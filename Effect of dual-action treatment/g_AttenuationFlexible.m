function [AllVirtualPatientTypes, percentage] = g_AttenuationFlexible(patient_type, SA_fold, SE_fold)
% g_AttenuationFlexible - Apply separate fold-change enhancements to SA and SE parameters
%
% SYNTAX:
%   [AllVirtualPatientTypes, percentage] = g_AttenuationFlexible(patient_type, SA_fold, SE_fold)
%
% INPUTS:
%   patient_type - 'reversible' or 'irreversible'
%   SA_fold      - Fold-change for gamma_AB (SA attenuation parameter)
%   SE_fold      - Fold-change for gamma_EB (SE attenuation parameter)
%
% OUTPUTS:
%   AllVirtualPatientTypes - Matrix with classified patients
%   percentage - % of patients gaining healthy states
%
% OUTPUT FILES:
%   data/attenuation_[type]_SA[x]_SE[y].csv - Full steady state results
%
% Author: Jamie Lee (refactored)
% Date: October 14, 2025

%% Step 1: Setup paths and load data

current_dir = pwd;
analyse_folder = fullfile(current_dir, '..', 'Analyse steady states');

if ~exist(analyse_folder, 'dir')
    error('Cannot find Analyse steady states folder at: %s', analyse_folder);
end

% Add path to helper functions
addpath(analyse_folder);

% Verify required functions exist
required_functions = {'f_computeCase1', 'f_computeCase2', 'f_computeCase3', 'f_computeCase4'};
for i = 1:length(required_functions)
    if exist(required_functions{i}, 'file') ~= 2
        error('Cannot find %s.m', required_functions{i});
    end
end

fprintf('  ✓ Helper functions loaded\n');

% Load classification data from SA-killing folder
data_path = fullfile(current_dir, '..', 'Effect of SA-killing', 'data');
data_file = fullfile(data_path, sprintf('%s_SAkilling.csv', patient_type));

if ~exist(data_file, 'file')
    error('Cannot find classification file: %s\nPlease run g_ExtractInitialConditions.m first', data_file);
end

skin_sites = readmatrix(data_file);
n_patients = size(skin_sites, 1);
fprintf('  ✓ Loaded %d patient rows from %s\n\n', n_patients, data_file);

%% Step 2: Extract and enhance parameters
fprintf('[2/6] Applying fold-change enhancements...\n');

% Extract parameter sets (columns 3-19 in original file)
ParamSet = skin_sites(:, 3:19);

fprintf('  ✓ Enhanced gamma_AB by %.1fx\n', SA_fold);
fprintf('  ✓ Enhanced gamma_EB by %.1fx\n\n', SE_fold);

%% Step 3: Compute steady states for all patients
% Preallocate cell array for parallel processing
AllSteadyStates_cell = cell(n_patients, 1);
parfor i = 1:n_patients
    % Extract parameters for this patient
    kappa_A  = ParamSet(i, 1);
    A_max    = ParamSet(i, 2);
    gamma_AB = SA_fold * ParamSet(i, 3);  % ENHANCE SA attenuation
    delta_AE = ParamSet(i, 4);
    A_th     = ParamSet(i, 5);
    E_pth    = ParamSet(i, 6);
    gamma_AE = ParamSet(i, 7);
    
    kappa_E  = ParamSet(i, 8);
    E_max    = ParamSet(i, 9);
    gamma_EB = SE_fold * ParamSet(i, 10); % ENHANCE SE attenuation
    delta_EA = ParamSet(i, 11);
    E_th     = ParamSet(i, 12);
    A_pth    = ParamSet(i, 13);
    
    kappa_B  = ParamSet(i, 14);
    delta_B  = ParamSet(i, 15);
    delta_BA = ParamSet(i, 16);
    delta_BE = ParamSet(i, 17);
    
    % Store enhanced parameter set
    VirtualPatient = [kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, gamma_AE, ...
                      kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
                      kappa_B, delta_B, delta_BA, delta_BE];
    
    % Compute steady states for 4 agr scenarios
    % Case 1: Neither SA nor SE agr active
    output_1 = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
                               gamma_EB, E_th, kappa_B, delta_B);
    
    % Case 2: Only SA agr active
    output_2 = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
                               gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA);
    
    % Case 3: Only SE agr active
    output_3 = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, ...
                               kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B, delta_BE);
    
    % Case 4: Both SA and SE agr active
    output_4 = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, gamma_AE, ...
                               kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
                               kappa_B, delta_B, delta_BA, delta_BE);
    
    % Process each case's output
    SteadyStates = [];
    
    for case_num = 1:4
        if case_num == 1
            SteadyState = real(output_1);
        elseif case_num == 2
            SteadyState = output_2;
        elseif case_num == 3
            SteadyState = real(output_3);
        else
            SteadyState = real(output_4);
        end
        
        % Remove rows with only zeros
        SteadyState(~any(SteadyState, 2), :) = [];
        
        if ~isempty(SteadyState)
            % Repeat parameter set for each steady state
            Params = repmat(VirtualPatient, size(SteadyState, 1), 1);
            SteadyStates = [SteadyStates; [Params, SteadyState]];
        end
    end
    
    AllSteadyStates_cell{i} = SteadyStates;
end

% Combine results from all patients
AllSteadyStates = vertcat(AllSteadyStates_cell{:});

%% Step 4: Filter for stable states only
% Preallocate cell array for parallel filtering
AllStableStates_cell = cell(size(AllSteadyStates, 1), 1);

% Check stability: eigenvalues in columns 21, 22, 23 must all be negative
parfor j = 1:size(AllSteadyStates, 1)
    if (AllSteadyStates(j, 21) < 0 && AllSteadyStates(j, 22) < 0 && ...
        AllSteadyStates(j, 23) < 0)
        AllStableStates_cell{j} = AllSteadyStates(j, :);
    else
        AllStableStates_cell{j} = [];
    end
end

% Remove empty cells and concatenate
AllStableStates_cell = AllStableStates_cell(~cellfun('isempty', AllStableStates_cell));
AllStableStates = vertcat(AllStableStates_cell{:});

%% Step 5: Number patients and prepare for classification
Param = AllStableStates(:, 1:17);

% Find unique parameter sets
[~, ~, ic] = unique(Param, 'rows', 'stable');

% Count occurrences per patient
count = accumarray(ic, 1);
map = count(ic);

numVirtualPatients = [ic, map, Param];
AllVirtualPatients = [numVirtualPatients, AllStableStates(:, 18:23)];
% removed unused variable n_unique_patients to avoid unused-assignment warning

%% Step 6: Classify patients using a_PatientGroups
data_folder = 'data';
figures_folder = 'figures';

% Ensure folders exist
if ~exist(data_folder, 'dir'), mkdir(data_folder); end
if ~exist(figures_folder, 'dir'), mkdir(figures_folder); end

% Save AllVirtualPatients for a_PatientGroups to load
temp_file = fullfile(data_folder, 'AllVirtualPatients_latest.csv');
writematrix(AllVirtualPatients, temp_file);

% Suppress a_PatientGroups output (it's verbose)
evalc('a_PatientGroups');

% Verify the output was created in the current workspace; if not, try common output files
if ~exist('AllVirtualPatientTypes', 'var')
    % Common candidate output filenames that a_PatientGroups might write
    candidate_files = { fullfile(data_folder, 'AllVirtualPatientTypes_latest.csv'), ...
                        fullfile(data_folder, 'AllVirtualPatientTypes.csv'), ...
                        fullfile(pwd, 'AllVirtualPatientTypes.csv') };
    loaded = false;
    for cf = 1:numel(candidate_files)
        if exist(candidate_files{cf}, 'file')
            try
                AllVirtualPatientTypes = readmatrix(candidate_files{cf});
                loaded = true;
                break;
            catch
                % continue to next candidate if read fails
            end
        end
    end
    if ~loaded
        delete(temp_file);
        error('a_PatientGroups failed to create AllVirtualPatientTypes and no fallback file was found.');
    end
end

% Clean up temporary file
delete(temp_file);

%% Step 7: Merge regions 8 and 9
AllVirtualPatientTypes(AllVirtualPatientTypes(:, 26) == 9, 26) = 8;

%% Step 8: Save results
output_folder = 'data';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

output_file = fullfile(output_folder, sprintf('attenuation_%s_SA%.1f_SE%.1f.csv', ...
                                               patient_type, SA_fold, SE_fold));

writematrix(AllVirtualPatientTypes, output_file);

%% Step 9: Calculate percentage
count_1 = sum(AllVirtualPatientTypes(:, 26) == 1);
count_2 = sum(AllVirtualPatientTypes(:, 26) == 2);
count_3 = sum(AllVirtualPatientTypes(:, 26) == 3);
count_4 = sum(AllVirtualPatientTypes(:, 26) == 4);
count_healthy_regions = count_1 + count_2 + count_3 + count_4;
percentage = 100 * count_healthy_regions / n_patients;

end