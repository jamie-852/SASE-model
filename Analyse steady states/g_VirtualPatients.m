% g_VirtualPatients.m
%
% Purpose: Group steady states by unique parameter sets and assign patient IDs
%          Filters for stable states only (negative eigenvalues)
%          Each unique parameter set = one virtual patient
%
% Inputs:  data/AllSteadyStates_latest.csv (from a_SampledParameters.m)
% Outputs: data/AllVirtualPatients_latest.csv
%          Contains: [Patient_ID, Num_Stable_States, Parameters(1-17), 
%                     Steady_States(A*,E*,B*), Eigenvalues(λ1,λ2,λ3)]
%
% Author: Jamie Lee
% Date: 6 October 2025
% Version: 2.0 - Improved clarity, added configuration

clc;
close all;

fprintf('=== Virtual Patient Assignment ===\n');
fprintf('Grouping steady states by unique parameter sets...\n\n');

tic;  % Start timing

%% Configuration - Use main script values if available, otherwise use defaults
if ~exist('data_folder', 'var')
    data_folder = 'data';
end
if ~exist('figures_folder', 'var')
    figures_folder = 'figures';
end
if ~exist('date_str', 'var')
    date_str = datestr(now, 'yyyy-mm-dd');
end

% Create folders if needed
if ~exist(data_folder, 'dir')
    mkdir(data_folder);
end
if ~exist(figures_folder, 'dir')
    mkdir(figures_folder);
end

%% Load data
fprintf('[1/5] Loading steady states...\n');

input_file = fullfile(data_folder, 'AllSteadyStates_latest.csv');

% Check if file exists
if ~exist(input_file, 'file')
    error('Input file not found: %s\nPlease run a_SampledParameters.m first.', input_file);
end

AllSteadyStates = readmatrix(input_file);
fprintf('  ✓ Loaded %d steady states\n', size(AllSteadyStates, 1));

% Remove any rows with only zeros (shouldn't exist, but defensive programming)
zero_rows = ~any(AllSteadyStates, 2);
if any(zero_rows)
    AllSteadyStates(zero_rows, :) = [];
    fprintf('  ✓ Removed %d zero rows\n', sum(zero_rows));
end

%% Filter for stable states only
fprintf('\n[2/5] Filtering for stable steady states...\n');
fprintf('  (Stability criterion: all eigenvalues < 0)\n');

% Extract eigenvalues (columns 21-23)
lambda1 = AllSteadyStates(:, 21);
lambda2 = AllSteadyStates(:, 22);
lambda3 = AllSteadyStates(:, 23);

% Check stability: all three eigenvalues must be negative
is_stable = (lambda1 < 0) & (lambda2 < 0) & (lambda3 < 0);

% Filter for stable states
AllStableStates = AllSteadyStates(is_stable, :);

n_total = size(AllSteadyStates, 1);
n_stable = size(AllStableStates, 1);
stability_rate = 100 * n_stable / n_total;

fprintf('  ✓ Total steady states:  %d\n', n_total);
fprintf('  ✓ Stable states:        %d (%.1f%%)\n', n_stable, stability_rate);
fprintf('  ✓ Unstable states:      %d (%.1f%%)\n', n_total - n_stable, 100 - stability_rate);

%% Group by unique parameter sets
fprintf('\n[3/5] Grouping by unique parameter sets...\n');

% Extract parameter sets (columns 1-17)
ParameterSets = AllStableStates(:, 1:17);

% Find unique parameter sets
% 'stable' option maintains original order
[UniqueParams, ~, patient_id] = unique(ParameterSets, 'rows', 'stable');

n_unique_patients = size(UniqueParams, 1);
fprintf('  ✓ Unique parameter sets (virtual patients): %d\n', n_unique_patients);

%% Count stable states per patient
fprintf('\n[4/5] Counting stable states per patient...\n');

% Count how many stable states each unique parameter set has
states_per_patient = accumarray(patient_id, 1);

% Map the count back to each row
% Each row gets labeled with how many stable states its patient has
num_stable_states = states_per_patient(patient_id);

% Summary statistics
min_states = min(states_per_patient);
max_states = max(states_per_patient);
mean_states = mean(states_per_patient);
median_states = median(states_per_patient);

fprintf('  ✓ Stable states per patient:\n');
fprintf('    - Minimum:  %d\n', min_states);
fprintf('    - Maximum:  %d\n', max_states);
fprintf('    - Mean:     %.2f\n', mean_states);
fprintf('    - Median:   %.0f\n', median_states);

%% Build output matrix
fprintf('\n[5/5] Building output matrix...\n');

% Output structure (25 columns):
% Column 1:    Patient ID (1 to N unique patients)
% Column 2:    Number of stable states for this patient
% Columns 3-19: Parameter set (17 parameters)
% Columns 20-22: Steady states (A*, E*, B*)
% Columns 23-25: Eigenvalues (λ1, λ2, λ3)

AllVirtualPatients = [patient_id, ...                    % Col 1: Patient ID
                      num_stable_states, ...             % Col 2: # states
                      AllStableStates(:, 1:17), ...      % Cols 3-19: Parameters
                      AllStableStates(:, 18:23)];        % Cols 20-25: States & eigenvalues

fprintf('  ✓ Output matrix size: %d rows × %d columns\n', ...
    size(AllVirtualPatients, 1), size(AllVirtualPatients, 2));

%% Save results
fprintf('\nSaving results...\n');

% Check if intermediate files should be saved (from main script)
if ~exist('save_intermediate_files', 'var')
    save_intermediate_files = true;  % Default: save everything (standalone mode)
end

if save_intermediate_files
    % Save as CSV (timestamped)
    csv_filename = fullfile(data_folder, sprintf('AllVirtualPatients_%s.csv', date_str));
    writematrix(AllVirtualPatients, csv_filename);
    fprintf('  ✓ Saved CSV: %s\n', csv_filename);

    % Save as MAT (faster for MATLAB)
    mat_filename = fullfile(data_folder, sprintf('AllVirtualPatients_%s.mat', date_str));
    save(mat_filename, 'AllVirtualPatients', 'n_unique_patients', 'states_per_patient');
    fprintf('  ✓ Saved MAT: %s\n', mat_filename);
else
    fprintf('  ⊝ Intermediate files skipped (save_intermediate_files = false)\n');
end

% Always save latest version (needed by next scripts)
csv_latest = fullfile(data_folder, 'AllVirtualPatients_latest.csv');
writematrix(AllVirtualPatients, csv_latest);
fprintf('  ✓ Saved latest CSV: %s\n', csv_latest);

%% Summary
elapsed_time = toc;

fprintf('\n=== Virtual Patient Assignment Complete ===\n');
fprintf('Total execution time: %.1f seconds\n', elapsed_time);
fprintf('\nSummary:\n');
fprintf('  Input:  %d steady states (%.1f%% stable)\n', n_total, stability_rate);
fprintf('  Output: %d virtual patients\n', n_unique_patients);
fprintf('  Average: %.2f stable states per patient\n', mean_states);
fprintf('\nOutput columns (25 total):\n');
fprintf('  Col 1:     Patient ID\n');
fprintf('  Col 2:     Number of stable states\n');
fprintf('  Cols 3-19: Parameters (17 columns)\n');
fprintf('  Cols 20-22: Steady states (A*, E*, B*)\n');
fprintf('  Cols 23-25: Eigenvalues (λ1, λ2, λ3)\n');
fprintf('\nNext step: Run a_PatientGroups.m to classify patients\n');

%% End of script