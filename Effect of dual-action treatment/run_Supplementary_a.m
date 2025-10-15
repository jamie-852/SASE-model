% run_Figure_Panel_a.m - Generate Panel (a): Combined Attenuation + SA-Killing
%
% DESCRIPTION:
%   Tests 7 attenuation levels with 2:1 SA:SE ratio, then applies SA-killing
%   treatment to damaged sites to measure combined treatment effectiveness
%
% WORKFLOW:
%   For each attenuation level (2:1 ratio):
%     1. Apply attenuation using g_AttenuationFlexible
%     2. Count patients already healthy (B* = 1) after attenuation
%     3. Extract damaged sites (B* < 1) using g_ExtractInitialConditions
%     4. Apply SA-killing (strength=3, duration=2) using g_TreatmentResponse_Flexible
%     5. Total recovery = already_healthy + recovered_from_SA_killing
%
% ATTENUATION LEVELS TESTED (SE, SA - 2:1 ratio):
%   (1, 2), (2.5, 5), (5, 10), (7.5, 15), (10, 20), (12.5, 25), (15, 30)
%
% OUTPUT:
%   - CSV files in data/ folder
%   - Figure: figures/Panel_a_Combined_Treatment.png
%
% ESTIMATED TIME: 3-6 hours (depends on system)
%
% Author: Jamie Lee
% Date: October 14, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  Panel (a): Attenuation + SA-Killing Treatment       ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Configuration
SE_folds = [1, 2.5, 5, 7.5, 10, 12.5, 15];
SA_folds = [2, 5, 10, 15, 20, 25, 30];  % 2:1 ratio

patient_types = {'reversible', 'irreversible'};

% SA-killing parameters (single combination)
sa_killing_strength = 3;  % days⁻¹
sa_killing_duration = 2;  % days

fprintf('Configuration:\n');
fprintf('  Attenuation levels: %d combinations (2:1 SA:SE ratio)\n', length(SE_folds));
fprintf('  Patient types: reversible, irreversible\n');
fprintf('  SA-killing: strength=%.1f days⁻¹, duration=%.1f days\n\n', ...
        sa_killing_strength, sa_killing_duration);

fprintf('⚠️  WARNING: This will take several hours!\n');
fprintf('Press any key to continue or Ctrl+C to cancel...\n');
pause;
fprintf('\n');

%% Setup paths
sa_killing_folder = fullfile('..', 'Effect of SA-killing');

if ~exist(sa_killing_folder, 'dir')
    error('Cannot find SA-killing folder at: %s', sa_killing_folder);
end

% Add paths to ODE helper functions
addpath(sa_killing_folder);

% Verify ODE helper functions exist
required_functions = {'f_defineODEs', 'f_defineODEs_SAkilling', 'f_EventHealthy'};
for i = 1:length(required_functions)
    if exist(required_functions{i}, 'file') ~= 2
        error('Cannot find %s.m in %s', required_functions{i}, sa_killing_folder);
    end
end
fprintf('✓ ODE helper functions found\n');

% Create output folders
if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('figures', 'dir'), mkdir('figures'); end

%% Storage for results
results = struct();
results.SE_folds = SE_folds;
results.SA_folds = SA_folds;
results.reversible_recovery = zeros(size(SE_folds));
results.irreversible_recovery = zeros(size(SE_folds));

%% Main loop: Test each attenuation level
total_start = tic;

for level_idx = 1:length(SE_folds)
    SE_fold = SE_folds(level_idx);
    SA_fold = SA_folds(level_idx);
    
    fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
    fprintf('║  Level %d/%d: SE=%.1fx, SA=%.1fx (ratio %.2f:1)        \n', ...
            level_idx, length(SE_folds), SE_fold, SA_fold, SA_fold/SE_fold);
    fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
    
    for type_idx = 1:length(patient_types)
        patient_type = patient_types{type_idx};
        
        fprintf('\n--- Processing %s patients ---\n\n', patient_type);
        
        %% STAGE 1: Apply attenuation
        fprintf('STAGE 1: Applying attenuation...\n');
        stage1_start = tic;
        g_AttenuationFlexible(patient_type, SA_fold, SE_fold);
        stage1_time = toc(stage1_start);
        fprintf('✓ Attenuation complete (%.1f min)\n\n', stage1_time/60);
        
        %% STAGE 2: Analyze attenuation results
        fprintf('STAGE 2: Analyzing attenuation results...\n');
        
        % Load attenuation results
        atten_file = sprintf('data/attenuation_%s_SA%.1f_SE%.1f.csv', ...
                             patient_type, SA_fold, SE_fold);
        atten_data = readmatrix(atten_file);
        
        % Count patients (unique parameter sets)
        unique_patients = unique(atten_data(:, 3:19), 'rows');
        n_total_patients = size(unique_patients, 1);
        
        % Separate by barrier status
        healthy_mask = (atten_data(:, 22) == 1);
        damaged_mask = (atten_data(:, 22) < 1);
        
        n_healthy_states = sum(healthy_mask);
        n_damaged_states = sum(damaged_mask);
        
        % Count unique patients with at least one healthy state
        healthy_data = atten_data(healthy_mask, :);
        if ~isempty(healthy_data)
            healthy_patient_params = unique(healthy_data(:, 3:19), 'rows');
            n_already_recovered = size(healthy_patient_params, 1);
        else
            n_already_recovered = 0;
        end
        
        fprintf('  Total unique patients: %d\n', n_total_patients);
        fprintf('  States with B* = 1: %d\n', n_healthy_states);
        fprintf('  States with B* < 1: %d\n', n_damaged_states);
        fprintf('  Patients with ≥1 healthy state: %d (%.1f%%)\n', ...
                n_already_recovered, 100*n_already_recovered/n_total_patients);
        
        % If all patients already recovered, skip SA-killing
        if n_damaged_states == 0
            fprintf('  ✓ All patients recovered from attenuation alone!\n');
            recovery_pct = 100;
            
            if strcmp(patient_type, 'reversible')
                results.reversible_recovery(level_idx) = recovery_pct;
            else
                results.irreversible_recovery(level_idx) = recovery_pct;
            end
            continue;
        end
        
        fprintf('\n');
        
        %% STAGE 3: Extract damaged sites for SA-killing
        fprintf('STAGE 3: Extracting damaged sites for SA-killing...\n');
        
        damaged_data = atten_data(damaged_mask, :);
        
        % Get unique damaged patients
        damaged_patient_params = unique(damaged_data(:, 3:19), 'rows');
        n_damaged_patients = size(damaged_patient_params, 1);
        
        fprintf('  Unique damaged patients: %d\n', n_damaged_patients);
        
        % Prepare initial conditions file for SA-killing
        initial_file = sprintf('data/panel_a_%s_SA%.1f_SE%.1f_initial.csv', ...
                               patient_type, SA_fold, SE_fold);
        
        % Use g_ExtractInitialConditions with custom paths
        input_file = atten_file;
        
        % Call g_ExtractInitialConditions to extract worst-case states
        fprintf('  Extracting worst-case initial conditions...\n');
        extract_initial_conditions_custom(damaged_data, initial_file);
        
        fprintf('  ✓ Saved initial conditions: %s\n\n', initial_file);
        
        %% STAGE 4: Apply SA-killing treatment
        fprintf('STAGE 4: Applying SA-killing treatment...\n');
        fprintf('  Strength: %.1f days⁻¹\n', sa_killing_strength);
        fprintf('  Duration: %.1f days\n', sa_killing_duration);
        fprintf('  Patients to treat: %d\n', n_damaged_patients);
        
        stage4_start = tic;
        
        % Run SA-killing treatment
        treatment_output = sprintf('data/panel_a_%s_SA%.1f_SE%.1f_treatment.csv', ...
                                   patient_type, SA_fold, SE_fold);
        
        frac_recovered = run_sa_killing_treatment(initial_file, treatment_output, ...
                                                   sa_killing_strength, sa_killing_duration);
        
        stage4_time = toc(stage4_start);
        fprintf('✓ SA-killing complete (%.1f min)\n\n', stage4_time/60);
        
        %% Calculate total recovery
        n_recovered_from_treatment = round(frac_recovered * n_damaged_patients);
        n_total_recovered = n_already_recovered + n_recovered_from_treatment;
        recovery_pct = 100 * n_total_recovered / n_total_patients;
        
        fprintf('═══ RESULTS FOR %s (Level %d) ═══\n', upper(patient_type), level_idx);
        fprintf('  Attenuation: SE=%.1fx, SA=%.1fx\n', SE_fold, SA_fold);
        fprintf('  Total patients: %d\n', n_total_patients);
        fprintf('  Already recovered (attenuation): %d\n', n_already_recovered);
        fprintf('  Recovered from SA-killing: %d\n', n_recovered_from_treatment);
        fprintf('  TOTAL RECOVERED: %d (%.1f%%)\n\n', n_total_recovered, recovery_pct);
        
        % Store results
        if strcmp(patient_type, 'reversible')
            results.reversible_recovery(level_idx) = recovery_pct;
        else
            results.irreversible_recovery(level_idx) = recovery_pct;
        end
    end
end

total_time = toc(total_start);
fprintf('\nTotal analysis time: %.1f hours\n\n', total_time/3600);

%% Generate Panel (a) figure
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║              GENERATING PANEL (a) FIGURE              ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

figure('Position', [100, 100, 800, 600]);
hold on;

% Plot both patient types
plot(SE_folds, results.reversible_recovery, '-o', 'LineWidth', 2.5, ...
     'MarkerSize', 10, 'DisplayName', 'Reversible', 'Color', [0.2, 0.6, 0.8]);
plot(SE_folds, results.irreversible_recovery, '-s', 'LineWidth', 2.5, ...
     'MarkerSize', 10, 'DisplayName', 'Irreversible', 'Color', [0.8, 0.2, 0.2]);

xlabel('SE Attenuation Fold-Change', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('% Damaged Sites Recovered', 'FontSize', 14, 'FontWeight', 'bold');
title('Panel (a): Combined Attenuation + SA-Killing Treatment', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 12);
grid on;
xlim([0, max(SE_folds)+1]);
ylim([0, 100]);

% Add secondary x-axis showing SA values
ax1 = gca;
ax1.FontSize = 12;
ax2 = axes('Position', ax1.Position, 'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', 'Color', 'none');
ax2.XLim = ax1.XLim;
ax2.YLim = ax1.YLim;
ax2.XTick = SE_folds;
ax2.XTickLabel = arrayfun(@(x) sprintf('%.1f', x), SA_folds, 'UniformOutput', false);
xlabel(ax2, 'SA Attenuation Fold-Change (2:1 ratio)', 'FontSize', 14, 'FontWeight', 'bold');
ax2.YTick = [];
ax2.FontSize = 12;

% Save figure
saveas(gcf, 'figures/Panel_a_Combined_Treatment.png');
fprintf('✓ Figure saved to: figures/Panel_a_Combined_Treatment.png\n');

% Save summary data
summary_data = [SE_folds', SA_folds', ...
                results.reversible_recovery', results.irreversible_recovery'];
summary_header = 'SE_fold,SA_fold,Reversible_pct,Irreversible_pct';
writematrix(summary_data, 'data/panel_a_summary.csv');
fprintf('✓ Summary saved to: data/panel_a_summary.csv\n');

fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║                   ANALYSIS COMPLETE!                  ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');

%% Helper function: Extract initial conditions (custom version)
function extract_initial_conditions_custom(patient_data, output_file)
    % Extract one initial condition per patient using priority rules
    % Priority: Regions 7/8/9 (SA-driven) → Regions 5/6 (SE-driven) → smallest B*
    
    % Get unique patient IDs
    patient_ids = unique(patient_data(:, 1));
    n_patients = length(patient_ids);
    
    % Preallocate output
    initial_conditions = zeros(n_patients, size(patient_data, 2));
    
    % Process each patient
    for i = 1:n_patients
        patient_id = patient_ids(i);
        patient_rows = patient_data(patient_data(:, 1) == patient_id, :);
        
        regions = patient_rows(:, 26);
        B_stars = patient_rows(:, 22);
        
        % Priority 1: SA-driven states (Regions 7, 8, 9)
        sa_mask = (regions == 7) | (regions == 8) | (regions == 9);
        
        if any(sa_mask)
            sa_rows = patient_rows(sa_mask, :);
            sa_B = B_stars(sa_mask);
            [~, idx] = min(sa_B);
            initial_conditions(i, :) = sa_rows(idx, :);
            continue;
        end
        
        % Priority 2: SE-driven states (Regions 5, 6)
        se_mask = (regions == 5) | (regions == 6);
        
        if any(se_mask)
            se_rows = patient_rows(se_mask, :);
            se_B = B_stars(se_mask);
            [~, idx] = min(se_B);
            initial_conditions(i, :) = se_rows(idx, :);
            continue;
        end
        
        % Fallback: smallest B*
        [~, idx] = min(B_stars);
        initial_conditions(i, :) = patient_rows(idx, :);
    end
    
    writematrix(initial_conditions, output_file);
end

%% Helper function: Run SA-killing treatment
function frac_recovered = run_sa_killing_treatment(input_file, output_file, strength, duration)
    % Run SA-killing treatment simulation
    % Returns: fraction of patients that recovered (B* reached 1)
    
    % Load sites
    sites = readmatrix(input_file);
    n_sites = size(sites, 1);
    
    % ODE options
    options = odeset('NonNegative', 1, 'RelTol', 1e-4, 'AbsTol', 1e-4);
    options_event = odeset('NonNegative', 1, 'Events', @f_EventHealthy, ...
                           'RelTol', 1e-4, 'AbsTol', 1e-4);
    
    % Check for parallel processing
    use_parallel = check_parallel();
    
    % Simulate treatment for each site
    n_success = 0;
    S = 1;  % Treatment applied when S = 1
    
    if use_parallel
        parfor i = 1:n_sites
            if simulate_site(sites(i, :), strength, duration, S, options, options_event)
                n_success = n_success + 1;
            end
        end
    else
        for i = 1:n_sites
            if simulate_site(sites(i, :), strength, duration, S, options, options_event)
                n_success = n_success + 1;
            end
            
            if mod(i, 50) == 0
                fprintf('    Progress: %d/%d sites\n', i, n_sites);
            end
        end
    end
    
    frac_recovered = n_success / n_sites;
    
    % Save detailed results
    results_data = [strength, duration, n_sites, n_success, frac_recovered];
    writematrix(results_data, output_file);
    
    fprintf('  Treatment results: %d/%d recovered (%.1f%%)\n', ...
            n_success, n_sites, 100*frac_recovered);
end

%% Helper: Check parallel processing
function available = check_parallel()
    try
        pool = gcp('nocreate');
        if isempty(pool)
            parpool('local', 'SpmdEnabled', false);
        end
        available = true;
    catch
        available = false;
    end
end

%% Helper: Simulate single site
function success = simulate_site(site_data, delta_AS, t_end, S, options, options_event)
    % Extract parameters (columns 3-19)
    kappa_A  = site_data(3);    kappa_E  = site_data(10);
    A_max    = site_data(4);    E_max    = site_data(11);
    gamma_AB = site_data(5);    gamma_EB = site_data(12);
    delta_AE = site_data(6);    delta_EA = site_data(13);
    A_th     = site_data(7);    E_th     = site_data(14);
    E_pth    = site_data(8);    A_pth    = site_data(15);
    gamma_AE = site_data(9);    kappa_B  = site_data(16);
    delta_B  = site_data(17);
    delta_BA = site_data(18);
    delta_BE = site_data(19);
    
    % Extract initial conditions (columns 20-22)
    A_0 = site_data(20);
    E_0 = site_data(21);
    B_0 = site_data(22);
    
    % Handle near-zero populations
    if A_0 <= 1, A_0 = 0; end
    if E_0 <= 1, E_0 = 0; end
    
    % Phase 1: Apply SA-killing treatment
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, ...
        delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, ...
        A_pth, kappa_B, delta_B, delta_BA, delta_BE, delta_AS, S), ...
        [0, t_end], [A_0, E_0, B_0], options);
    
    % Perturbation after treatment
    A_pert = max(1, y1(end, 1) - 1);
    E_pert = max(1, y1(end, 2) - 1);
    B_post = y1(end, 3);
    
    % Phase 2: Check if system reaches healthy state
    [t2, y2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t1(end), t1(end) + 1e6], [A_pert, E_pert, B_post], options_event);
    
    if t2(end) >= (t1(end) + 1e6)
        success = false;
        return;
    end
    
    % Phase 3: Test stability
    A_stab = max(1, y2(end, 1) - 1);
    E_stab = max(1, y2(end, 2) - 1);
    B_final = y2(end, 3);
    
    [~, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t2(end), t1(end) + 1e6], [A_stab, E_stab, B_final], options);
    
    success = (y3(end, 3) == 1);
end

%% Event function: Detect healthy state
function [value, isterminal, direction] = f_EventHealthy(~, y)
    value = y(3) - 1;
    isterminal = 1;
    direction = 1;
end