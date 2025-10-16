% g_samples.m
%
% Purpose: Generate parameter samples for virtual patient generation
%          Samples 1 million parameter sets from log-uniform distributions
%          based on ranges defined in Supplementary Table S1
%
% Outputs: SampledParameters_[date].csv in ./output/ folder
%          Contains 17 columns (15 parameters + 2 constants)
%
% Author: Jamie Lee
% Date: 6 October 2025
% Version: 2.0 - Added output folder, improved clarity

clc;
% Don't clear all - we want to keep workspace variables from main script
% clear all;  
close all;

fprintf('Generating parameter samples...\n\n');

%% Configuration - Use main script values if available, otherwise use defaults
if ~exist('n_samples', 'var')
    n_samples = 10^6;  % Default: 1 million parameter sets
end
if ~exist('data_folder', 'var')
    data_folder = 'data';  % Default data folder
end
if ~exist('figures_folder', 'var')
    figures_folder = 'figures';  % Default figures folder
end
if ~exist('date_str', 'var')
    date_str = datestr(now, 'yyyy-mm-dd');
end

% Random seed - IMPORTANT: This should be set by main script or user
% Don't initialize here if running from main script
if ~exist('rng_initialized', 'var')
    rng(0, 'twister');  % Default seed only if not already set
    fprintf('Random seed: 0 (default - standalone mode)\n');
end
fprintf('Number of samples: %d\n\n', n_samples);

%% Create folders if they don't exist
if ~exist(data_folder, 'dir')
    mkdir(data_folder);
    fprintf('Created data folder: %s\n', data_folder);
end
if ~exist(figures_folder, 'dir')
    mkdir(figures_folder);
    fprintf('Created figures folder: %s\n', figures_folder);
end
fprintf('\n');

%% Helper function for log-uniform sampling
% This reduces repetitive code
log_uniform = @(n, log_min, log_max) (log_max - log_min) .* rand(n, 1) + log_min;

%% Growth, inhibitions and killing of S. aureus
fprintf('[1/3] Sampling S. aureus parameters...\n');

% kappa_A: Growth rate of SA
% Range: [9, 27] → log range: [0.954, 1.431]
log_kappa_A = log_uniform(n_samples, 0.954, 1.431);

% A_max: Maximum SA population (constant)
% Value: 11.1 × 10^8 → log value: 9.045
A_max = repmat(11.1 * 10^8, n_samples, 1);

% gamma_AB: SA inhibition by barrier
% Range: [58.7, 5870] → log range: [1.769, 3.769]
log_gamma_AB = log_uniform(n_samples, 1.769, 3.769);

% delta_AE: SA killing by SE
% Range: [4.78, 478] → log range: [0.679, 2.679]
log_delta_AE = log_uniform(n_samples, 0.679, 2.679);

% A_th: SA threshold for barrier damage
% Range: [1.13 × 10^7, 1.11 × 10^9] → log range: [7.053, 9.045]
log_A_th = log_uniform(n_samples, 7.053, 9.045);

% E_pth: SE presence threshold for SA growth inhibition
% Range: [1.13 × 10^7, 1.11 × 10^9] → log range: [7.053, 9.045]
log_E_pth = log_uniform(n_samples, 7.053, 9.045);

% gamma_AE: SA inhibition by SE presence
% Range: [1.30 × 10^-9, 1.30 × 10^-7] → log range: [-8.886, -6.886]
log_gamma_AE = log_uniform(n_samples, -8.886, -6.886);

%% Growth, inhibitions and killings of S. epidermidis
fprintf('[2/3] Sampling S. epidermidis parameters...\n');

% kappa_E: Growth rate of SE
% Range: [9, 27] → log range: [0.954, 1.431]
log_kappa_E = log_uniform(n_samples, 0.954, 1.431);

% E_max: Maximum SE population (constant)
% Value: 11.1 × 10^8 → log value: 9.045
E_max = repmat(11.1 * 10^8, n_samples, 1);

% gamma_EB: SE inhibition by barrier
% Range: [55.8, 5580] → log range: [1.747, 3.747]
log_gamma_EB = log_uniform(n_samples, 1.747, 3.747);

% delta_EA: SE killing by SA
% Range: [4.78, 478] → log range: [0.679, 2.679]
log_delta_EA = log_uniform(n_samples, 0.679, 2.679);

% E_th: SE threshold for barrier damage
% Range: [1.13 × 10^7, 1.11 × 10^9] → log range: [7.053, 9.045]
log_E_th = log_uniform(n_samples, 7.053, 9.045);

% A_pth: SA presence threshold for SE growth inhibition
% Range: [1.13 × 10^7, 1.11 × 10^9] → log range: [7.053, 9.045]
log_A_pth = log_uniform(n_samples, 7.053, 9.045);

%% Turnover and damage to barrier integrity
fprintf('[3/3] Sampling barrier parameters...\n');

% kappa_B: Barrier recovery rate
% Range: [7.11 × 10^-3, 0.711] → log range: [-2.148, -0.148]
log_kappa_B = log_uniform(n_samples, -2.148, -0.148);

% delta_B: Barrier degradation rate (baseline)
% Range: [2.89 × 10^-3, 0.289] → log range: [-2.539, -0.539]
log_delta_B = log_uniform(n_samples, -2.539, -0.539);

% delta_BA: Barrier damage by SA
% Range: [1.0 × 10^-10, 1.0 × 10^-8] → log range: [-10, -8]
log_delta_BA = log_uniform(n_samples, -10, -8);

% delta_BE: Barrier damage by SE
% Range: [1.0 × 10^-12, 1.0 × 10^-8] → log range: [-12, -8]
log_delta_BE = log_uniform(n_samples, -12, -8);

%% Combine all parameters into one matrix
fprintf('\nCombining parameters...\n');

% Column order matches Table S1:
% 1:  log_kappa_A    - SA growth rate (log)
% 2:  A_max          - SA max population (linear)
% 3:  log_gamma_AB   - SA inhibition by barrier (log)
% 4:  log_delta_AE   - SA killing by SE (log)
% 5:  log_A_th       - SA threshold for barrier damage (log)
% 6:  log_E_pth      - SE presence threshold (log)
% 7:  log_gamma_AE   - SA inhibition by SE (log)
% 8:  log_kappa_E    - SE growth rate (log)
% 9:  E_max          - SE max population (linear)
% 10: log_gamma_EB   - SE inhibition by barrier (log)
% 11: log_delta_EA   - SE killing by SA (log)
% 12: log_E_th       - SE threshold for barrier damage (log)
% 13: log_A_pth      - SA presence threshold (log)
% 14: log_kappa_B    - Barrier recovery rate (log)
% 15: log_delta_B    - Barrier degradation rate (log)
% 16: log_delta_BA   - Barrier damage by SA (log)
% 17: log_delta_BE   - Barrier damage by SE (log)

samples = [log_kappa_A, A_max, log_gamma_AB, log_delta_AE, log_A_th, ...
           log_E_pth, log_gamma_AE, log_kappa_E, E_max, log_gamma_EB, ...
           log_delta_EA, log_E_th, log_A_pth, log_kappa_B, log_delta_B, ...
           log_delta_BA, log_delta_BE];

fprintf('Parameter matrix size: %d × %d\n', size(samples, 1), size(samples, 2));

%% Save results
fprintf('\nSaving results...\n');

% Check if intermediate files should be saved (from main script)
if ~exist('save_intermediate_files', 'var')
    save_intermediate_files = true;  % Default: save everything (standalone mode)
end

if save_intermediate_files
    % Save as CSV (for compatibility and inspection)
    csv_filename = fullfile(data_folder, sprintf('SampledParameters_%s.csv', date_str));
    writematrix(samples, csv_filename);
    fprintf('  ✓ Saved CSV: %s\n', csv_filename);

    % Also save as MAT (for faster loading in MATLAB)
    mat_filename = fullfile(data_folder, sprintf('SampledParameters_%s.mat', date_str));
    save(mat_filename, 'samples', 'n_samples');
    fprintf('  ✓ Saved MAT: %s\n', mat_filename);
else
    fprintf('  ⊝ Intermediate files skipped (save_intermediate_files = false)\n');
end

% Always save latest version (needed by next scripts)
csv_latest = fullfile(data_folder, 'SampledParameters_latest.csv');
writematrix(samples, csv_latest);
fprintf('  ✓ Saved latest CSV: %s\n', csv_latest);

%% Display summary statistics
fprintf('\n=== Summary Statistics ===\n');
fprintf('Sample size: %d parameter sets\n', n_samples);
fprintf('Parameters: %d (15 sampled + 2 constants)\n', size(samples, 2));
fprintf('\nParameter ranges (log scale unless noted):\n');
fprintf('  SA parameters:\n');
fprintf('    log(kappa_A):  [%.3f, %.3f]\n', min(log_kappa_A), max(log_kappa_A));
fprintf('    A_max:         %.2e (constant, linear scale)\n', A_max(1));
fprintf('    log(gamma_AB): [%.3f, %.3f]\n', min(log_gamma_AB), max(log_gamma_AB));
fprintf('  SE parameters:\n');
fprintf('    log(kappa_E):  [%.3f, %.3f]\n', min(log_kappa_E), max(log_kappa_E));
fprintf('    E_max:         %.2e (constant, linear scale)\n', E_max(1));
fprintf('  Barrier parameters:\n');
fprintf('    log(kappa_B):  [%.3f, %.3f]\n', min(log_kappa_B), max(log_kappa_B));
fprintf('    log(delta_B):  [%.3f, %.3f]\n', min(log_delta_B), max(log_delta_B));

%% Completion message
fprintf('\n=== Parameter Sampling Complete ===\n');
fprintf('Total execution time: %.2f seconds\n', toc);
fprintf('\nNext step: Run a_SampledParameters.m to analyse steady states\n');

%% End of script