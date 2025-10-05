% main_steady_states.m
%
% Main runner script for steady state analysis pipeline
% 
% This script orchestrates the complete workflow for generating and analyzing
% virtual patient parameter sets, computing steady states, and classifying
% patients into clinical categories.
%
% USAGE:
%   1. Modify the CONFIGURATION section below to set your parameters
%   2. Run this script: matlab -batch "run('main_steady_states.m')"
%   3. Results will be saved in data/ folder
%   4. Figures will be saved in figures/ folder
%
% OUTPUTS:
%   Primary output: data/AllVirtualPatientTypes_latest.csv
%   This file contains all virtual patients with classifications and is
%   used as input for all downstream analyses (violin plots, treatment
%   effects, etc.)
%
% Author: [Your name]
% Date: [Date]
% Version: 1.0

clc;
clear all;
close all;

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║       SASE Model - Steady State Analysis Pipeline          ║\n');
fprintf('║                                                            ║\n');
fprintf('║  Generates virtual patients and computes steady states     ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

%% ═══════════════════════════════════════════════════════════════════════
%  CONFIGURATION - Modify these parameters as needed
%  ═══════════════════════════════════════════════════════════════════════

% Random seed for reproducibility
% Change this value to generate a different set of virtual patients
% Use the same seed to reproduce exact results
config.random_seed = 0;  % Default: 0 (change to any integer)

% Number of parameter sets to sample
config.n_samples = 10^6;  % Default: 1 million
                          % For testing, try 10^4 (10,000)
                          % For publication, use 10^6

% Output folder names
config.data_folder = 'data';      % Where CSV/MAT files are saved
config.figures_folder = 'figures'; % Where plots are saved

% Processing options
config.suppress_ode_warnings = true;   % Hide ODE solver warnings (cleaner output)
config.save_intermediate_files = true; % Save outputs from each step
config.generate_figures = true;        % Create visualization plots

% Date stamp for output files
config.date_str = datestr(now, 'yyyy-mm-dd');

%% ═══════════════════════════════════════════════════════════════════════
%  SETUP - Create folders and display configuration
%  ═══════════════════════════════════════════════════════════════════════

fprintf('═══ Configuration ═══\n');
fprintf('Random seed:          %d\n', config.random_seed);
fprintf('Number of samples:    %d (%.0e)\n', config.n_samples, config.n_samples);
fprintf('Data folder:          %s/\n', config.data_folder);
fprintf('Figures folder:       %s/\n', config.figures_folder);
fprintf('Generate figures:     %s\n', mat2str(config.generate_figures));
fprintf('Date stamp:           %s\n', config.date_str);
fprintf('\n');

% Create output folders
if ~exist(config.data_folder, 'dir')
    mkdir(config.data_folder);
    fprintf('✓ Created data folder\n');
end
if ~exist(config.figures_folder, 'dir')
    mkdir(config.figures_folder);
    fprintf('✓ Created figures folder\n');
end

% Suppress ODE warnings if requested
if config.suppress_ode_warnings
    warning('off', 'MATLAB:ode45:IntegrationTolNotMet');
    warning('off', 'MATLAB:ode15s:IntegrationTolNotMet');
    fprintf('✓ ODE solver warnings suppressed\n');
end

fprintf('\n');

% Start overall timer
overall_start = tic;

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 1: Generate Parameter Samples
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 1/5: Generate Parameter Samples                      ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Set random seed
rng(config.random_seed, 'twister');
fprintf('→ Random seed set to: %d\n', config.random_seed);

% Call g_samples.m with configuration
% Note: We'll need to pass config to g_samples or modify it to use workspace vars
generate_parameter_samples(config);

fprintf('\n✓ Step 1 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 2: Compute Steady States
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 2/5: Compute Steady States                           ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call a_SampledParameters.m
compute_steady_states(config);

fprintf('\n✓ Step 2 complete (%.1f minutes)\n\n', toc(step_start)/60);

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 3: Assign Virtual Patient IDs
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 3/5: Assign Virtual Patient IDs                      ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call g_VirtualPatients.m
assign_patient_ids(config);

fprintf('\n✓ Step 3 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 4: Classify into Patient Groups
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 4/5: Classify Patient Groups                         ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call a_PatientGroups.m
classify_patient_groups(config);

fprintf('\n✓ Step 4 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 5: Generate Classification Files
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 5/5: Generate Classification Files                   ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call g_ClassificationFiles.m
generate_classification_files(config);

fprintf('\n✓ Step 5 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  COMPLETION - Summary and next steps
%  ═══════════════════════════════════════════════════════════════════════

% Re-enable warnings
if config.suppress_ode_warnings
    warning('on', 'MATLAB:ode45:IntegrationTolNotMet');
    warning('on', 'MATLAB:ode15s:IntegrationTolNotMet');
end

total_time = toc(overall_start);

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║                  PIPELINE COMPLETE                         ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

fprintf('═══ Summary ═══\n');
fprintf('Total execution time: %.1f minutes (%.2f hours)\n', total_time/60, total_time/3600);
fprintf('Random seed used:     %d\n', config.random_seed);
fprintf('Parameter sets:       %d\n', config.n_samples);
fprintf('\n');

fprintf('═══ Output Files ═══\n');
fprintf('Primary output (use this for downstream analysis):\n');
fprintf('  → %s/AllVirtualPatientTypes_latest.csv\n', config.data_folder);
fprintf('\n');
fprintf('Classification files (for violin plots):\n');
fprintf('  → %s/asymp.csv (asymptomatic patients)\n', config.data_folder);
fprintf('  → %s/rev_SAkilling.csv (reversible patients)\n', config.data_folder);
fprintf('  → %s/irrev_SAkilling.csv (irreversible patients)\n', config.data_folder);
fprintf('\n');

if config.save_intermediate_files
    fprintf('Intermediate files:\n');
    fprintf('  → %s/SampledParameters_latest.csv\n', config.data_folder);
    fprintf('  → %s/AllSteadyStates_latest.csv\n', config.data_folder);
    fprintf('  → %s/AllVirtualPatients_latest.csv\n', config.data_folder);
    fprintf('\n');
end

if config.generate_figures
    fprintf('Figures:\n');
    fprintf('  → %s/parameter_distributions_%s.png\n', config.figures_folder, config.date_str);
    fprintf('  → %s/steady_state_analysis_%s.png\n', config.figures_folder, config.date_str);
    fprintf('  → %s/classification_summary_%s.png\n', config.figures_folder, config.date_str);
    fprintf('\n');
end

fprintf('═══ Next Steps ═══\n');
fprintf('The primary output file contains all virtual patient data.\n');
fprintf('You can now:\n');
fprintf('  1. Generate violin plots (Folder 7)\n');
fprintf('  2. Analyze SA-killing effects (Folder 2)\n');
fprintf('  3. Analyze dual-action treatment (Folder 3)\n');
fprintf('  4. Perform custom analyses on AllVirtualPatientTypes_latest.csv\n');
fprintf('\n');

fprintf('To reproduce these exact results, use random seed: %d\n', config.random_seed);
fprintf('To generate a different patient population, change the random seed in the\n');
fprintf('CONFIGURATION section and re-run this script.\n');
fprintf('\n');

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║                       DONE!                                ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');

%% ═══════════════════════════════════════════════════════════════════════
%  HELPER FUNCTIONS - These call the actual analysis scripts
%  ═══════════════════════════════════════════════════════════════════════

function generate_parameter_samples(config)
    % Wrapper for g_samples.m
    % This ensures g_samples uses the configuration from main script
    
    % We need to modify g_samples.m slightly to accept workspace variables
    % For now, we'll call it and trust it uses the right config
    % Alternative: copy the core logic here
    
    fprintf('Generating %d parameter samples...\n', config.n_samples);
    fprintf('(This calls g_samples.m)\n\n');
    
    % Set the variables that g_samples.m expects
    n_samples = config.n_samples;
    data_folder = config.data_folder;
    figures_folder = config.figures_folder;
    date_str = config.date_str;
    
    % Call the script (it will use variables from workspace)
    run('g_samples.m');
end

function compute_steady_states(config)
    % Wrapper for a_SampledParameters.m
    
    fprintf('Computing steady states for all parameter sets...\n');
    fprintf('(This calls a_SampledParameters.m)\n');
    fprintf('⚠ This step may take several hours for 1 million samples\n\n');
    
    % Set workspace variables
    data_folder = config.data_folder;
    figures_folder = config.figures_folder;
    date_str = config.date_str;
    
    run('a_SampledParameters.m');
end

function assign_patient_ids(config)
    % Wrapper for g_VirtualPatients.m
    
    fprintf('Assigning unique IDs to virtual patients...\n');
    fprintf('(This calls g_VirtualPatients.m)\n\n');
    
    % Set workspace variables
    data_folder = config.data_folder;
    figures_folder = config.figures_folder;
    date_str = config.date_str;
    
    % Note: You'll need to update g_VirtualPatients.m to use data_folder
    run('g_VirtualPatients.m');
end

function classify_patient_groups(config)
    % Wrapper for a_PatientGroups.m
    
    fprintf('Classifying patients into clinical groups...\n');
    fprintf('(This calls a_PatientGroups.m)\n\n');
    
    % Set workspace variables
    data_folder = config.data_folder;
    figures_folder = config.figures_folder;
    date_str = config.date_str;
    
    % Note: You'll need to update a_PatientGroups.m to use data_folder
    run('a_PatientGroups.m');
end

function generate_classification_files(config)
    % Wrapper for g_ClassificationFiles.m
    
    fprintf('Generating classification files for downstream analysis...\n');
    fprintf('(This calls g_ClassificationFiles.m)\n\n');
    
    % Set workspace variables
    data_folder = config.data_folder;
    figures_folder = config.figures_folder;
    date_str = config.date_str;
    
    % Note: You'll need to update g_ClassificationFiles.m to use data_folder
    run('g_ClassificationFiles.m');
end