% g_ExtractInitialConditions.m
%
% Purpose: Extract initial conditions for SA-killing treatment simulations
%          Selects ONE "worst-case" damaging state per patient
%
% Selection Priority:
%   1. Regions 7/8/9 (SA-driven damage) - pick state with smallest B*
%   2. Regions 5/6 (SE-driven damage) - pick state with smallest B*
%
% Inputs:  ../Analyse steady states/data/reversible.csv and irreversible.csv
% Outputs: data/reversible_SAkilling.csv and irreversible_SAkilling.csv
%
% Author: Jamie Lee
% Date: 10 October 2025

function g_ExtractInitialConditions()
    
    clc;
    fprintf('=== Extracting Initial Conditions for SA-Killing Simulations ===\n\n');
    
    %% Setup paths
    % Input files from Analyse steady states/data/
    input_folder = '../Analyse steady states/data';
    reversible_file = fullfile(input_folder, 'reversible.csv');
    irreversible_file = fullfile(input_folder, 'irreversible.csv');
    
    % Output files to local data/ folder
    output_folder = 'data';
    reversible_output = fullfile(output_folder, 'reversible_SAkilling.csv');
    irreversible_output = fullfile(output_folder, 'irreversible_SAkilling.csv');
    
    %% Check if input files exist
    if ~exist(reversible_file, 'file')
        error('Cannot find %s\nPlease run g_ClassificationFiles.m first', reversible_file);
    end
    if ~exist(irreversible_file, 'file')
        error('Cannot find %s\nPlease run g_ClassificationFiles.m first', irreversible_file);
    end
    
    %% Process reversible patients
    fprintf('[1/2] Processing reversible patients...\n');
    reversible_data = readmatrix(reversible_file);
    reversible_initial = extract_worst_case_states(reversible_data);
    
    % Create output folder (mkdir won't error if it already exists)
    mkdir(output_folder);
    
    writematrix(reversible_initial, reversible_output);
    fprintf('  ✓ Saved %s (%d patients)\n', reversible_output, size(reversible_initial, 1));
    
    %% Process irreversible patients
    fprintf('\n[2/2] Processing irreversible patients...\n');
    irreversible_data = readmatrix(irreversible_file);
    irreversible_initial = extract_worst_case_states(irreversible_data);
    
    % Create output folder (mkdir won't error if it already exists)
    mkdir(output_folder);
    
    writematrix(irreversible_initial, irreversible_output);
    fprintf('  ✓ Saved %s (%d patients)\n', irreversible_output, size(irreversible_initial, 1));
    
    %% Summary
    fprintf('\n=== Extraction Complete ===\n');
    fprintf('Initial conditions ready for treatment simulations:\n');
    fprintf('  - Reversible: %d patients\n', size(reversible_initial, 1));
    fprintf('  - Irreversible: %d patients\n', size(irreversible_initial, 1));
    fprintf('  - Total: %d patients\n\n', size(reversible_initial, 1) + size(irreversible_initial, 1));
    
end

%% Helper function to extract worst-case initial conditions
function initial_conditions = extract_worst_case_states(patient_data)
    % Extract one initial condition per patient using priority rules
    %
    % Priority:
    %   1. Regions 7/8/9 (SA-driven) → pick smallest B*
    %   2. Regions 5/6 (SE-driven) → pick smallest B*
    
    % Get unique patient IDs (column 1)
    patient_ids = unique(patient_data(:, 1));
    n_patients = length(patient_ids);
    
    fprintf('  Found %d unique patients\n', n_patients);
    
    % Preallocate output
    initial_conditions = zeros(n_patients, size(patient_data, 2));
    
    % Process each patient
    for i = 1:n_patients
        patient_id = patient_ids(i);
        
        % Get all steady states for this patient
        patient_rows = patient_data(patient_data(:, 1) == patient_id, :);
        
        % Get regions (column 26) and B* values (column 22)
        regions = patient_rows(:, 26);
        B_stars = patient_rows(:, 22);
        
        % Priority 1: Look for SA-driven states (Regions 7, 8, 9)
        sa_driven_mask = (regions == 7) | (regions == 8) | (regions == 9);
        
        if any(sa_driven_mask)
            % SA-driven states exist - pick one with smallest B*
            sa_driven_rows = patient_rows(sa_driven_mask, :);
            sa_driven_B = B_stars(sa_driven_mask);
            
            [~, idx] = min(sa_driven_B);
            initial_conditions(i, :) = sa_driven_rows(idx, :);
            continue;
        end
        
        % Priority 2: Look for SE-driven states (Regions 5, 6)
        se_driven_mask = (regions == 5) | (regions == 6);
        
        if any(se_driven_mask)
            % SE-driven states exist - pick one with smallest B*
            se_driven_rows = patient_rows(se_driven_mask, :);
            se_driven_B = B_stars(se_driven_mask);
            
            [~, idx] = min(se_driven_B);
            initial_conditions(i, :) = se_driven_rows(idx, :);
            continue;
        end
        
        % Fallback (shouldn't happen for reversible/irreversible)
        % Just pick state with smallest B*
        [~, idx] = min(B_stars);
        initial_conditions(i, :) = patient_rows(idx, :);
        
        fprintf('  Warning: Patient %d has no regions 5-9 (unusual)\n', patient_id);
    end
    
    % Summary of region distribution
    selected_regions = initial_conditions(:, 26);
    fprintf('  Selected initial conditions by region:\n');
    for region = [5, 6, 7, 8, 9]
        count = sum(selected_regions == region);
        if count > 0
            fprintf('    Region %d: %d patients (%.1f%%)\n', ...
                region, count, 100*count/n_patients);
        end
    end
    
end