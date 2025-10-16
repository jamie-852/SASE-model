% a_SampledParameters.m
%
% Purpose: Compute steady states for all sampled parameter sets
%          Analyzes 1 million parameter sets across 4 biological scenarios
%          (different combinations of SA and SE accessory gene regulator activity)
%
% Inputs:  data/SampledParameters_latest.csv (from g_samples.m)
% Outputs: data/AllSteadyStates_[date].csv
%          Contains 23 columns: 17 parameters + 3 steady states + 3 eigenvalues
%
% Dependencies: f_computeCase1.m, f_computeCase2.m, f_computeCase3.m, f_computeCase4.m
%
% Author: Jamie Lee
% Date: 6 October 2025
% Version: 2.0 - Added data/figures folders, progress tracking, improved clarity

clc;
close all;

fprintf('=== Steady State Analysis Script ===\n');
fprintf('Computing steady states for all sampled parameters...\n\n');

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

% Create folders if they don't exist
if ~exist(data_folder, 'dir')
    mkdir(data_folder);
    fprintf('Created data folder: %s\n', data_folder);
end
if ~exist(figures_folder, 'dir')
    mkdir(figures_folder);
    fprintf('Created figures folder: %s\n', figures_folder);
end

%% Load sampled parameters
fprintf('\n[1/4] Loading parameter samples...\n');

input_file = fullfile(data_folder, 'SampledParameters_latest.csv');

% Check if file exists
if ~exist(input_file, 'file')
    error('Input file not found: %s\nPlease run g_samples.m first.', input_file);
end

% Use tabularTextDatastore for efficient handling of large files
ds = tabularTextDatastore(input_file);

% Get total number of rows for progress tracking
% Note: NumRows not available in older MATLAB versions
if ~exist('n_samples', 'var')
    % Estimate from file or use default
    total_samples = 10^6;  % Default assumption
    fprintf('  ✓ Expected parameter sets: %d (using default)\n', total_samples);
else
    total_samples = n_samples;  % Use value from main script
    fprintf('  ✓ Expected parameter sets: %d (from configuration)\n', total_samples);
end
fprintf('  ✓ Input file: %s\n', input_file);

%% Initialize output matrix
fprintf('\n[2/4] Initializing output structures...\n');

% Pre-allocate with first row of zeros (will be removed later)
% Columns: 17 parameters + 3 steady states (A*, E*, B*) + 3 eigenvalues
AllSteadyStates = zeros(1, 23);

% Counter for processed samples
samples_processed = 0;
last_progress = 0;

fprintf('  ✓ Output matrix initialized (23 columns)\n');
fprintf('  ✓ Parallel processing enabled\n\n');

%% Process parameter sets in batches
fprintf('[3/4] Computing steady states...\n');
fprintf('Processing %d parameter sets across 4 scenarios...\n', total_samples);
fprintf('This may take several hours. Progress will be shown every 10%%.\n\n');

batch_num = 0;

while hasdata(ds)
    batch_num = batch_num + 1;
    T = read(ds);
    ParamSet = table2array(T);
    
    batch_size = size(ParamSet, 1);
    fprintf('  Processing batch %d (%d parameter sets)...\n', batch_num, batch_size);
    
    % Process batch in parallel
    batch_results = cell(batch_size, 1);
    
    parfor i = 1:batch_size
        try
            % Extract parameters and convert from log scale where needed
            kappa_A  = 10^ParamSet(i, 1);   % SA growth rate
            A_max    = ParamSet(i, 2);       % SA max population (linear scale)
            gamma_AB = 10^ParamSet(i, 3);   % SA inhibition by barrier
            delta_AE = 10^ParamSet(i, 4);   % SA killing by SE
            A_th     = 10^ParamSet(i, 5);   % SA threshold
            E_pth    = 10^ParamSet(i, 6);   % SE presence threshold
            gamma_AE = 10^ParamSet(i, 7);   % SA inhibition by SE
            
            kappa_E  = 10^ParamSet(i, 8);   % SE growth rate
            E_max    = ParamSet(i, 9);       % SE max population (linear scale)
            gamma_EB = 10^ParamSet(i, 10);  % SE inhibition by barrier
            delta_EA = 10^ParamSet(i, 11);  % SE killing by SA
            E_th     = 10^ParamSet(i, 12);  % SE threshold
            A_pth    = 10^ParamSet(i, 13);  % SA presence threshold
            
            kappa_B  = 10^ParamSet(i, 14);  % Barrier recovery rate
            delta_B  = 10^ParamSet(i, 15);  % Barrier degradation rate
            delta_BA = 10^ParamSet(i, 16);  % Barrier damage by SA
            
            % Special handling for very small delta_BE values
            if ParamSet(i, 17) < -10
                delta_BE = 0;  % Treat as effectively zero
            else
                delta_BE = 10^ParamSet(i, 17);  % Barrier damage by SE
            end
            
            % Store parameter set (in linear scale)
            VirtualPatient = [kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
                E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
                E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE];
            
            %% Compute steady states for all 4 scenarios
            
            % Case 1: Neither SA nor SE agr active
            [output_1] = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, ...
                kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B);
            
            % Case 2: Only SA agr active
            [output_2] = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, ...
                kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
                kappa_B, delta_B, delta_BA);
            
            % Case 3: Only SE agr active
            [output_3] = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, ...
                A_th, E_pth, kappa_E, E_max, gamma_EB, E_th, ...
                kappa_B, delta_B, delta_BE);
            
            % Case 4: Both SA and SE agr active
            [output_4] = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, ...
                A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
                E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE);
            
            %% Process Case 1: No agr activity
            SteadyState_1 = output_1;
            SteadyState_1(~any(SteadyState_1, 2), :) = [];  % Remove zero rows
            if ~isempty(SteadyState_1)
                Params = repmat(VirtualPatient, size(SteadyState_1, 1), 1);
                output_one = [Params, SteadyState_1];
            else
                output_one = [];
            end
            
            %% Process Case 2: SA agr active
            SteadyState_2 = output_2;
            SteadyState_2(~any(SteadyState_2, 2), :) = [];
            if ~isempty(SteadyState_2)
                Params = repmat(VirtualPatient, size(SteadyState_2, 1), 1);
                output_two = [Params, SteadyState_2];
            else
                output_two = [];
            end
            
            %% Process Case 3: SE agr active
            SteadyState_3 = output_3;
            SteadyState_3(~any(SteadyState_3, 2), :) = [];
            if ~isempty(SteadyState_3)
                Params = repmat(VirtualPatient, size(SteadyState_3, 1), 1);
                output_three = [Params, SteadyState_3];
            else
                output_three = [];
            end
            
            %% Process Case 4: Both agr active
            SteadyState_4 = output_4;
            SteadyState_4(~any(SteadyState_4, 2), :) = [];
            if ~isempty(SteadyState_4)
                Params = repmat(VirtualPatient, size(SteadyState_4, 1), 1);
                output_four = [Params, SteadyState_4];
            else
                output_four = [];
            end
            
            %% Combine all steady states for this parameter set
            SteadyStates = [output_one; output_two; output_three; output_four];
            
            % Store in cell array for this batch
            batch_results{i} = SteadyStates;
            
        catch ME
            % If error occurs for a parameter set, store empty and continue
            warning('Error processing parameter set %d in batch %d: %s', ...
                i, batch_num, ME.message);
            batch_results{i} = [];
        end
    end
    
    % Combine batch results
    for i = 1:batch_size
        if ~isempty(batch_results{i})
            AllSteadyStates = [AllSteadyStates; batch_results{i}];
        end
    end
    
    % Update progress
    samples_processed = samples_processed + batch_size;
    progress = floor(100 * samples_processed / total_samples);
    
    % Show progress every 10%
    if progress >= last_progress + 10
        fprintf('  Progress: %d%% (%d/%d parameter sets)\n', ...
            progress, samples_processed, total_samples);
        last_progress = progress;
    end
end

% Remove the initial row of zeros
AllSteadyStates(1, :) = [];

fprintf('\n  ✓ Computation complete!\n');
fprintf('  ✓ Total steady states found: %d\n', size(AllSteadyStates, 1));
fprintf('  ✓ Average steady states per parameter set: %.2f\n', ...
    size(AllSteadyStates, 1) / total_samples);

%% Save results
fprintf('\n[4/4] Saving results...\n');

% Check if intermediate files should be saved (from main script)
if ~exist('save_intermediate_files', 'var')
    save_intermediate_files = true;  % Default: save everything (standalone mode)
end

if save_intermediate_files
    % Save as CSV (timestamped)
    csv_filename = fullfile(data_folder, sprintf('AllSteadyStates_%s.csv', date_str));
    writematrix(AllSteadyStates, csv_filename);
    fprintf('  ✓ Saved CSV: %s\n', csv_filename);

    % Save as MAT (faster for MATLAB)
    mat_filename = fullfile(data_folder, sprintf('AllSteadyStates_%s.mat', date_str));
    save(mat_filename, 'AllSteadyStates', 'total_samples');
    fprintf('  ✓ Saved MAT: %s\n', mat_filename);
else
    fprintf('  ⊝ Intermediate files skipped (save_intermediate_files = false)\n');
end

% Always save latest version (needed by next scripts)
csv_latest = fullfile(data_folder, 'AllSteadyStates_latest.csv');
writematrix(AllSteadyStates, csv_latest);
fprintf('  ✓ Saved latest CSV: %s\n', csv_latest);

%% Summary statistics
fprintf('\n=== Summary Statistics ===\n');
fprintf('Input: %d parameter sets\n', total_samples);
fprintf('Output: %d steady states\n', size(AllSteadyStates, 1));
fprintf('Columns: 23 (17 parameters + 3 steady states + 3 eigenvalues)\n');

% Analyze steady state distributions
A_star = AllSteadyStates(:, 18);
E_star = AllSteadyStates(:, 19);
B_star = AllSteadyStates(:, 20);

fprintf('\nSteady state ranges:\n');
fprintf('  A* (SA): [%.2e, %.2e]\n', min(A_star), max(A_star));
fprintf('  E* (SE): [%.2e, %.2e]\n', min(E_star), max(E_star));
fprintf('  B* (Barrier): [%.4f, %.4f]\n', min(B_star), max(B_star));

% Count stable states (negative eigenvalues)
lambda1 = AllSteadyStates(:, 21);
lambda2 = AllSteadyStates(:, 22);
lambda3 = AllSteadyStates(:, 23);
stable = (lambda1 < 0) & (lambda2 < 0) & (lambda3 < 0);
fprintf('\nStability analysis:\n');
fprintf('  Stable steady states: %d (%.1f%%)\n', sum(stable), 100*mean(stable));
fprintf('  Unstable steady states: %d (%.1f%%)\n', sum(~stable), 100*mean(~stable));

%% Completion message
elapsed_time = toc;
fprintf('\n=== Steady State Analysis Complete ===\n');
fprintf('Total execution time: %.2f minutes (%.2f hours)\n', ...
    elapsed_time/60, elapsed_time/3600);
fprintf('\nNext step: Run g_VirtualPatients.m to assign patient IDs\n');

%% End of script