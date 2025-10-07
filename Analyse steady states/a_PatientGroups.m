% a_PatientGroups.m
%
% Purpose: Classify virtual patients into 9 clinical categories
%          Based on steady state values (A*, E*, B*) and agr switch states
%          Categories defined in Supplementary Material "Mathematical analysis of steady states"
%
% Inputs:  data/AllVirtualPatients_latest.csv (from g_VirtualPatients.m)
% Outputs: data/AllVirtualPatientTypes_latest.csv
%          Contains: [Patient_ID, Num_States, Parameters(1-17), 
%                     Steady_States, Eigenvalues, Category(1-9)]
%
% Category definitions:
%   1: No bacteria (A*=0, E*=0), healthy barrier (B*=1)
%   2: Low SA, no SE, healthy barrier
%   3: No SA, low/high SE, healthy barrier  
%   4: Low SA, low SE, healthy barrier
%   5: No SA, high SE with agr, damaged barrier
%   6: Low SA, high SE with agr, may be damaged or healthy depending on SE strain (i.e., delta_BE)
%   7: High SA with agr, no SE, damaged barrier
%   8: High SA with agr, low SE, damaged barrier
%   9: High SA with agr, high SE with agr, damaged barrier
%
% Author: Jamie Lee
% Date: 6 October 2025
% Version: 2.0 - Improved clarity, added validation, visualization

clc;
% Don't clear all - keeps workspace variables from main script
% clear all;
close all;

fprintf('=== Patient Classification Script ===\n');
fprintf('Classifying virtual patients into clinical categories...\n\n');

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
fprintf('[1/4] Loading virtual patient data...\n');

input_file = fullfile(data_folder, 'AllVirtualPatients_latest.csv');

% Check if file exists
if ~exist(input_file, 'file')
    error('Input file not found: %s\nPlease run g_VirtualPatients.m first.', input_file);
end

AllVirtualPatients = readmatrix(input_file);

% Ensure data is real (remove any imaginary components if present)
AllVirtualPatients = real(AllVirtualPatients);

n_states = size(AllVirtualPatients, 1);
fprintf('  ✓ Loaded %d stable states\n', n_states);

%% Extract key parameters (constant across all patients)
fprintf('\n[2/4] Extracting system parameters...\n');

% Maximum population levels (same for all parameter sets)
A_max = AllVirtualPatients(1, 4);   % SA maximum population
E_max = AllVirtualPatients(1, 11);  % SE maximum population

fprintf('  ✓ A_max (SA): %.2e\n', A_max);
fprintf('  ✓ E_max (SE): %.2e\n', E_max);

%% Classify each state into categories
fprintf('\n[3/4] Classifying states into categories...\n');
fprintf('  (Based on 9 categories from Supplementary Figure S15)\n');

% Initialize category vector
category = zeros(n_states, 1);

% Track progress
last_progress = 0;

% Parallel loop for classification
parfor i = 1:n_states
    % Extract patient-specific parameters
    A_th     = AllVirtualPatients(i, 7);   % SA threshold for agr activation
    gamma_AE = AllVirtualPatients(i, 9);   % SA inhibition by SE
    E_th     = AllVirtualPatients(i, 14);  % SE threshold for agr activation
    
    % Extract steady state values
    A_star = AllVirtualPatients(i, 20);  % SA population at steady state
    E_star = AllVirtualPatients(i, 21);  % SE population at steady state
    B_star = AllVirtualPatients(i, 22);  % Barrier function at steady state
    
    %% Determine agr switch states
    % SE agr switch: ON if E* >= E_th
    if E_star >= E_th
        sw_E = 1;  % SE agr active
    else
        sw_E = 0;  % SE agr inactive
    end
    
    % SA agr switch: ON if A* >= A_th * (1 + gamma_AE * sw_E * E*)
    % (SA threshold increases when SE is present and active)
    SA_threshold = A_th * (1 + gamma_AE * sw_E * E_star);
    if A_star >= SA_threshold
        sw_A = 1;  % SA agr active
    else
        sw_A = 0;  % SA agr inactive
    end
    
    %% Classify into one of 9 categories
    % Each category represents a distinct clinical state
    
    % Category 1: Healthy skin, no bacteria
    % A*=0, E*=0, B*=1 (both agr switches OFF)
    if (A_star == 0) && (E_star == 0) && (B_star == 1) && ...
       (sw_A == 0) && (sw_E == 0)
        category(i) = 1;
    end
    
    % Category 2: Low SA colonization, healthy barrier
    % 0 < A* < A_th, E*=0, B*=1 (both agr switches OFF)
    if (A_star > 0) && (A_star < A_th) && (E_star == 0) && (B_star == 1) && ...
       (sw_A == 0) && (sw_E == 0)
        category(i) = 2;
    end
    
    % Category 3: No SA, SE present (low or high), healthy barrier
    % EITHER: A*=0, 0 < E* < E_th, B*=1 (sw_A = 0, sw_E = 0)
    % OR: A*=0, E_th <= E* <= E_max, B*=1 (sw_A = 0, sw_E = 1)
    if ((A_star == 0) && (E_star > 0) && (E_star < E_th) && (B_star == 1) && ...
        (sw_A == 0) && (sw_E == 0)) || ...
       ((A_star == 0) && (E_star >= E_th) && (E_star <= E_max) && ...
        (sw_A == 0) && (sw_E == 1) && (B_star == 1))
        category(i) = 3;
    end
    
    % Category 4: Both bacteria present at low levels, healthy barrier
    % 0 < A* < A_th, 0 < E* < E_th, B*=1 (both agr switches OFF)
    if (A_star > 0) && (A_star < A_th) && ...
       (E_star > 0) && (E_star < E_th) && ...
       (B_star == 1) && (sw_A == 0) && (sw_E == 0)
        category(i) = 4;
    end
    
    % Category 5: No SA, high SE with agr, damaged barrier
    % A*=0, E_th <= E* <= E_max, B* < 1 (sw_A = 0, sw_E = 1)
    if (A_star == 0) && (E_star >= E_th) && (E_star <= E_max) && ...
       (B_star < 1) && (sw_A == 0) && (sw_E == 1)
        category(i) = 5;
    end
    
    % Category 6: Low SA, high SE with agr, any barrier status
    % 0 < A* <= A_max, E_th <= E* <= E_max (sw_A = 0, sw_E = 1)
    % Note: No B* constraint - barrier can be healthy or damaged
    if (A_star > 0) && (A_star <= A_max) && ...
       (E_star >= E_th) && (E_star <= E_max) && ...
       (sw_A == 0) && (sw_E == 1)
        category(i) = 6;
    end
    
    % Category 7: High SA with agr, no SE
    % A_th <= A* <= A_max, E*=0 (SA agr ON, SE agr OFF)
    if (A_star >= A_th) && (A_star <= A_max) && (E_star == 0) && ...
       (sw_A == 1) && (sw_E == 0)
        category(i) = 7;
    end
    
    % Category 8: High SA with agr, low SE
    % A_th <= A* <= A_max, 0 < E* <= E_th (SA agr ON, SE agr OFF)
    if (A_star >= A_th) && (A_star <= A_max) && ...
       (E_star > 0) && (E_star <= E_th) && ...
       (sw_A == 1) && (sw_E == 0)
        category(i) = 8;
    end
    
    % Category 9: Both bacteria high with agr active
    % A_th <= A* <= A_max, E_th <= E* <= E_max (both agr switches ON)
    if (A_star >= A_th) && (A_star <= A_max) && ...
       (E_star >= E_th) && (E_star <= E_max) && ...
       (sw_A == 1) && (sw_E == 1)
        category(i) = 9;
    end
end

fprintf('  ✓ Classification complete\n');

%% Validate classification
fprintf('\nValidating classification...\n');

% Check for unclassified states
unclassified = sum(category == 0);
if unclassified > 0
    warning('%d states (%.1f%%) could not be classified!', ...
        unclassified, 100*unclassified/n_states);
    fprintf('  ⚠ These states don''t fit any category - investigate manually\n');
else
    fprintf('  ✓ All states successfully classified\n');
end

%% Build output matrix
fprintf('\n[4/4] Building output matrix...\n');

% Add category as final column (column 26)
AllVirtualPatientTypes = [AllVirtualPatients, category];

fprintf('  ✓ Output matrix size: %d rows × %d columns\n', ...
    size(AllVirtualPatientTypes, 1), size(AllVirtualPatientTypes, 2));

%% Save results
fprintf('\nSaving results...\n');

% Save as CSV (timestamped)
csv_filename = fullfile(data_folder, sprintf('AllVirtualPatientTypes_%s.csv', date_str));
writematrix(AllVirtualPatientTypes, csv_filename);
fprintf('  ✓ Saved CSV: %s\n', csv_filename);

% Save as MAT (faster for MATLAB)
mat_filename = fullfile(data_folder, sprintf('AllVirtualPatientTypes_%s.mat', date_str));
save(mat_filename, 'AllVirtualPatientTypes', 'category');
fprintf('  ✓ Saved MAT: %s\n', mat_filename);

% Save latest version (for easy reference by next scripts)
csv_latest = fullfile(data_folder, 'AllVirtualPatientTypes_latest.csv');
writematrix(AllVirtualPatientTypes, csv_latest);
fprintf('  ✓ Saved latest CSV: %s\n', csv_latest);

%% Category statistics and summary
fprintf('\n=== Category Distribution ===\n');

% Define category descriptions
category_names = {
    'Cat 1: No bacteria, healthy';
    'Cat 2: Low SA, healthy';
    'Cat 3: SE present, healthy';
    'Cat 4: Both low, healthy';
    'Cat 5: High SE agr, damaged';
    'Cat 6: Low SA + high SE agr, healthy';
    'Cat 7: High SA agr, no SE';
    'Cat 8: High SA agr + low SE';
    'Cat 9: Both high with agr'
};

% Count states in each category
for i = 1:9
    count = sum(category == i);
    pct = 100 * count / n_states;
    fprintf('  %s: %6d states (%.1f%%)\n', category_names{i}, count, pct);
end

if unclassified > 0
    fprintf('  Unclassified:                    %6d states (%.1f%%)\n', ...
        unclassified, 100*unclassified/n_states);
end

%% Summary
elapsed_time = toc;

fprintf('\n=== Patient Classification Complete ===\n');
fprintf('Total execution time: %.1f seconds\n', elapsed_time);
fprintf('\nOutput structure (26 columns):\n');
fprintf('  Col 1:     Patient ID\n');
fprintf('  Col 2:     Number of stable states\n');
fprintf('  Cols 3-19: Parameters (17 columns)\n');
fprintf('  Cols 20-22: Steady states (A*, E*, B*)\n');
fprintf('  Cols 23-25: Eigenvalues (λ1, λ2, λ3)\n');
fprintf('  Col 26:    Category (1-9)\n');
fprintf('\nNext step: Run g_ClassificationFiles.m to generate classification files\n');

%% End of script