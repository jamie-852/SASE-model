% g_AttenuationOnly.m
%
% Purpose: Simulate attenuation-only treatment by enhancing bacterial growth 
%          attenuation by the skin barrier (modifying gamma_AB and gamma_EB)
%
% This treatment modifies the skin's parameters to make it more hostile to
% bacterial growth, potentially converting damaged states to healthy states.
%
% The script:
%   1. Loads initial patient data (irreversible or reversible)
%   2. Enhances gamma_AB and gamma_EB by specified fold-change
%   3. Recomputes all steady states with modified parameters
%   4. Classifies patients and counts how many gain healthy states
%   5. Saves modified patients for downstream analysis
%
% Prerequisites:
%   - Must have helper functions in path from '../Analyse steady states/':
%     f_computeCase1.m, f_computeCase2.m, f_computeCase3.m, f_computeCase4.m
%     a_PatientGroups.m, f_SteadyStateCheck.m
%
% Inputs:  ../Effect of SA-killing/data/irreversible_SAkilling.csv 
%          ../Effect of SA-killing/data/reversible_SAkilling.csv
% Outputs: data/attenuation_[patient_type]_[fold]x.csv
%          data/attenuation_summary_[patient_type]_[fold]x.csv
%
% Usage:
%   g_AttenuationOnly('irreversible', 20)  % 20-fold enhancement for irreversible
%   g_AttenuationOnly('reversible', 20)    % 20-fold enhancement for reversible
%
% Author: Jamie Lee
% Date: 13 October 2025
% Version: 3.1 - Fixed path handling for parallel operations

function g_AttenuationOnly(patient_type, fold_change)
    
    clc;
    fprintf('=== Attenuation-Only Treatment Simulation ===\n\n');
    
    %% Add path to helper functions
    helper_path = '../Analyse steady states';
    if exist(helper_path, 'dir')
        addpath(helper_path);
        fprintf('Added helper functions to path: %s\n', helper_path);
        
        % Verify all required functions exist
        required_functions = {'f_computeCase1', 'f_computeCase2', 'f_computeCase3', ...
                              'f_computeCase4', 'a_PatientGroups'};
        
        for i = 1:length(required_functions)
            if exist(required_functions{i}, 'file') ~= 2
                error('Cannot find %s.m\nPlease check that it exists in: %s', ...
                      required_functions{i}, helper_path);
            end
        end
        fprintf('✓ All helper functions verified\n');
    else
        error(['Cannot find helper functions folder: %s\n' ...
               'Please ensure ''Analyse steady states'' folder exists at this path'], helper_path);
    end
    fprintf('\n');
    
    %% Configuration
    if nargin < 1
        patient_type = 'irreversible';  % Default to irreversible patients
    end
    
    if nargin < 2
        fold_change = 20;  % Default to 20-fold enhancement
    end
    
    fprintf('Configuration:\n');
    fprintf('  Patient type: %s\n', patient_type);
    fprintf('  Fold enhancement: %dx\n', fold_change);
    fprintf('  Treatment: Enhance gamma_AB and gamma_EB (skin bacterial attenuation)\n');
    fprintf('\n');
    
    %% Load input data
    fprintf('[1/6] Loading patient data...\n');
    
    if strcmp(patient_type, 'irreversible')
        input_file = '../Effect of SA-killing/data/irreversible_SAkilling.csv';
    elseif strcmp(patient_type, 'reversible')
        input_file = '../Effect of SA-killing/data/reversible_SAkilling.csv';
    else
        error('Invalid patient_type. Use ''irreversible'' or ''reversible''');
    end
    
    if ~exist(input_file, 'file')
        error('Cannot find %s\nPlease run g_ExtractInitialConditions.m first', input_file);
    end
    
    skin_sites = readmatrix(input_file);
    n_patients = size(skin_sites, 1);
    
    fprintf('  ✓ Loaded: %s\n', input_file);
    fprintf('  Total patients: %d\n', n_patients);
    fprintf('  Expected computation time: ~%.0f seconds\n\n', n_patients * 0.5);
    
    %% Apply fold-change enhancement
    fprintf('[2/6] Applying %dx fold enhancement...\n', fold_change);
    fprintf('  Parameters modified:\n');
    fprintf('    gamma_AB (SA growth attenuation): Column 5 × %d\n', fold_change);
    fprintf('    gamma_EB (SE growth attenuation): Column 12 × %d\n', fold_change);
    fprintf('\n');
    
    %% Recompute steady states with enhanced parameters
    fprintf('[3/6] Recomputing steady states with enhanced parameters...\n');
    fprintf('  Using helper functions: f_computeCase1-4.m\n');
    fprintf('  Progress: 0%%');
    
    ParamSet = skin_sites(:, 3:19);
    n_param_sets = size(ParamSet, 1);
    
    % Pre-allocate cell array for parallel results
    SteadyStateCell = cell(n_param_sets, 1);
    
    tic;
    parfor i = 1:n_param_sets
        % Extract parameters
        kappa_A  = ParamSet(i, 1);
        A_max    = ParamSet(i, 2);
        gamma_AB = fold_change * ParamSet(i, 3);  % Enhanced
        delta_AE = ParamSet(i, 4);
        A_th     = ParamSet(i, 5);
        E_pth    = ParamSet(i, 6);
        gamma_AE = ParamSet(i, 7);
        kappa_E  = ParamSet(i, 8);
        E_max    = ParamSet(i, 9);
        gamma_EB = fold_change * ParamSet(i, 10);  % Enhanced
        delta_EA = ParamSet(i, 11);
        E_th     = ParamSet(i, 12);
        A_pth    = ParamSet(i, 13);
        kappa_B  = ParamSet(i, 14);
        delta_B  = ParamSet(i, 15);
        delta_BA = ParamSet(i, 16);
        delta_BE = ParamSet(i, 17);
        
        VirtualPatient = [kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
            E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
            E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE];
        
        % Compute steady states for all 4 cases (from Analyse steady states)
        output_1 = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, kappa_E, ...
            E_max, gamma_EB, E_th, kappa_B, delta_B);
        
        output_2 = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, kappa_E, ...
            E_max, gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA);
        
        output_3 = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
            E_pth, kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B, delta_BE);
        
        output_4 = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
            E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
            kappa_B, delta_B, delta_BA, delta_BE);
        
        % Process Case 1: SA and SE agr inactive
        SteadyState_1 = real(output_1);
        SteadyState_1(~any(SteadyState_1, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_1, 1), 1);
        output_one = [Params, SteadyState_1];
        
        % Process Case 2: Only SA agr active
        SteadyState_2 = output_2;
        SteadyState_2(~any(SteadyState_2, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_2, 1), 1);
        output_two = [Params, SteadyState_2];
        
        % Process Case 3: Only SE agr active
        SteadyState_3 = real(output_3);
        SteadyState_3(~any(SteadyState_3, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_3, 1), 1);
        output_three = [Params, SteadyState_3];
        
        % Process Case 4: Both SA and SE agr active
        SteadyState_4 = real(output_4);
        SteadyState_4(~any(SteadyState_4, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_4, 1), 1);
        output_four = [Params, SteadyState_4];
        
        % Combine all steady states for this patient
        SteadyStateCell{i} = [output_one; output_two; output_three; output_four];
    end
    
    % Concatenate all results after parallel loop
    AllSteadyStates = vertcat(SteadyStateCell{:});
    
    fprintf('\b\b\b\b100%%\n');
    fprintf('  ✓ Complete (%.1f seconds)\n', toc);
    fprintf('  Total steady states found: %d\n\n', size(AllSteadyStates, 1));
    
    %% Check stability
    fprintf('[4/6] Filtering for stable steady states...\n');
    
    AllStableStates = [];
    parfor j = 1:size(AllSteadyStates, 1)
        % Check if all eigenvalues are negative (stable)
        if (AllSteadyStates(j, 21) < 0 && AllSteadyStates(j, 22) < 0 && ...
            AllSteadyStates(j, 23) < 0)
            AllStableStates = [AllStableStates; AllSteadyStates(j, :)];
        end
    end
    
    fprintf('  ✓ Stable steady states: %d\n\n', size(AllStableStates, 1));
    
    %% Organize by patient
    fprintf('[5/6] Organizing by patient and assigning regions...\n');
    
    Param = AllStableStates(:, 1:17);
    [~, ~, ic] = unique(Param, 'rows', 'stable');
    count = accumarray(ic, 1);
    map = count(ic);
    
    numVirtualPatients = [ic, map, Param];
    AllVirtualPatients = [numVirtualPatients, AllStableStates(:, 18:23)];
    
    % Ensure helper path is still available (important after parallel operations)
    if exist(helper_path, 'dir')
        addpath(helper_path);
    end
    
    % Double-check a_PatientGroups is accessible
    if exist('a_PatientGroups', 'file') ~= 2
        error(['Cannot find a_PatientGroups.m\n' ...
               'Please ensure it exists in: %s\n' ...
               'Current path: %s'], helper_path, path);
    end
    
    % Classify the processed patients directly (instead of using a_PatientGroups)
    fprintf('  Classifying %s patients into clinical categories...\n', patient_type);
    
    % Extract parameters for classification
    n_states = size(AllVirtualPatients, 1);
    A_max = AllVirtualPatients(1, 4);   % SA maximum population  
    E_max = AllVirtualPatients(1, 11);  % SE maximum population
    
    % Initialize category vector
    category = zeros(n_states, 1);
    
    % Classify each state (using same logic as a_PatientGroups)
    for i = 1:n_states
        A_th = AllVirtualPatients(i, 7);   % SA threshold
        % gamma_AE not needed for classification logic
        E_th = AllVirtualPatients(i, 14);  % SE threshold
        
        A_star = AllVirtualPatients(i, 20); % SA steady state
        E_star = AllVirtualPatients(i, 21); % SE steady state  
        B_star = AllVirtualPatients(i, 22); % Barrier steady state
        
        % Determine agr switch states
        sw_E = (E_star >= E_th) && (E_star <= E_max);
        sw_A = (A_star >= A_th) && (A_star <= A_max);
        
        % Classification logic (same as a_PatientGroups)
        if (A_star == 0) && (E_star == 0) && (B_star == 1) && (~sw_A) && (~sw_E)
            category(i) = 1; % Healthy, no bacteria
        elseif (A_star > 0) && (A_star < A_th) && (E_star == 0) && (B_star == 1) && (~sw_A) && (~sw_E)
            category(i) = 2; % Low SA, healthy
        elseif ((A_star == 0) && (E_star > 0) && (E_star < E_th) && (B_star == 1) && (~sw_A) && (~sw_E)) || ...
               ((A_star == 0) && (E_star >= E_th) && (E_star <= E_max) && (~sw_A) && sw_E && (B_star == 1))
            category(i) = 3; % SE present, healthy
        elseif (A_star > 0) && (A_star < A_th) && (E_star > 0) && (E_star < E_th) && (B_star == 1) && (~sw_A) && (~sw_E)
            category(i) = 4; % Both low, healthy
        elseif (A_star == 0) && (E_star >= E_th) && (E_star <= E_max) && (~sw_A) && sw_E && (B_star < 1)
            category(i) = 5; % High SE agr, damaged
        elseif (A_star > 0) && (A_star < A_th) && (E_star >= E_th) && (E_star <= E_max) && (~sw_A) && sw_E && (B_star == 1)
            category(i) = 6; % Low SA + high SE agr, healthy
        elseif (A_star >= A_th) && (A_star <= A_max) && (E_star == 0) && sw_A && (~sw_E) && (B_star < 1)
            category(i) = 7; % High SA agr, no SE
        elseif (A_star >= A_th) && (A_star <= A_max) && (E_star > 0) && (E_star < E_th) && sw_A && (~sw_E) && (B_star < 1)
            category(i) = 8; % High SA agr + low SE
        elseif (A_star >= A_th) && (A_star <= A_max) && (E_star >= E_th) && (E_star <= E_max) && sw_A && sw_E && (B_star < 1)
            category(i) = 9; % Both high agr
        end
    end
    
    % Create output matrix with categories
    AllVirtualPatientTypes = [AllVirtualPatients, category];
    
    % Save classified results to local data folder
    local_data_folder = 'data';
    if ~exist(local_data_folder, 'dir')
        mkdir(local_data_folder);
    end
    
    date_str = char(datetime('now', 'Format', 'yyyy-MM-dd'));
    patient_types_file = fullfile(local_data_folder, sprintf('%s_attenuation_%s.csv', patient_type, date_str));
    writematrix(AllVirtualPatientTypes, patient_types_file);
    fprintf('  ✓ Saved classified results: %s\n', patient_types_file);
    
    fprintf('  ✓ Patients organized and classified\n');
    fprintf('  Unique patients: %d\n', length(unique(ic)));
    fprintf('  Total steady state rows: %d\n\n', size(AllVirtualPatientTypes, 1));
    
    %% Count healthy states gained
    fprintf('[6/6] Analyzing treatment effectiveness...\n');
    
    % Count healthy steady states by category (B* = 1, regions 1-4)  
    % Category is now in the last column
    category_col = size(AllVirtualPatientTypes, 2);
    count_1 = nnz(AllVirtualPatientTypes(:, category_col) == 1);
    count_2 = nnz(AllVirtualPatientTypes(:, category_col) == 2);
    count_3 = nnz(AllVirtualPatientTypes(:, category_col) == 3);
    count_4 = nnz(AllVirtualPatientTypes(:, category_col) == 4);
    
    count_healthy_states = count_1 + count_2 + count_3 + count_4;
    
    % Count unique patients with at least one healthy state
    healthy_mask = (AllVirtualPatientTypes(:, category_col) == 1) | ...
                   (AllVirtualPatientTypes(:, category_col) == 2) | ...
                   (AllVirtualPatientTypes(:, category_col) == 3) | ...
                   (AllVirtualPatientTypes(:, category_col) == 4);
    unique_healthy_patients = length(unique(AllVirtualPatientTypes(healthy_mask, 1)));
    
    percentage = unique_healthy_patients / n_patients * 100;
    
    fprintf('  Healthy steady states by category:\n');
    fprintf('    Category 1: %d states\n', count_1);
    fprintf('    Category 2: %d states\n', count_2);
    fprintf('    Category 3: %d states\n', count_3);
    fprintf('    Category 4: %d states\n', count_4);
    fprintf('    Total healthy states: %d\n', count_healthy_states);
    fprintf('  Unique patients with healthy states: %d out of %d (%.1f%%)\n', ...
        unique_healthy_patients, n_patients, percentage);
    fprintf('\n');
    
    %% Save outputs
    fprintf('Saving outputs...\n');
    
    output_folder = 'data';
    mkdir(output_folder);
    
    % Save modified patient data for downstream dual-action analysis
    output_file = sprintf('%s/attenuation_%s_%dx.csv', output_folder, patient_type, fold_change);
    writematrix(AllVirtualPatients, output_file);
    fprintf('  ✓ Saved: %s\n', output_file);
    fprintf('    Use this file for dual-action treatment (attenuation + SA-killing)\n');
    
    % Save summary statistics
    summary = [fold_change, n_patients, unique_healthy_patients, percentage];
    summary_file = sprintf('%s/attenuation_summary_%s_%dx.csv', output_folder, patient_type, fold_change);
    writematrix(summary, summary_file);
    fprintf('  ✓ Saved: %s\n', summary_file);
    fprintf('    [fold_change, n_original, n_patients_healthy, percentage]\n\n');
    
    %% Summary
    fprintf('=== Attenuation-Only Treatment Complete ===\n');
    fprintf('Treatment: %dx enhancement of gamma_AB and gamma_EB\n', fold_change);
    fprintf('Patients gaining healthy states: %d out of %d (%.1f%%)\n', ...
        unique_healthy_patients, n_patients, percentage);
    fprintf('\n');
    fprintf('Next steps:\n');
    fprintf('  1. Visualize attenuation-only results (optional)\n');
    fprintf('  2. For dual-action treatment, apply SA-killing to:\n');
    fprintf('     → Use: run_DualAction.m (attenuation + SA-killing combined)\n');
    fprintf('\n');
    
end