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

% Random seed - set by main script or user
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

%% Parameter sampling - ranges defined in Table 1 of Supplementary Note S2
% All parameters are sampled from a log uniform distribution
% Vectors describe lower and upper bounds of parameters

fprintf('Sampling parameters using original methodology...\n\n');

%% growth, inhibitions and killing of S. aureus: ________________________
%kappa_A         = [9, 27]
%log(kappa_A)    = [0.954, 1.431]
log_kappa_A = (1.431 - 0.954).*rand(n_samples,1) + 0.954;

%A_max           = 11.1*10^8;
%log(A_max)      = 9.045;
A_max = repelem(11.1*10^8, n_samples);
A_max = A_max.';

%gamma_AB        = [587*10^(-1), 587*10]      
%log(gamma_AB)   = [1.769, 3.769]
log_gamma_AB = (3.769 - 1.769).*rand(n_samples,1) + 1.769;

%delta_AE        = [478*10^(-2), 478]          
%log(delta_AE)   = [0.679, 2.679]
log_delta_AE = (2.679 - 0.679).*rand(n_samples,1) + 0.679;

%A_th            = [1.13*10^(-1), 11.1]*10^8    
%log(A_th)       = [7.053, 9.045]
log_A_th = (9.045 - 7.053).*rand(n_samples,1) + 7.053;

%E_pth           = [1.13*10^(-1), 11.1]*10^8    
%log(E_pth)      = [7.053, 9.045]
log_E_pth = (9.045 - 7.053).*rand(n_samples,1) + 7.053;

%gamma_AE        = [1.30*10^(-1), 1.30*10]*10^(-8)                  
%log(gamma_AE)   = [-8.886, -6.886]
log_gamma_AE = (-6.886 - (-8.886)).*rand(n_samples,1) -8.886;

%% growth, inhibitions and killings of S. epidermidis: ___________________
%kappa_E         = [9, 27]
%log(kappa_E)    = [0.954, 1.431]
log_kappa_E = (1.431 - 0.954).*rand(n_samples,1) + 0.954;

%E_max           = 11.1*10^8;
%log(E_max)      = 9.045;
E_max = repelem(11.1*10^8, n_samples);
E_max = E_max.';

%gamma_EB        = [558*10^(-1), 558*10]   
%log(gamma_EB)   = [1.747, 3.747]
log_gamma_EB = (3.747 - 1.747).*rand(n_samples,1) + 1.747;

%delta_EA        = [478*10^(-2), 478]
%log(delta_EA)   = [0.679, 2.679]
log_delta_EA = (2.679 - 0.679).*rand(n_samples,1) + 0.679;

%E_th            = [1.13*10^(-1), 11.1]*10^8   
%log(E_th)       = [7.053, 9.045]
log_E_th = (9.045 - 7.053).*rand(n_samples,1) + 7.053;

%A_pth           = [1.13*10^(-1), 11.1]*10^8  
%log(A_pth)      = [7.053, 9.045]
log_A_pth = (9.045 - 7.053).*rand(n_samples,1) + 7.053;

%% turnover and damage to barrier integrity: _____________________________
%kappa_B         = [0.0711*10^(-1), 0.0711*10]
%log(kappa_B)    = [-2.148, -0.148]
log_kappa_B = (-0.148 - (-2.148)).*rand(n_samples,1) -2.148;

%delta_B         = [0.0289*10^(-1), 0.0289*10]
%log(delta_B)    = [-2.539, -0.539]
log_delta_B = (-0.539 - (-2.539)).*rand(n_samples,1) -2.539;

%delta_BA        = [0.1*10^(-1), 0.1*10]*10^(-8)
%log(delta_BA)   = [-10, -8]
log_delta_BA = (-8 - (-10)).*rand(n_samples,1) -10;

%delta_BE        = [0, 0.1*10]*10^(-8)
%log(delta_BE)   = [-12, -8]
log_delta_BE = (-8 - (-12)).*rand(n_samples,1) -12;

% combine parameter samples in one giant matrix
samples = [log_kappa_A, A_max, log_gamma_AB, log_delta_AE, log_A_th, log_E_pth, ...
    log_gamma_AE, log_kappa_E, E_max, log_gamma_EB, log_delta_EA, log_E_th, ...
    log_A_pth, log_kappa_B, log_delta_B, log_delta_BA, log_delta_BE];

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