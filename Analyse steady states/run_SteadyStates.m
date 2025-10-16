% run_SteadyStates.m
%
% Main runner script for steady state analysis pipeline
% 
% This script orchestrates the complete workflow for generating and analyzing
% virtual patient parameter sets, computing steady states, and classifying
% patients into clinical categories.
%
% USAGE:
%   1. Modify the CONFIGURATION section below to set your parameters
%   2. Run this script in the terminal: matlab -batch "run('run_SteadyStates.m')"
%   3. Results will be saved in data/ folder
%
% OUTPUTS:
%   Primary output: data/AllVirtualPatientTypes_latest.csv
%   This file contains all virtual patients with classifications and is
%   used as input for all downstream analyses (violin plots, treatment
%   effects, etc.)
%
% Author: Jamie Lee
% Date: 6 October 2025
% Version: 2.2 - Removed figures_folder (no figures produced)

clc;
clear all;
close all;

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║       SA-SE Model - Steady State Analysis Pipeline     ║\n');
fprintf('║                                                        ║\n');
fprintf('║  Generates virtual patients and computes steady states ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

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

% Processing options
config.suppress_ode_warnings = true;   % Hide ODE solver warnings (cleaner output)
config.save_intermediate_files = false; % Save outputs from each step - disabled to reduce clutter

% Date stamp for output files
config.date_str = datestr(now, 'yyyy-mm-dd');

%% ═══════════════════════════════════════════════════════════════════════
%  SETUP - Create folders and display configuration
%  ═══════════════════════════════════════════════════════════════════════

fprintf('═══ Configuration ═══\n');
fprintf('Random seed:          %d\n', config.random_seed);
fprintf('Number of samples:    %d (%.0e)\n', config.n_samples, config.n_samples);
fprintf('Data folder:          %s/\n', config.data_folder);
fprintf('Date stamp:           %s\n', config.date_str);
fprintf('\n');

% Create output folders
if ~exist(config.data_folder, 'dir')
    mkdir(config.data_folder);
    fprintf('✓ Created data folder\n');
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

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 1/5: Generate Parameter Samples                      ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Set random seed
rng(config.random_seed, 'twister');
fprintf('→ Random seed set to: %d\n', config.random_seed);

% Call g_Samples.m with configuration
generate_parameter_samples(config);

fprintf('\n✓ Step 1 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 2: Compute Steady States
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 2/5: Compute Steady States                           ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call a_SampledParameters.m
compute_steady_states(config);

fprintf('\n✓ Step 2 complete (%.1f minutes)\n\n', toc(step_start)/60);

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 3: Assign Virtual Patient IDs
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 3/5: Assign Virtual Patient IDs                      ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call g_VirtualPatients.m
assign_patient_ids(config);

fprintf('\n✓ Step 3 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 4: Classify into Patient Groups
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 4/5: Classify Patient Groups                         ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call a_PatientGroups.m
classify_patient_groups(config);

fprintf('\n✓ Step 4 complete (%.1f seconds)\n\n', toc(step_start));

%% ═══════════════════════════════════════════════════════════════════════
%  STEP 5: Generate Classification CSV Files
%  ═══════════════════════════════════════════════════════════════════════

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 5/5: Generate Classification CSV Files               ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

step_start = tic;

% Call g_ClassificationFiles.m to create asymp.csv, reversible.csv, irreversible.csv
generate_classification_csvs(config);

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

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║                  PIPELINE COMPLETE                         ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

fprintf('═══ Summary ═══\n');
fprintf('Total execution time: %.1f minutes (%.2f hours)\n', total_time/60, total_time/3600);
fprintf('Random seed used:     %d\n', config.random_seed);
fprintf('Parameter sets:       %d\n', config.n_samples);
fprintf('\n');

fprintf('═══ Primary Output ═══\n');
fprintf('→ %s/AllVirtualPatientTypes_latest.csv\n', config.data_folder);
fprintf('\n');
fprintf('This file contains all virtual patients with clinical classifications.\n');
fprintf('Structure: 26 columns\n');
fprintf('  - Column 1:     Patient ID\n');
fprintf('  - Column 2:     Number of stable states\n');
fprintf('  - Columns 3-19:  Parameters (17 parameters)\n');
fprintf('  - Columns 20-22: Steady states (A*, E*, B*)\n');
fprintf('  - Columns 23-25: Eigenvalues (λ1, λ2, λ3)\n');
fprintf('  - Column 26:    Region (1-9)\n');
fprintf('\n');

fprintf('═══ Essential Output Files ═══\n');
fprintf('⭐ %s/AllVirtualPatientTypes_latest.csv (main dataset)\n', config.data_folder);
fprintf('⭐ %s/asymp.csv (asymptomatic patients)\n', config.data_folder);
fprintf('⭐ %s/reversible.csv (reversible patients)\n', config.data_folder);
fprintf('⭐ %s/irreversible.csv (irreversible patients)\n', config.data_folder);
fprintf('\n');

if config.save_intermediate_files
    fprintf('═══ Intermediate Files ═══\n');
    fprintf('  → %s/SampledParameters_latest.csv (17 cols)\n', config.data_folder);
    fprintf('  → %s/AllSteadyStates_latest.csv (23 cols)\n', config.data_folder);
    fprintf('  → %s/AllVirtualPatients_latest.csv (25 cols)\n', config.data_folder);
    fprintf('  → Timestamped versions with date suffixes\n');
    fprintf('\n');
else
    fprintf('═══ Storage Optimization ═══\n');
    fprintf('  ⊝ Intermediate files disabled (save_intermediate_files = false)\n');
    fprintf('  ⊝ Only essential outputs saved\n');
    fprintf('  ⊝ Reduced disk usage\n');
    fprintf('\n');
end

fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║                       DONE!                            ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n');

%% ═══════════════════════════════════════════════════════════════════════
%  HELPER FUNCTIONS - These call the actual analysis scripts
%  ═══════════════════════════════════════════════════════════════════════

function generate_parameter_samples(config)
    % Wrapper for g_samples.m
    
    fprintf('Generating %d parameter samples...\n', config.n_samples);
    fprintf('Using random seed: %d\n', config.random_seed);
    fprintf('(This calls g_samples.m)\n\n');
    
    % Set workspace variables that g_samples.m will use
    assignin('base', 'n_samples', config.n_samples);
    assignin('base', 'data_folder', config.data_folder);
    assignin('base', 'date_str', config.date_str);
    assignin('base', 'save_intermediate_files', config.save_intermediate_files);
    assignin('base', 'rng_initialized', true);  % Flag to prevent re-initialization
    
    % Run the script in base workspace
    evalin('base', 'run(''g_Samples.m'')');
end

function compute_steady_states(config)
    % Wrapper for a_SampledParameters.m
    
    fprintf('Computing steady states for all parameter sets...\n');
    fprintf('(This calls a_SampledParameters.m)\n');
    fprintf('⚠  This step may take several hours for 1 million samples\n\n');
    
    % Set workspace variables
    assignin('base', 'n_samples', config.n_samples);
    assignin('base', 'data_folder', config.data_folder);
    assignin('base', 'date_str', config.date_str);
    assignin('base', 'save_intermediate_files', config.save_intermediate_files);
    
    evalin('base', 'run(''a_SampledParameters.m'')');
end

function assign_patient_ids(config)
    % Wrapper for g_VirtualPatients.m
    
    fprintf('Assigning unique IDs to virtual patients...\n');
    fprintf('(This calls g_VirtualPatients.m)\n\n');
    
    % Set workspace variables
    assignin('base', 'data_folder', config.data_folder);
    assignin('base', 'date_str', config.date_str);
    assignin('base', 'save_intermediate_files', config.save_intermediate_files);
    
    evalin('base', 'run(''g_VirtualPatients.m'')');
end

function classify_patient_groups(config)
    % Wrapper for a_PatientGroups.m
    
    fprintf('Classifying patients into clinical groups...\n');
    fprintf('(This calls a_PatientGroups.m)\n\n');
    
    % Set workspace variables
    assignin('base', 'data_folder', config.data_folder);
    assignin('base', 'date_str', config.date_str);
    assignin('base', 'save_intermediate_files', config.save_intermediate_files);
    
    evalin('base', 'run(''a_PatientGroups.m'')');
end

function generate_classification_csvs(config)
    % Wrapper for g_ClassificationFiles.m
    
    fprintf('Generating classification CSV files...\n');
    fprintf('Creating: asymp.csv, reversible.csv, irreversible.csv\n');
    fprintf('(This calls g_ClassificationFiles.m)\n\n');
    
    % Run the classification script directly since it's in the same directory
    evalin('base', 'run(''g_ClassificationFiles.m'')');
    
    fprintf('  ✓ CSV files saved to: %s/\n', fullfile(pwd, config.data_folder));
end