% g_ExtractInitialConditions.m
%
% Purpose: Extract initial conditions for SA-killing treatment simulations
%          Selects ONE "worst-case" damaging state per patient
%
% Selection Priority:
%   1. Regions 7/8/9 (SA-driven damage) - pick state with smallest B*
%   2. Regions 5/6 (SE-driven damage) - pick state with smallest B*
%
% DEFAULT USAGE (for regular SA-killing workflow):
%   g_ExtractInitialConditions()
%   Inputs:  ../Analyse steady states/data/reversible.csv and irreversible.csv
%   Outputs: data/reversible_SAkilling.csv and irreversible_SAkilling.csv
%
% CUSTOM USAGE (for dual-action workflow):
%   g_ExtractInitialConditions(input_folder, output_folder, file_suffix)
%   Example: g_ExtractInitialConditions('../Effect of dual-action treatment/data', ...
%                                       '../Effect of dual-action treatment/data', ...
%                                       'attenuation_reversible_20x.csv', ...
%                                       'attenuation_irreversible_20x.csv', ...
%                                       'dual_action_reversible_20x_initial.csv', ...
%                                       'dual_action_irreversible_20x_initial.csv')
%
% Author: Jamie Lee
% Date: 13 October 2025
% Version: 3.0 - Made flexible for dual-action workflow

function g_ExtractInitialConditions(input_folder, output_folder, ...
                                     reversible_input_name, irreversible_input_name, ...
                                     reversible_output_name, irreversible_output_name)
    
    clc;
    fprintf('=== Extracting Initial Conditions for SA-Killing Simulations ===\n\n');
    
    %% Handle default parameters (regular workflow)
    if nargin == 0
        % Default: regular SA-killing workflow
        input_folder = '../Analyse steady states/data';
        output_folder = 'data';
        reversible_input_name = 'reversible.csv';
        irreversible_input_name = 'irreversible.csv';
        reversible_output_name = 'reversible_SAkilling.csv';
        irreversible_output_name = 'irreversible_SAkilling.csv';
        
        fprintf('Mode: Regular SA-killing workflow\n');
    else
        fprintf('Mode: Custom input/output paths\n');
    end
    
    fprintf('Input folder: %s\n', input_folder);
    fprintf('Output folder: %s\n\n', output_folder);
    
    %% Setup full paths
    reversible_file = fullfile(input_folder, reversible_input_name);
    irreversible_file = fullfile(input_folder, irreversible_input_name);
    reversible_output = fullfile(output_folder, reversible_output_name);
    irreversible_output = fullfile(output_folder, irreversible_output_name);
    
    %% Check if input files exist
    if ~exist(reversible_file, 'file')
        error('Cannot find %s\nPlease check input paths', reversible_file);
    end
    if ~exist(irreversible_file, 'file')
        error('Cannot find %s\nPlease check input paths', irreversible_file);
    end
    
    %% Process reversible patients
    fprintf('[1/2] Processing reversible patients...\n');
    fprintf('  Input: %s\n', reversible_file);
    reversible_data = readmatrix(reversible_file);
    
    % Filter for damaged states only (B* < 1) if needed
    reversible_damaged = reversible_data(reversible_data(:, 22) < 1, :);
    
    if isempty(reversible_damaged)
        fprintf('  ⚠️  No damaged states found (all have B* = 1)\n');
        reversible_initial = [];
    else
        reversible_initial = extract_worst_case_states(reversible_damaged);
    end
    
    % Create output folder
    mkdir(output_folder);
    
    writematrix(reversible_initial, reversible_output);
    fprintf('  ✓ Saved %s (%d patients)\n', reversible_output, size(reversible_initial, 1));
    
    %% Process irreversible patients
    fprintf('\n[2/2] Processing irreversible patients...\n');
    fprintf('  Input: %s\n', irreversible_file);
    irreversible_data = readmatrix(irreversible_file);
    
    % Filter for damaged states only (B* < 1) if needed
    irreversible_damaged = irreversible_data(irreversible_data(:, 22) < 1, :);
    
    if isempty(irreversible_damaged)
        fprintf('  ⚠️  No damaged states found (all have B* = 1)\n');
        irreversible_initial = [];
    else
        irreversible_initial = extract_worst_case_states(irreversible_damaged);
    end
    
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