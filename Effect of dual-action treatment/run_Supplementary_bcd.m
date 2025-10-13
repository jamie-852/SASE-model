% run_Supplementary_bcd.m
%
% Purpose: Generate supplementary figure panels b, c, and d showing treatment
%          effectiveness across different gamma_AB and gamma_EB enhancement combinations
%
% This script:
%   1. Runs attenuation treatment simulations for 9 parameter combinations
%   2. Tests both irreversible and reversible patient populations
%   3. Generates heatmap visualizations showing % patients gaining healthy states
%   4. Saves results and figures for publication
%
% Parameter combinations tested:
%   gamma_AB (SA attenuation): 1x, 10x, 20x enhancement
%   gamma_EB (SE attenuation): 1x, 10x, 20x enhancement
%   Total: 9 combinations for each patient type
%
% Outputs:
%   - data/supplementary_results_irreversible.csv
%   - data/supplementary_results_reversible.csv  
%   - figures/supplementary_panel_b.png (all damaged sites)
%   - figures/supplementary_panel_c.png (irreversible sites)
%   - figures/supplementary_panel_d.png (reversible sites)
%
% Author: Jamie Lee
% Date: 13 October 2025

function run_Supplementary_bcd()
    
    clc;
    fprintf('=== Supplementary Figure b-d: Attenuation Treatment Matrix ===\n\n');
    
    %% Configuration
    gamma_AB_values = [1, 10, 20];  % SA attenuation enhancement levels
    gamma_EB_values = [1, 10, 20];  % SE attenuation enhancement levels  
    patient_types = {'irreversible', 'reversible'};
    
    % Ensure output directories exist
    if ~exist('data', 'dir')
        mkdir('data');
    end
    if ~exist('figures', 'dir')
        mkdir('figures');
    end
    
    fprintf('Parameter combinations to test:\n');
    fprintf('  gamma_AB enhancement: %s\n', mat2str(gamma_AB_values));
    fprintf('  gamma_EB enhancement: %s\n', mat2str(gamma_EB_values));
    fprintf('  Patient types: %s\n', strjoin(patient_types, ', '));
    fprintf('  Total simulations: %d\n\n', length(gamma_AB_values) * length(gamma_EB_values) * length(patient_types));
    
    %% Run simulations for each patient type
    results_irreversible = [];
    results_reversible = [];
    
    for p = 1:length(patient_types)
        patient_type = patient_types{p};
        fprintf('[Patient Type: %s]\n', upper(patient_type));
        
        % Initialize results matrix: [gamma_AB, gamma_EB, percentage]
        results_matrix = zeros(length(gamma_AB_values) * length(gamma_EB_values), 3);
        result_idx = 1;
        
        for i = 1:length(gamma_AB_values)
            for j = 1:length(gamma_EB_values)
                gamma_AB_fold = gamma_AB_values(i);
                gamma_EB_fold = gamma_EB_values(j);
                
                fprintf('  Simulation %d/%d: gamma_AB=%dx, gamma_EB=%dx\n', ...
                    result_idx, length(gamma_AB_values) * length(gamma_EB_values), ...
                    gamma_AB_fold, gamma_EB_fold);
                
                % Run modified attenuation simulation
                percentage = g_AttenuationOnly_Matrix(patient_type, gamma_AB_fold, gamma_EB_fold);
                
                % Store results
                results_matrix(result_idx, :) = [gamma_AB_fold, gamma_EB_fold, percentage];
                result_idx = result_idx + 1;
                
                fprintf('    → %.1f%% patients gained healthy states\n', percentage);
            end
        end
        
        % Store results for this patient type
        if strcmp(patient_type, 'irreversible')
            results_irreversible = results_matrix;
        else
            results_reversible = results_matrix;
        end
        
        % Save individual results
        results_file = sprintf('data/supplementary_results_%s.csv', patient_type);
        writematrix(results_matrix, results_file);
        fprintf('  ✓ Saved results: %s\n\n', results_file);
    end
    
    %% Generate combined results for "all damaged sites" (panel b)
    fprintf('[Generating Combined Results for Panel b]\n');
    
    % Load original patient data to get proportions
    irreversible_data = readmatrix('../Effect of SA-killing/data/irreversible_SAkilling.csv');
    reversible_data = readmatrix('../Effect of SA-killing/data/reversible_SAkilling.csv');
    
    n_irreversible = size(irreversible_data, 1);
    n_reversible = size(reversible_data, 1);
    n_total = n_irreversible + n_reversible;
    
    fprintf('  Total damaged sites: %d\n', n_total);
    fprintf('  Irreversible sites: %d (%.1f%%)\n', n_irreversible, n_irreversible/n_total*100);
    fprintf('  Reversible sites: %d (%.1f%%)\n', n_reversible, n_reversible/n_total*100);
    
    % Calculate weighted average for combined results
    results_combined = zeros(size(results_irreversible));
    for i = 1:size(results_irreversible, 1)
        % Weighted average based on population sizes
        combined_percentage = (results_irreversible(i, 3) * n_irreversible + ...
                               results_reversible(i, 3) * n_reversible) / n_total;
        results_combined(i, :) = [results_irreversible(i, 1:2), combined_percentage];
    end
    
    % Save combined results
    writematrix(results_combined, 'data/supplementary_results_combined.csv');
    fprintf('  ✓ Saved combined results: data/supplementary_results_combined.csv\n\n');
    
    %% Generate heatmap plots
    fprintf('[Generating Heatmap Visualizations]\n');
    
    % Create figure with subplots for all three panels
    fig = figure('Position', [100, 100, 1200, 400]);
    
    % Panel b: All damaged sites
    subplot(1, 3, 1);
    create_heatmap(results_combined, gamma_AB_values, gamma_EB_values, ...
        '% of damaged skin sites\nthat gain a non-damaged state', 'b');
    
    % Panel c: Irreversible sites  
    subplot(1, 3, 2);
    create_heatmap(results_irreversible, gamma_AB_values, gamma_EB_values, ...
        '% of irreversible sites\nthat gain a non-damaged state', 'c');
    
    % Panel d: Reversible sites
    subplot(1, 3, 3); 
    create_heatmap(results_reversible, gamma_AB_values, gamma_EB_values, ...
        '% of reversible sites\nthat gain a non-damaged state', 'd');
    
    % Save figure
    saveas(fig, 'figures/supplementary_panels_bcd.png');
    saveas(fig, 'figures/supplementary_panels_bcd.fig');
    fprintf('  ✓ Saved figure: figures/supplementary_panels_bcd.png\n');
    fprintf('  ✓ Saved figure: figures/supplementary_panels_bcd.fig\n\n');
    
    %% Summary
    fprintf('=== Summary ===\n');
    fprintf('Completed %d attenuation treatment simulations\n', ...
        length(gamma_AB_values) * length(gamma_EB_values) * length(patient_types));
    fprintf('\nTreatment effectiveness ranges:\n');
    fprintf('  All damaged sites: %.1f%% - %.1f%%\n', min(results_combined(:, 3)), max(results_combined(:, 3)));
    fprintf('  Irreversible sites: %.1f%% - %.1f%%\n', min(results_irreversible(:, 3)), max(results_irreversible(:, 3)));
    fprintf('  Reversible sites: %.1f%% - %.1f%%\n', min(results_reversible(:, 3)), max(results_reversible(:, 3)));
    
    fprintf('\nFiles generated:\n');
    fprintf('  → data/supplementary_results_*.csv (raw data)\n');
    fprintf('  → figures/supplementary_panels_bcd.png (publication figure)\n\n');
    
end

function create_heatmap(results_matrix, gamma_AB_values, gamma_EB_values, title_text, panel_label)
    % Create heatmap visualization matching the publication style
    
    % Reshape results into matrix format
    heatmap_data = zeros(length(gamma_EB_values), length(gamma_AB_values));
    for i = 1:size(results_matrix, 1)
        gamma_AB = results_matrix(i, 1);
        gamma_EB = results_matrix(i, 2);
        percentage = results_matrix(i, 3);
        
        % Find indices
        ab_idx = find(gamma_AB_values == gamma_AB);
        eb_idx = find(gamma_EB_values == gamma_EB);
        
        heatmap_data(eb_idx, ab_idx) = percentage;
    end
    
    % Create heatmap
    imagesc(heatmap_data);
    colormap(gray);
    
    % Flip colormap so darker = higher effectiveness
    colormap(flipud(gray));
    
    % Add percentage text on each cell
    for i = 1:size(heatmap_data, 1)
        for j = 1:size(heatmap_data, 2)
            text(j, i, sprintf('%.0f', heatmap_data(i, j)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 12, 'FontWeight', 'bold', ...
                'Color', 'white');
        end
    end
    
    % Customize axes
    set(gca, 'XTick', 1:length(gamma_AB_values));
    set(gca, 'XTickLabel', gamma_AB_values);
    set(gca, 'YTick', 1:length(gamma_EB_values));
    set(gca, 'YTickLabel', gamma_EB_values);
    
    % Labels and title
    xlabel('Strength of\nSA attenuation', 'FontSize', 12, 'Color', [0.2, 0.4, 0.8]);
    ylabel('Strength of\nSE attenuation', 'FontSize', 12, 'Color', [0.2, 0.4, 0.8]);
    title(title_text, 'FontSize', 10, 'FontWeight', 'normal');
    
    % Add panel label
    text(-0.15, 1.15, sprintf('\\bf%s', panel_label), ...
        'Units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Set aspect ratio and remove tick marks
    axis square;
    set(gca, 'TickLength', [0 0]);
    
end

function percentage = g_AttenuationOnly_Matrix(patient_type, gamma_AB_fold, gamma_EB_fold)
    % Modified version of g_AttenuationOnly that accepts separate fold changes
    % for gamma_AB and gamma_EB parameters
    
    %% Add path to helper functions (silently)
    helper_path = '../Analyse steady states';
    if exist(helper_path, 'dir')
        addpath(helper_path);
    else
        error('Cannot find helper functions folder: %s', helper_path);
    end
    
    %% Load input data (silently)
    if strcmp(patient_type, 'irreversible')
        input_file = '../Effect of SA-killing/data/irreversible_SAkilling.csv';
    elseif strcmp(patient_type, 'reversible')
        input_file = '../Effect of SA-killing/data/reversible_SAkilling.csv';
    else
        error('Invalid patient_type. Use ''irreversible'' or ''reversible''');
    end
    
    if ~exist(input_file, 'file')
        error('Cannot find %s', input_file);
    end
    
    skin_sites = readmatrix(input_file);
    n_patients = size(skin_sites, 1);
    
    %% Apply fold-change enhancements (separate for gamma_AB and gamma_EB)
    ParamSet = skin_sites(:, 3:19);
    n_param_sets = size(ParamSet, 1);
    
    % Pre-allocate cell array for parallel results
    SteadyStateCell = cell(n_param_sets, 1);
    
    parfor i = 1:n_param_sets
        % Extract parameters
        kappa_A  = ParamSet(i, 1);
        A_max    = ParamSet(i, 2);
        gamma_AB = gamma_AB_fold * ParamSet(i, 3);  % Enhanced by gamma_AB_fold
        delta_AE = ParamSet(i, 4);
        A_th     = ParamSet(i, 5);
        E_pth    = ParamSet(i, 6);
        gamma_AE = ParamSet(i, 7);
        kappa_E  = ParamSet(i, 8);
        E_max    = ParamSet(i, 9);
        gamma_EB = gamma_EB_fold * ParamSet(i, 10);  % Enhanced by gamma_EB_fold
        delta_EA = ParamSet(i, 11);
        E_th     = ParamSet(i, 12);
        A_pth    = ParamSet(i, 13);
        kappa_B  = ParamSet(i, 14);
        delta_B  = ParamSet(i, 15);
        delta_BA = ParamSet(i, 16);
        delta_BE = ParamSet(i, 17);
        
        VirtualPatient = [kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
            E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
            E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE];
        
        % Compute steady states for all 4 cases
        output_1 = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, kappa_E, ...
            E_max, gamma_EB, E_th, kappa_B, delta_B);
        
        output_2 = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, kappa_E, ...
            E_max, gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA);
        
        output_3 = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
            E_pth, kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B, delta_BE);
        
        output_4 = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, A_th, ...
            E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
            kappa_B, delta_B, delta_BA, delta_BE);
        
        % Process each case
        SteadyState_1 = real(output_1);
        SteadyState_1(~any(SteadyState_1, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_1, 1), 1);
        output_one = [Params, SteadyState_1];
        
        SteadyState_2 = output_2;
        SteadyState_2(~any(SteadyState_2, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_2, 1), 1);
        output_two = [Params, SteadyState_2];
        
        SteadyState_3 = real(output_3);
        SteadyState_3(~any(SteadyState_3, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_3, 1), 1);
        output_three = [Params, SteadyState_3];
        
        SteadyState_4 = real(output_4);
        SteadyState_4(~any(SteadyState_4, 2), :) = [];
        Params = repelem(VirtualPatient, size(SteadyState_4, 1), 1);
        output_four = [Params, SteadyState_4];
        
        % Combine all steady states for this patient
        SteadyStateCell{i} = [output_one; output_two; output_three; output_four];
    end
    
    % Concatenate all results after parallel loop
    AllSteadyStates = vertcat(SteadyStateCell{:});
    
    %% Filter for stable steady states
    AllStableStates = [];
    for j = 1:size(AllSteadyStates, 1)
        if (AllSteadyStates(j, 21) < 0 && AllSteadyStates(j, 22) < 0 && ...
            AllSteadyStates(j, 23) < 0)
            AllStableStates = [AllStableStates; AllSteadyStates(j, :)];
        end
    end
    
    %% Organize by patient and classify
    Param = AllStableStates(:, 1:17);
    [~, ~, ic] = unique(Param, 'rows', 'stable');
    count = accumarray(ic, 1);
    map = count(ic);
    
    numVirtualPatients = [ic, map, Param];
    AllVirtualPatients = [numVirtualPatients, AllStableStates(:, 18:23)];
    
    %% Classify patients (inline classification to avoid external dependencies)
    n_states = size(AllVirtualPatients, 1);
    A_max = AllVirtualPatients(1, 4);   
    E_max = AllVirtualPatients(1, 11);  
    
    category = zeros(n_states, 1);
    
    for i = 1:n_states
        A_th = AllVirtualPatients(i, 7);   
        E_th = AllVirtualPatients(i, 14);  
        
        A_star = AllVirtualPatients(i, 20); 
        E_star = AllVirtualPatients(i, 21); 
        B_star = AllVirtualPatients(i, 22); 
        
        sw_E = (E_star >= E_th) && (E_star <= E_max);
        sw_A = (A_star >= A_th) && (A_star <= A_max);
        
        % Classification logic
        if (A_star == 0) && (E_star == 0) && (B_star == 1) && (~sw_A) && (~sw_E)
            category(i) = 1; % Healthy, no bacteria
        elseif (A_star > 0) && (A_star < A_th) && (E_star == 0) && (B_star == 1) && (~sw_A) && (~sw_E)
            category(i) = 2; % Low SA, healthy
        elseif ((A_star == 0) && (E_star > 0) && (E_star < E_th) && (B_star == 1) && (~sw_A) && (~sw_E)) || ...
               ((A_star == 0) && (E_star >= E_th) && (E_star <= E_max) && (~sw_A) && sw_E && (B_star == 1))
            category(i) = 3; % SE present, healthy
        elseif (A_star > 0) && (A_star < A_th) && (E_star > 0) && (E_star < E_th) && (B_star == 1) && (~sw_A) && (~sw_E)
            category(i) = 4; % Both low, healthy
        elseif (A_star == 0) && (E_star >= E_th) && (E_star <= E_max) && (~sw_A) && sw_E && (B_star < 1)
            category(i) = 5; % High SE agr, damaged
        elseif (A_star > 0) && (A_star < A_th) && (E_star >= E_th) && (E_star <= E_max) && (~sw_A) && sw_E && (B_star == 1)
            category(i) = 6; % Low SA + high SE agr, healthy
        elseif (A_star >= A_th) && (A_star <= A_max) && (E_star == 0) && sw_A && (~sw_E) && (B_star < 1)
            category(i) = 7; % High SA agr, no SE
        elseif (A_star >= A_th) && (A_star <= A_max) && (E_star > 0) && (E_star < E_th) && sw_A && (~sw_E) && (B_star < 1)
            category(i) = 8; % High SA agr + low SE
        elseif (A_star >= A_th) && (A_star <= A_max) && (E_star >= E_th) && (E_star <= E_max) && sw_A && sw_E && (B_star < 1)
            category(i) = 9; % Both high agr
        end
    end
    
    AllVirtualPatientTypes = [AllVirtualPatients, category];
    
    %% Calculate treatment effectiveness
    % Count unique patients with at least one healthy state (categories 1-4)
    healthy_mask = (AllVirtualPatientTypes(:, end) == 1) | ...
                   (AllVirtualPatientTypes(:, end) == 2) | ...
                   (AllVirtualPatientTypes(:, end) == 3) | ...
                   (AllVirtualPatientTypes(:, end) == 4);
    unique_healthy_patients = length(unique(AllVirtualPatientTypes(healthy_mask, 1)));
    
    percentage = unique_healthy_patients / n_patients * 100;
    
end