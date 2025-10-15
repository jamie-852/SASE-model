% run_Panel_a_DataGeneration.m
%
% Generate data for Panel (a): Combined Attenuation (20x) + SA-Killing Treatment
%
% Workflow:
%   1. Apply 20x attenuation to SA and SE for both patient types
%   2. Count patients that recover from attenuation alone
%   3. Extract damaged patients and apply SA-killing treatment
%   4. Calculate total recovery % for each (strength, duration) combination
%
% Outputs: data/panel_a_results.mat
%          data/reversible_dual_action.csv
%          data/irreversible_dual_action.csv
%
% Author: Jamie Lee
% Date: October 15, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║    Panel (a): Combined Treatment Data Generation     ║\n');
fprintf('║           Attenuation (20x) + SA-Killing              ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Configuration
attenuation_fold = 20;  % 20x for both SA and SE
patient_types = {'reversible', 'irreversible'};

% SA-killing parameters (matching g_TreatmentResponse defaults)
strength_start = 0;
strength_step = 1;
strength_end = 5;
duration_start = 1;
duration_step = 0.5;
duration_end = 4;

fprintf('Configuration:\n');
fprintf('  Attenuation: %dx (both SA and SE)\n', attenuation_fold);
fprintf('  SA-killing strength: %.1f to %.1f (step %.1f)\n', strength_start, strength_end, strength_step);
fprintf('  SA-killing duration: %.1f to %.1f days (step %.1f)\n\n', duration_start, duration_end, duration_step);

fprintf('⚠️  This will take several hours!\n');
fprintf('Press any key to continue or Ctrl+C to cancel...\n');
pause;
fprintf('\n');

%% Setup paths
sa_killing_folder = fullfile('..', 'Effect of SA-killing');
if ~exist(sa_killing_folder, 'dir')
    error('Cannot find SA-killing folder at: %s', sa_killing_folder);
end

% Add SA-killing folder to path
addpath(sa_killing_folder);

% Create output folders
if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('figures', 'dir'), mkdir('figures'); end

%% Initialize results storage
results = struct();
results.strength_vals = strength_start:strength_step:strength_end;
results.duration_vals = duration_start:duration_step:duration_end;
results.all_sites = zeros(length(results.duration_vals), length(results.strength_vals));
results.reversible = zeros(length(results.duration_vals), length(results.strength_vals));
results.irreversible = zeros(length(results.duration_vals), length(results.strength_vals));

%% STAGE 1: Apply Attenuation Treatment
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║             STAGE 1: Attenuation (20x)                ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

attenuation_results = struct();

for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    
    fprintf('\n--- %s patients ---\n\n', upper(patient_type));
    
    % Run attenuation
    fprintf('Running attenuation...\n');
    stage1_start = tic;
    [AllVirtualPatientTypes, ~] = g_AttenuationFlexible(patient_type, attenuation_fold, attenuation_fold);
    stage1_time = toc(stage1_start);
    fprintf('✓ Complete (%.1f min)\n\n', stage1_time/60);
    
    % Get unique patients and their recovery status
    patient_ids = unique(AllVirtualPatientTypes(:, 1));
    n_total_patients = length(patient_ids);
    
    % Count patients with ALL healthy states
    n_recovered_attenuation = 0;
    damaged_patient_ids = [];
    
    for i = 1:n_total_patients
        patient_id = patient_ids(i);
        patient_rows = AllVirtualPatientTypes(AllVirtualPatientTypes(:, 1) == patient_id, :);
        
        % Check if ALL states have B* = 1 (fully healthy patient)
        if all(patient_rows(:, 22) == 1)
            n_recovered_attenuation = n_recovered_attenuation + 1;
        else
            damaged_patient_ids = [damaged_patient_ids; patient_id];
        end
    end
    
    pct_attenuation = 100 * n_recovered_attenuation / n_total_patients;
    
    fprintf('Attenuation Results:\n');
    fprintf('  Total patients: %d\n', n_total_patients);
    fprintf('  Recovered (attenuation alone): %d (%.1f%%)\n', n_recovered_attenuation, pct_attenuation);
    fprintf('  Still damaged: %d (%.1f%%)\n\n', length(damaged_patient_ids), 100 - pct_attenuation);
    
    % Store results
    attenuation_results.(patient_type).n_total = n_total_patients;
    attenuation_results.(patient_type).n_recovered_attenuation = n_recovered_attenuation;
    attenuation_results.(patient_type).damaged_patient_ids = damaged_patient_ids;
    attenuation_results.(patient_type).AllVirtualPatientTypes = AllVirtualPatientTypes;
end

%% STAGE 2: Extract Initial Conditions for Damaged Patients
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║    STAGE 2: Extract Initial Conditions (Damaged)     ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    
    fprintf('\n--- %s patients ---\n\n', upper(patient_type));
    
    damaged_ids = attenuation_results.(patient_type).damaged_patient_ids;
    AllVPT = attenuation_results.(patient_type).AllVirtualPatientTypes;
    
    if isempty(damaged_ids)
        fprintf('No damaged patients - all recovered from attenuation!\n');
        attenuation_results.(patient_type).initial_conditions = [];
        continue;
    end
    
    % Extract damaged patients only
    damaged_mask = ismember(AllVPT(:, 1), damaged_ids);
    damaged_data = AllVPT(damaged_mask, :);
    
    % Apply extraction logic (priority: regions 7/8/9, then 5/6)
    initial_conditions = extract_worst_case_initial_conditions(damaged_data);
    
    fprintf('  Extracted %d initial conditions\n', size(initial_conditions, 1));
    
    % Save temporarily to SA-killing folder with unique name
    temp_file = fullfile(sa_killing_folder, 'data', sprintf('dual_action_%s_20x_temp.csv', patient_type));
    writematrix(initial_conditions, temp_file);
    fprintf('  ✓ Saved temporarily: %s\n', temp_file);
    
    attenuation_results.(patient_type).initial_conditions = initial_conditions;
    attenuation_results.(patient_type).temp_file = temp_file;
end

%% STAGE 3: Apply SA-Killing Treatment
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║          STAGE 3: SA-Killing Treatment                ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

for type_idx = 1:length(patient_types)
    patient_type = patient_types{type_idx};
    
    fprintf('\n--- %s patients ---\n\n', upper(patient_type));
    
    initial_conditions = attenuation_results.(patient_type).initial_conditions;
    
    if isempty(initial_conditions)
        fprintf('Skipping SA-killing (no damaged patients)\n');
        % Fill with 100% recovery for all combinations
        attenuation_results.(patient_type).sa_killing_results = ones(length(results.duration_vals), length(results.strength_vals));
        continue;
    end
    
    % Run SA-killing for all combinations
    fprintf('Testing %d strength × %d duration = %d combinations\n', ...
            length(results.strength_vals), length(results.duration_vals), ...
            length(results.strength_vals) * length(results.duration_vals));
    
    stage3_start = tic;
    sa_killing_results = run_sa_killing_grid(initial_conditions, ...
                                              results.strength_vals, ...
                                              results.duration_vals);
    stage3_time = toc(stage3_start);
    
    fprintf('✓ SA-killing complete (%.1f min)\n', stage3_time/60);
    
    attenuation_results.(patient_type).sa_killing_results = sa_killing_results;
    
    % Clean up temporary file
    if exist(attenuation_results.(patient_type).temp_file, 'file')
        delete(attenuation_results.(patient_type).temp_file);
        fprintf('✓ Cleaned up temporary file\n');
    end
end

%% STAGE 4: Calculate Total Recovery Percentages
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║      STAGE 4: Calculate Total Recovery Rates          ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

for dur_idx = 1:length(results.duration_vals)
    for str_idx = 1:length(results.strength_vals)
        
        % Reversible
        n_rev_total = attenuation_results.reversible.n_total;
        n_rev_atten = attenuation_results.reversible.n_recovered_attenuation;
        frac_rev_sa = attenuation_results.reversible.sa_killing_results(dur_idx, str_idx);
        n_rev_damaged = length(attenuation_results.reversible.damaged_patient_ids);
        n_rev_sa = round(frac_rev_sa * n_rev_damaged);
        
        pct_rev = 100 * (n_rev_atten + n_rev_sa) / n_rev_total;
        results.reversible(dur_idx, str_idx) = pct_rev;
        
        % Irreversible
        n_irrev_total = attenuation_results.irreversible.n_total;
        n_irrev_atten = attenuation_results.irreversible.n_recovered_attenuation;
        frac_irrev_sa = attenuation_results.irreversible.sa_killing_results(dur_idx, str_idx);
        n_irrev_damaged = length(attenuation_results.irreversible.damaged_patient_ids);
        n_irrev_sa = round(frac_irrev_sa * n_irrev_damaged);
        
        pct_irrev = 100 * (n_irrev_atten + n_irrev_sa) / n_irrev_total;
        results.irreversible(dur_idx, str_idx) = pct_irrev;
        
        % Weighted average for all sites
        n_total = n_rev_total + n_irrev_total;
        n_recovered_total = (n_rev_atten + n_rev_sa) + (n_irrev_atten + n_irrev_sa);
        pct_all = 100 * n_recovered_total / n_total;
        results.all_sites(dur_idx, str_idx) = pct_all;
    end
end

fprintf('✓ Recovery rates calculated\n\n');

%% Save Results
fprintf('Saving results...\n');

% Save MAT file
save('data/panel_a_results.mat', 'results', 'attenuation_results');
fprintf('  ✓ data/panel_a_results.mat\n');

% Save CSV files (for plotting compatibility)
fprintf('  Saving CSV files for plotting...\n');

% Format: [strength, duration, success_percentage]
n_combos = length(results.strength_vals) * length(results.duration_vals);
reversible_csv = zeros(n_combos, 3);
irreversible_csv = zeros(n_combos, 3);

row_idx = 0;
for str_idx = 1:length(results.strength_vals)
    for dur_idx = 1:length(results.duration_vals)
        row_idx = row_idx + 1;
        
        strength = results.strength_vals(str_idx);
        duration = results.duration_vals(dur_idx);
        
        reversible_csv(row_idx, :) = [strength, duration, results.reversible(dur_idx, str_idx)];
        irreversible_csv(row_idx, :) = [strength, duration, results.irreversible(dur_idx, str_idx)];
    end
end

writematrix(reversible_csv, 'data/reversible_dual_action.csv');
writematrix(irreversible_csv, 'data/irreversible_dual_action.csv');

fprintf('  ✓ data/reversible_dual_action.csv\n');
fprintf('  ✓ data/irreversible_dual_action.csv\n\n');

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║              DATA GENERATION COMPLETE                 ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

fprintf('Summary:\n');
fprintf('  All sites recovery range: %.1f%% - %.1f%%\n', min(results.all_sites(:)), max(results.all_sites(:)));
fprintf('  Reversible recovery range: %.1f%% - %.1f%%\n', min(results.reversible(:)), max(results.reversible(:)));
fprintf('  Irreversible recovery range: %.1f%% - %.1f%%\n\n', min(results.irreversible(:)), max(results.irreversible(:)));

fprintf('Next step: Run run_Panel_a_Plot.m to generate heatmaps\n');

%% Helper Functions

function initial_conditions = extract_worst_case_initial_conditions(patient_data)
    % Extract one initial condition per patient using priority rules
    patient_ids = unique(patient_data(:, 1));
    n_patients = length(patient_ids);
    initial_conditions = zeros(n_patients, size(patient_data, 2));
    
    for i = 1:n_patients
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
end

function sa_results = run_sa_killing_grid(initial_conditions, strength_vals, duration_vals)
    % Run SA-killing treatment for all (strength, duration) combinations
    
    n_sites = size(initial_conditions, 1);
    sa_results = zeros(length(duration_vals), length(strength_vals));
    
    % ODE options
    options = odeset('NonNegative', 1, 'RelTol', 1e-4, 'AbsTol', 1e-4);
    options_event = odeset('NonNegative', 1, 'Events', @f_EventHealthy, 'RelTol', 1e-4, 'AbsTol', 1e-4);
    
    % Check parallel
    try
        pool = gcp('nocreate');
        if isempty(pool), parpool('local', 'SpmdEnabled', false); end
        use_parallel = true;
    catch
        use_parallel = false;
    end
    
    combo_idx = 0;
    total_combos = length(strength_vals) * length(duration_vals);
    
    for str_idx = 1:length(strength_vals)
        for dur_idx = 1:length(duration_vals)
            combo_idx = combo_idx + 1;
            
            strength = strength_vals(str_idx);
            duration = duration_vals(dur_idx);
            
            % Test this combination on all sites
            n_success = 0;
            
            if use_parallel
                parfor i = 1:n_sites
                    if test_treatment(initial_conditions(i, :), strength, duration, options, options_event)
                        n_success = n_success + 1;
                    end
                end
            else
                for i = 1:n_sites
                    if test_treatment(initial_conditions(i, :), strength, duration, options, options_event)
                        n_success = n_success + 1;
                    end
                end
            end
            
            sa_results(dur_idx, str_idx) = n_success / n_sites;
            
            % Debug output every 10 combinations
            if mod(combo_idx, 10) == 0
                fprintf('  Combo %d/%d: strength=%.1f, duration=%.1f → %.1f%% success (%d/%d)\n', ...
                        combo_idx, total_combos, strength, duration, ...
                        100*n_success/n_sites, n_success, n_sites);
            end
        end
    end
    
    % Summary
    fprintf('\n  SA-killing grid complete:\n');
    fprintf('    Min success: %.1f%%\n', 100*min(sa_results(:)));
    fprintf('    Max success: %.1f%%\n', 100*max(sa_results(:)));
    fprintf('    Mean success: %.1f%%\n\n', 100*mean(sa_results(:)));
end

function success = test_treatment(site_data, delta_AS, t_end, options, options_event)
    % Test single treatment combination (from g_TreatmentResponse logic)
    
    % Extract parameters
    kappa_A  = site_data(3);    kappa_E  = site_data(10);
    A_max    = site_data(4);    E_max    = site_data(11);
    gamma_AB = site_data(5);    gamma_EB = site_data(12);
    delta_AE = site_data(6);    delta_EA = site_data(13);
    A_th     = site_data(7);    E_th     = site_data(14);
    E_pth    = site_data(8);    A_pth    = site_data(15);
    gamma_AE = site_data(9);    kappa_B  = site_data(16);
    delta_B  = site_data(17);   delta_BA = site_data(18);
    delta_BE = site_data(19);
    
    % Initial conditions
    A_0 = site_data(20);
    E_0 = site_data(21);
    B_0 = site_data(22);
    
    if A_0 <= 1, A_0 = 0; end
    if E_0 <= 1, E_0 = 0; end
    
    S = 1;  % Treatment applied
    
    % Phase 1: SA-killing
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, ...
        delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, ...
        A_pth, kappa_B, delta_B, delta_BA, delta_BE, delta_AS, S), ...
        [0, t_end], [A_0, E_0, B_0], options);
    
    % Phase 2: Recovery check
    A_pert = max(1, y1(end, 1) - 1);
    E_pert = max(1, y1(end, 2) - 1);
    B_post = y1(end, 3);
    
    [t2, y2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t1(end), t1(end) + 1e6], [A_pert, E_pert, B_post], options_event);
    
    if t2(end) >= (t1(end) + 1e6)
        success = false;
        return;
    end
    
    % Phase 3: Stability check
    A_stab = max(1, y2(end, 1) - 1);
    E_stab = max(1, y2(end, 2) - 1);
    B_final = y2(end, 3);
    
    [~, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t2(end), t1(end) + 1e6], [A_stab, E_stab, B_final], options);
    
    success = (y3(end, 3) == 1);
end