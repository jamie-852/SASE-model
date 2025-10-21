% run_DualAction.m
%
% Purpose: Dual-action treatment pipeline (20x attenuation + SA-killing)
%
% Workflow:
%   1. Apply 20x attenuation to both SA and SE for each patient type
%   2. Extract damaged sites (regions 5-9) as initial conditions
%   3. Apply SA-killing treatment to damaged sites
%   4. Generate heatmap figures of treatment success rates for all sites, reversible sites, and irreversible sites
%
% Outputs:
%   - data/reversible_SAkilling_post_attenuation.csv
%   - data/irreversible_SAkilling_post_attenuation.csv
%   - data/reversible_treatment_results_dual_action.csv
%   - data/irreversible_treatment_results_dual_action.csv
%   - figures/Figure5_AllSites.png
%   - figures/Figure5_Reversible.png
%   - figures/Figure5_Irreversible.png
%
% Author: Jamie Lee
% Date: October 20, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════════════════════╗\n');
fprintf('║      Dual-Action Treatment Pipeline (20x attenuation + SA-killing)     ║\n');
fprintf('╚═══════════════════════════════════════════════════════════════════════╝\n\n');

%% Configuration
fold_change = 20;  % 20x attenuation for both SA and SE
patient_types = {'reversible', 'irreversible'};

% Create output folders
if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('figures', 'dir'), mkdir('figures'); end

%% Stage 1: Apply Attenuation
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║         STAGE 1: Attenuation (20x SA + 20x SE)       ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

attenuation_stats = struct();

for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    
    fprintf('\n--- %s patients ---\n\n', upper(patient_type));
    
    % Run attenuation
    fprintf('Running attenuation...\n');
    stage1_start = tic;
    [AllVirtualPatientTypes, ~] = g_AttenuationFlexible(patient_type, fold_change, fold_change);
    stage1_time = toc(stage1_start);
    
    fprintf('✓ Attenuation complete (%.1f minutes)\n', stage1_time/60);
    
    % Calculate recovery percentage correctly (count patients, not states)
    patient_ids = unique(AllVirtualPatientTypes(:, 1));
    n_unique_patients = length(patient_ids);
    
    n_recovered = 0;
    
    fprintf('  Analyzing %d unique patients...', n_unique_patients);
    progress_update = max(1, floor(n_unique_patients/10));  % Update every 10%
    
    for i = 1:n_unique_patients
        if mod(i, progress_update) == 0
            fprintf(' %.0f%%', 100*i/n_unique_patients);
        end
        
        patient_id = patient_ids(i);
        patient_states = AllVirtualPatientTypes(AllVirtualPatientTypes(:, 1) == patient_id, :);
        all_regions = patient_states(:, 26);
        
        % Check if ALL states are in healthy regions (1-4)
        if all(all_regions >= 1 & all_regions <= 4)
            n_recovered = n_recovered + 1;
        end
    end
    fprintf(' 100%%\n');
    
    percentage = 100 * n_recovered / n_unique_patients;
    
    fprintf('✓ Complete (%.1f min)\n', stage1_time/60);
    fprintf('  Recovery from attenuation alone: %.1f%% (%d/%d patients)\n\n', ...
            percentage, n_recovered, n_unique_patients);
    
    % Store stats
    attenuation_stats.(patient_type).data = AllVirtualPatientTypes;
    attenuation_stats.(patient_type).percentage = percentage;
    attenuation_stats.(patient_type).n_recovered = n_recovered;
    attenuation_stats.(patient_type).n_total = n_unique_patients;
end

%% Stage 2: Extract Damaged Sites
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║     STAGE 2: Extract Damaged Sites (Regions 5-9)     ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    
    fprintf('\n--- %s patients ---\n\n', upper(patient_type));
    
    AllVPT = attenuation_stats.(patient_type).data;
    
    % Filter for damaged regions (5-9)
    region_col = 26;
    damaged_mask = (AllVPT(:, region_col) >= 5) & (AllVPT(:, region_col) <= 9);
    damaged_sites = AllVPT(damaged_mask, :);
    
    fprintf('  Total sites: %d\n', size(AllVPT, 1));
    fprintf('  Undamaged (regions 1-4): %d (%.1f%%)\n', ...
        sum(~damaged_mask), 100*sum(~damaged_mask)/size(AllVPT, 1));
    fprintf('  Damaged (regions 5-9): %d (%.1f%%)\n', ...
        size(damaged_sites, 1), 100*size(damaged_sites, 1)/size(AllVPT, 1));
    
    if isempty(damaged_sites)
        fprintf('  ⚠️  No damaged sites - all recovered from attenuation!\n');
        attenuation_stats.(patient_type).damaged_sites = [];
        continue;
    end
    
    % Extract initial conditions using priority rules
    initial_conditions = extract_worst_case_initial_conditions(damaged_sites);
    
    % Save initial conditions
    ic_file = sprintf('data/%s_SAkilling_post_attenuation.csv', patient_type);
    writematrix(initial_conditions, ic_file);
    fprintf('  ✓ Saved: %s (%d sites)\n', ic_file, size(initial_conditions, 1));
    
    attenuation_stats.(patient_type).damaged_sites = initial_conditions;
end

%% Stage 3: Apply SA-Killing Treatment
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║         STAGE 3: SA-Killing Treatment                 ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    
    fprintf('\n--- %s patients ---\n\n', upper(patient_type));
    
    damaged_sites = attenuation_stats.(patient_type).damaged_sites;
    
    if isempty(damaged_sites)
        fprintf('Skipping SA-killing (no damaged sites)\n');
        
        % Create dummy results showing 100% success
        strengths = 0:1:5;
        durations = 1:0.5:4;
        [S, D] = meshgrid(strengths, durations);
        results = [S(:), D(:), ones(numel(S), 1)];
        
        results_file = sprintf('data/%s_treatment_results_dual_action.csv', patient_type);
        writematrix(results, results_file);
        fprintf('  ✓ Saved: %s (100%% success - no treatment needed)\n', results_file);
        continue;
    end
    
    % Run SA-killing treatment
    fprintf('Testing SA-killing treatment combinations...\n');
    stage3_start = tic;
    g_TreatmentResponse_DualAction(patient_type);
    stage3_time = toc(stage3_start);
    
    fprintf('✓ SA-killing complete (%.1f min)\n', stage3_time/60);
end

%% Stage 4: Generate Plots
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║         STAGE 4: Generate Heatmap Figures             ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

% Save attenuation statistics for plotting function
attenuation_summary = [];
for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    pct = attenuation_stats.(patient_type).percentage / 100;  % Convert to fraction
    n_rec = attenuation_stats.(patient_type).n_recovered;
    n_tot = attenuation_stats.(patient_type).n_total;
    
    % Save as: [type_code, recovery_fraction, n_recovered, n_total]
    type_code = strcmp(patient_type, 'reversible');  % 1 for reversible, 0 for irreversible
    attenuation_summary = [attenuation_summary; type_code, pct, n_rec, n_tot];
end
writematrix(attenuation_summary, 'data/attenuation_recovery_stats.csv');

g_Plot_DualAction();

%% Summary
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║            DUAL-ACTION PIPELINE COMPLETE              ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

fprintf('Summary:\n');
fprintf('  Attenuation (20x SA + 20x SE):\n');
for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    pct = attenuation_stats.(patient_type).percentage;
    n_rec = attenuation_stats.(patient_type).n_recovered;
    n_tot = attenuation_stats.(patient_type).n_total;
    fprintf('    %s: %.1f%% recovered (%d/%d patients with ALL states healthy)\n', ...
            capitalize_first(patient_type), pct, n_rec, n_tot);
end

%% Helper Functions

function initial_conditions = extract_worst_case_initial_conditions(patient_data)
    % Extract one initial condition per patient using priority rules
    
    patient_ids = unique(patient_data(:, 1));
    n_patients = length(patient_ids);
    initial_conditions = zeros(n_patients, size(patient_data, 2));
    
    fprintf('  Processing %d patients for initial conditions...', n_patients);
    progress_update = max(1, floor(n_patients/10));
    
    for i = 1:n_patients
        if mod(i, progress_update) == 0
            fprintf(' %.0f%%', 100*i/n_patients);
        end
        
        patient_id = patient_ids(i);
        patient_rows = patient_data(patient_data(:, 1) == patient_id, :);
        regions = patient_rows(:, 26);
        B_stars = patient_rows(:, 22);
        
        % Priority 1: SA-driven (7/8/9)
        sa_mask = (regions == 7) | (regions == 8) | (regions == 9);
        if any(sa_mask)
            [~, idx] = min(B_stars(sa_mask));
            sa_rows = patient_rows(sa_mask, :);
            initial_conditions(i, :) = sa_rows(idx, :);
            continue;
        end
        
        % Priority 2: SE-driven (5/6)
        se_mask = (regions == 5) | (regions == 6);
        if any(se_mask)
            [~, idx] = min(B_stars(se_mask));
            se_rows = patient_rows(se_mask, :);
            initial_conditions(i, :) = se_rows(idx, :);
            continue;
        end
        
        % Fallback: smallest B*
        [~, idx] = min(B_stars);
        initial_conditions(i, :) = patient_rows(idx, :);
    end
    fprintf(' 100%%\n');
    
    % Report region distribution
    selected_regions = initial_conditions(:, 26);
    fprintf('  Initial condition regions:\n');
    for region = [5, 6, 7, 8, 9]
        count = sum(selected_regions == region);
        if count > 0
            fprintf('    Region %d: %d sites (%.1f%%)\n', region, count, 100*count/n_patients);
        end
    end
end

function str = capitalize_first(str)
    if ~isempty(str)
        str(1) = upper(str(1));
    end
end