% run_DualAction_Simplified.m
%
% Purpose: Simplified dual-action treatment pipeline that uses existing 
%          attenuation results and applies SA-killing treatment
%
% This script:
%   1. Reads existing attenuation results (attenuation_*_20x.csv)
%   2. Filters for damaged sites (regions 5-9) as initial conditions
%   3. Applies g_TreatmentResponse.m for SA-killing treatment
%   4. Generates treatment response heatmaps
%
% Author: Jamie Lee  
% Date: 14 October 2025
% Version: 1.0 - Simplified approach

function run_DualAction_Simplified()
    
    clc;
    fprintf('=== Simplified Dual-Action Treatment Pipeline ===\n\n');
    
    %% Configuration
    fold_change = 20;  % Attenuation fold change to use
    patient_types = {'reversible', 'irreversible'};
    
    % Create output directories
    if ~exist('data', 'dir'), mkdir('data'); end
    if ~exist('figures', 'dir'), mkdir('figures'); end
    
    %% Process each patient type
    for type_idx = 1:length(patient_types)
        patient_type = patient_types{type_idx};
        
        fprintf('=== Processing %s patients ===\n', patient_type);
        
        %% Step 1: Read attenuation results
        attenuation_file = sprintf('data/attenuation_%s_%dx.csv', patient_type, fold_change);
        
        if ~exist(attenuation_file, 'file')
            error('Cannot find %s\nPlease run g_AttenuationOnly(%s, %d) first', ...
                attenuation_file, patient_type, fold_change);
        end
        
        fprintf('[1/4] Reading attenuation results...\n');
        attenuation_data = readmatrix(attenuation_file);
        fprintf('  ✓ Loaded: %s (%d rows)\n', attenuation_file, size(attenuation_data, 1));
        
        %% Step 2: Analyze site damage status after attenuation
        fprintf('[2/4] Analyzing site damage status after attenuation...\n');
        
        % Column 26 contains the region classification
        region_col = 26;
        damaged_mask = (attenuation_data(:, region_col) >= 5) & (attenuation_data(:, region_col) <= 9);
        undamaged_mask = (attenuation_data(:, region_col) >= 1) & (attenuation_data(:, region_col) <= 4);
        
        damaged_sites = attenuation_data(damaged_mask, :);
        undamaged_sites = attenuation_data(undamaged_mask, :);
        
        fprintf('  Total sites: %d\n', size(attenuation_data, 1));
        fprintf('  Undamaged sites (regions 1-4): %d (%.1f%%) - already "treated"\n', ...
            size(undamaged_sites, 1), size(undamaged_sites, 1) / size(attenuation_data, 1) * 100);
        fprintf('  Damaged sites (regions 5-9): %d (%.1f%%) - need SA-killing\n', ...
            size(damaged_sites, 1), size(damaged_sites, 1) / size(attenuation_data, 1) * 100);
        
        % Count by region
        fprintf('  Region breakdown:\n');
        for region = 1:9
            count = sum(attenuation_data(:, region_col) == region);
            if region <= 4
                status = 'undamaged';
            else
                status = 'damaged';
            end
            fprintf('    Region %d (%s): %d sites\n', region, status, count);
        end
        
        %% Step 3: Extract initial conditions for SA-killing (if needed)
        fprintf('[3/4] Preparing initial conditions for SA-killing...\n');
        
        if size(damaged_sites, 1) == 0
            fprintf('  No damaged sites found - all sites already successfully treated by attenuation!\n');
            
            % Create dummy treatment results showing 100% success for all treatment combinations
            % Use standard treatment parameter ranges from g_TreatmentResponse
            strength_range = 0:0.5:5;  % SA-killing strength
            duration_range = 1:0.25:4; % Treatment duration (days)
            
            % Create all combinations
            [S, D] = meshgrid(strength_range, duration_range);
            strengths = S(:);
            durations = D(:);
            success_rates = ones(size(strengths));  % 100% success
            
            % Save results
            results_data = [strengths, durations, success_rates];
            results_filename = sprintf('data/%s_treatment_results_dual_action_%dx.csv', patient_type, fold_change);
            writematrix(results_data, results_filename);
            fprintf('  ✓ Saved treatment results: %s (100%% success, no SA-killing needed)\n', results_filename);
            
        else
            % g_TreatmentResponse expects specific columns (see g_ExtractInitialConditions)
            % We need: [patient_id, num_states, params(1:17), steady_states(A*,E*,B*), eigenvalues(3)]
            % From our data: columns 1-25 contain this information
            initial_conditions = damaged_sites(:, 1:25);
            
            % Save initial conditions file for g_TreatmentResponse
            ic_filename = sprintf('data/%s_SAkilling_from_attenuation_%dx.csv', patient_type, fold_change);
            writematrix(initial_conditions, ic_filename);
            fprintf('  ✓ Saved initial conditions: %s (%d damaged sites)\n', ic_filename, size(initial_conditions, 1));
        end
        
        %% Step 4: Run SA-killing treatment using g_TreatmentResponse
        fprintf('[4/4] Running SA-killing treatment simulations...\n');
        
        if size(damaged_sites, 1) == 0
            fprintf('  ✓ No SA-killing needed - all sites already treated by attenuation\n\n');
        else
            % Change directory to SA-killing folder and run g_TreatmentResponse
            original_dir = pwd;
            cd('../Effect of SA-killing');
            
            try
                % Copy our initial conditions to the expected location
                expected_ic_file = sprintf('data/%s_SAkilling.csv', patient_type);
                copyfile(fullfile(original_dir, ic_filename), expected_ic_file);
                
                % Run g_TreatmentResponse with default parameters (Figure 3 ranges)
                fprintf('  Calling g_TreatmentResponse...\n');
                g_TreatmentResponse();  % Default: strength 0-5, duration 1-4 days
                
                % Copy results back and combine with undamaged sites success
                results_file = sprintf('data/%s_treatment_results.csv', patient_type);
                target_file = sprintf('%s/%s_treatment_results_dual_action_%dx.csv', ...
                    original_dir, patient_type, fold_change);
                
                if exist(results_file, 'file')
                    % Load SA-killing results for damaged sites
                    sa_results = readmatrix(results_file);
                    
                    % Adjust success rates to account for total site population
                    total_sites = size(attenuation_data, 1);
                    damaged_count = size(damaged_sites, 1);
                    undamaged_count = size(undamaged_sites, 1);
                    
                    % New success rate = (undamaged_sites + damaged_sites * sa_success_rate) / total_sites
                    adjusted_success_rates = (undamaged_count + damaged_count * sa_results(:, 3)) / total_sites;
                    
                    % Save adjusted results
                    adjusted_results = [sa_results(:, 1:2), adjusted_success_rates];
                    writematrix(adjusted_results, target_file);
                    
                    fprintf('  ✓ Saved adjusted treatment results: %s\n', target_file);
                    fprintf('    (includes %d undamaged sites as 100%% successful)\n', undamaged_count);
                else
                    warning('Treatment results file not found: %s', results_file);
                end
                
            catch ME
                cd(original_dir);
                rethrow(ME);
            end
            
            cd(original_dir);
            fprintf('  ✓ %s treatment complete\n\n', patient_type);
        end
    end
    
    %% Step 5: Generate summary plots
    fprintf('=== Generating Treatment Response Heatmaps ===\n');
    
    % Generate combined heatmaps for both patient types
    generate_dual_action_plots(fold_change);
    
    fprintf('\n=== Dual-Action Treatment Pipeline Complete ===\n');
    fprintf('Treatment effectiveness includes:\n');
    fprintf('  • Sites with no damage after attenuation (regions 1-4): 100%% success\n');
    fprintf('  • Sites with damage after attenuation (regions 5-9): SA-killing results\n');
    fprintf('  • Combined metric maintains total site count for fair comparison\n\n');
    fprintf('Files generated:\n');
    for type_idx = 1:length(patient_types)
        patient_type = patient_types{type_idx};
        fprintf('  - data/%s_treatment_results_dual_action_%dx.csv\n', patient_type, fold_change);
    end
    fprintf('  - figures/Fig3_DualAction_%dx_Reversible.png\n', fold_change);
    fprintf('  - figures/Fig3_DualAction_%dx_Irreversible.png\n', fold_change);
    fprintf('  - figures/Fig3_DualAction_%dx_AllSites.png\n', fold_change);
end

%% Helper function to generate treatment response plots
function generate_dual_action_plots(fold_change)
    
    patient_types = {'reversible', 'irreversible'};
    
    % Generate individual plots for each patient type
    for type_idx = 1:length(patient_types)
        patient_type = patient_types{type_idx};
        
        % Load treatment results
        results_file = sprintf('data/%s_treatment_results_dual_action_%dx.csv', patient_type, fold_change);
        
        if ~exist(results_file, 'file')
            warning('Cannot find %s', results_file);
            continue;
        end
        
        data = readmatrix(results_file);
        strengths = data(:, 1);    % SA-killing strength
        durations = data(:, 2);    % Treatment duration (days)
        success_rates = data(:, 3) * 100;  % Convert to percentage
        
        % Create heatmap data
        unique_strengths = unique(strengths);
        unique_durations = unique(durations);
        
        heatmap_data = zeros(length(unique_durations), length(unique_strengths));
        
        for i = 1:length(unique_durations)
            for j = 1:length(unique_strengths)
                idx = (durations == unique_durations(i)) & (strengths == unique_strengths(j));
                if any(idx)
                    heatmap_data(i, j) = success_rates(idx);
                end
            end
        end
        
        % Create individual figure
        fig = figure('Position', [100, 100, 500, 400]);
        imagesc(unique_strengths, unique_durations, heatmap_data);
        colormap(gray);
        colorbar;
        
        % Customize plot
        xlabel('SA-killing strength');
        ylabel('Treatment duration (days)');
        title(sprintf('%s sites (after %dx attenuation)', ...
            capitalize_first(patient_type), fold_change));
        
        % Add value annotations
        for i = 1:size(heatmap_data, 1)
            for j = 1:size(heatmap_data, 2)
                value = heatmap_data(i, j);
                if value > 0
                    if value < 50
                        text_color = 'white';
                    else
                        text_color = 'black';
                    end
                    text(unique_strengths(j), unique_durations(i), sprintf('%.0f', value), ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                        'Color', text_color, 'FontSize', 8);
                end
            end
        end
        
        set(gca, 'YDir', 'normal');  % Flip Y-axis so low values are at bottom
        
        % Save individual figure
        output_file = sprintf('figures/Fig3_DualAction_%dx_%s.png', fold_change, capitalize_first(patient_type));
        print(fig, output_file, '-dpng', '-r300');
        fprintf('  ✓ Saved: %s\n', output_file);
        
        close(fig);
    end
    
    % Generate combined plot (AllSites)
    if length(patient_types) == 2
        % Load both datasets
        rev_data = readmatrix(sprintf('data/reversible_treatment_results_dual_action_%dx.csv', fold_change));
        irr_data = readmatrix(sprintf('data/irreversible_treatment_results_dual_action_%dx.csv', fold_change));
        
        if ~isempty(rev_data) && ~isempty(irr_data)
            % Average the success rates
            combined_success = (rev_data(:, 3) + irr_data(:, 3)) / 2 * 100;
            
            % Create combined heatmap
            unique_strengths = unique(rev_data(:, 1));
            unique_durations = unique(rev_data(:, 2));
            
            heatmap_data = zeros(length(unique_durations), length(unique_strengths));
            
            for i = 1:length(unique_durations)
                for j = 1:length(unique_strengths)
                    idx = (rev_data(:, 2) == unique_durations(i)) & (rev_data(:, 1) == unique_strengths(j));
                    if any(idx)
                        heatmap_data(i, j) = combined_success(idx);
                    end
                end
            end
            
            % Create combined figure
            fig = figure('Position', [100, 100, 500, 400]);
            imagesc(unique_strengths, unique_durations, heatmap_data);
            colormap(gray);
            colorbar;
            
            xlabel('SA-killing strength');
            ylabel('Treatment duration (days)');
            title(sprintf('All sites (after %dx attenuation)', fold_change));
            
            % Add value annotations
            for i = 1:size(heatmap_data, 1)
                for j = 1:size(heatmap_data, 2)
                    value = heatmap_data(i, j);
                    if value > 0
                        if value < 50
                            text_color = 'white';
                        else
                            text_color = 'black';
                        end
                        text(unique_strengths(j), unique_durations(i), sprintf('%.0f', value), ...
                            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                            'Color', text_color, 'FontSize', 8);
                    end
                end
            end
            
            set(gca, 'YDir', 'normal');
            
            % Save combined figure
            output_file = sprintf('figures/Fig3_DualAction_%dx_AllSites.png', fold_change);
            print(fig, output_file, '-dpng', '-r300');
            fprintf('  ✓ Saved: %s\n', output_file);
            
            close(fig);
        end
    end
end

%% Helper function to capitalize first letter
function str = capitalize_first(str)
    if ~isempty(str)
        str(1) = upper(str(1));
    end
end