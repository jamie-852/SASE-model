% g_ClassificationFiles.m
% 
% Purpose: Generate classification files for violin plots
%          Separates virtual patients into three categories based on their
%          stable states and barrier function (B*) values
%
% Input:  data/AllVirtualPatientTypes_latest.csv - 26 columns
%         Col 1: Patient ID
%         Col 2: Number of stable states
%         Cols 3-19: Parameters (17 columns)
%         Cols 20-22: Steady states (A*, E*, B*)
%         Cols 23-25: Eigenvalues (λ1, λ2, λ3)
%         Col 26: Category (1-9)
%
% Output: Three CSV files in data/ folder for violin plot generation:
%         - asymp.csv: Patients with ONLY B*=1 (asymptomatic)
%         - reversible.csv: Patients with B*=1 AND B*<1 (reversible)
%         - irreversible.csv: Patients with ONLY B*<1 (irreversible)
%
% Author: Jamie Lee
% Date: 6 October 2025
% Version: 2.0 - Updated for data/ folder structure

clc;
% Don't clear all - keeps workspace variables from main script
% clear all;
close all;

fprintf('=== Classification File Generator ===\n');
fprintf('Loading virtual patient data...\n\n');

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

%% Load data from data folder
input_file = fullfile(data_folder, 'AllVirtualPatientTypes_latest.csv');

if ~exist(input_file, 'file')
    % Try .mat file if CSV doesn't exist
    input_file_mat = fullfile(data_folder, 'AllVirtualPatientTypes_latest.mat');
    if exist(input_file_mat, 'file')
        data = load(input_file_mat);
        % Extract the data array
        fieldnames_list = fieldnames(data);
        all_data = data.(fieldnames_list{1});
        fprintf('  ✓ Loaded from MAT file\n');
    else
        error('Could not find AllVirtualPatientTypes_latest.csv or .mat in %s/ folder\nPlease run a_PatientGroups.m first.', data_folder);
    end
else
    all_data = readmatrix(input_file);
    fprintf('  ✓ Loaded from CSV file\n');
end

n_states = size(all_data, 1);
n_unique_patients = length(unique(all_data(:, 1)));

fprintf('  ✓ Total states: %d\n', n_states);
fprintf('  ✓ Unique patients: %d\n', n_unique_patients);
fprintf('  ✓ Input file: %s\n', input_file);

%% Extract relevant columns
% Column 1: Patient ID
% Column 22: B* (barrier function steady state)
% Column 26: Category (not used for this classification, but available)

site_ids = all_data(:, 1);
B_star = all_data(:, 22);

% Precision threshold for comparing B* to 1.0
% Adjust this threshold based on your numerical precision
B_threshold = 1e-6;  % B* is considered 1.0 if abs(B* - 1) < threshold

fprintf('\n  Using B* threshold: %.0e\n', B_threshold);
fprintf('  (B* is "healthy" if |B* - 1.0| < %.0e)\n', B_threshold);

%% Group by virtual patient site ID
unique_sites = unique(site_ids);
n_sites = length(unique_sites);

fprintf('\n=== Classifying Virtual Patients ===\n');
fprintf('Processing %d unique virtual skin sites...\n', n_sites);

% Initialize storage for each category
asymp_sites = [];
rev_sites = [];
irrev_sites = [];

% Classification counters
n_asymp = 0;
n_rev = 0;
n_irrev = 0;

%% Classify each virtual patient
for i = 1:n_sites
    % Get all rows (stable states) for this patient
    site_mask = site_ids == unique_sites(i);
    site_data = all_data(site_mask, :);
    site_B_values = B_star(site_mask);
    
    % Check for healthy (B* ≈ 1) and damaged (B* < 1) states
    has_healthy = any(abs(site_B_values - 1.0) < B_threshold);
    has_damaged = any(site_B_values < (1.0 - B_threshold));
    
    % Classify based on stable states
    if has_healthy && ~has_damaged
        % Asymptomatic: Only healthy states (B* = 1)
        asymp_sites = [asymp_sites; site_data];
        n_asymp = n_asymp + 1;
        
    elseif has_healthy && has_damaged
        % Reversible: Both healthy and damaged states
        rev_sites = [rev_sites; site_data];
        n_rev = n_rev + 1;
        
    elseif ~has_healthy && has_damaged
        % Irreversible: Only damaged states (B* < 1)
        irrev_sites = [irrev_sites; site_data];
        n_irrev = n_irrev + 1;
        
    else
        % Edge case: no clear classification (shouldn't happen)
        warning('Patient %d has no clear classification', unique_sites(i));
    end
end

fprintf('  ✓ Classification complete\n');

%% Display classification summary
fprintf('\n=== Classification Summary ===\n');
fprintf('Asymptomatic (only B*=1):      %6d patients (%5.1f%%)\n', ...
    n_asymp, 100*n_asymp/n_sites);
fprintf('Reversible (B*=1 and B*<1):    %6d patients (%5.1f%%)\n', ...
    n_rev, 100*n_rev/n_sites);
fprintf('Irreversible (only B*<1):      %6d patients (%5.1f%%)\n', ...
    n_irrev, 100*n_irrev/n_sites);
fprintf('                               -------\n');
fprintf('Total:                         %6d patients\n', n_sites);

%% Save classification files
fprintf('\n=== Saving Classification Files ===\n');

% Save asymptomatic
if ~isempty(asymp_sites)
    output_file = fullfile(data_folder, 'asymp.csv');
    writematrix(asymp_sites, output_file);
    fprintf('  ✓ Saved %s ⭐ ESSENTIAL OUTPUT\n', output_file);
    fprintf('    %d rows (%d patients)\n', size(asymp_sites, 1), n_asymp);
else
    warning('No asymptomatic sites found');
end

% Save reversible
if ~isempty(rev_sites)
    output_file = fullfile(data_folder, 'reversible.csv');
    writematrix(rev_sites, output_file);
    fprintf('  ✓ Saved %s ⭐ ESSENTIAL OUTPUT\n', output_file);
    fprintf('    %d rows (%d patients)\n', size(rev_sites, 1), n_rev);
else
    warning('No reversible sites found');
end

% Save irreversible
if ~isempty(irrev_sites)
    output_file = fullfile(data_folder, 'irreversible.csv');
    writematrix(irrev_sites, output_file);
    fprintf('  ✓ Saved %s ⭐ ESSENTIAL OUTPUT\n', output_file);
    fprintf('  ✓ Saved %s\n', output_file);
    fprintf('    %d rows (%d patients)\n', size(irrev_sites, 1), n_irrev);
else
    warning('No irreversible sites found');
end

%% Summary
fprintf('\n=== Classification Complete ===\n');
fprintf('All files saved to %s/ folder\n', data_folder);
fprintf('\nOutput files:\n');
fprintf('  - asymp.csv (%d patients, %d states)\n', n_asymp, size(asymp_sites, 1));
fprintf('  - reversible.csv (%d patients, %d states)\n', n_rev, size(rev_sites, 1));
fprintf('  - irreversible.csv (%d patients, %d states)\n', n_irrev, size(irrev_sites, 1));
fprintf('\nThese files are ready for violin plot generation.\n');
fprintf('Each file contains all stable states for patients in that category.\n');

%% End of script