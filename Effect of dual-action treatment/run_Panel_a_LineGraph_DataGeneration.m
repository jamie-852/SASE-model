% run_Panel_a_LineGraph_DataGeneration.m
%
% Generate data for Panel (a): Line graph showing recovery vs. attenuation strength
%
% Workflow:
%   1. Test 7 attenuation levels with 2:1 SA:SE ratio
%   2. Count patients that recover from attenuation alone
%   3. Extract damaged patients and apply FIXED SA-killing (3 days⁻¹, 2 days)
%   4. Calculate total recovery % for each attenuation level
%
% Attenuation levels: (SE, SA) = (1,2), (2.5,5), (5,10), (7.5,15), (10,20), (12.5,25), (15,30)
% SA-killing: Fixed at strength=3 days⁻¹, duration=2 days
%
% Output: data/panel_a_line_results.mat
%
% Author: Jamie Lee
% Date: October 15, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║    Panel (a): Line Graph Data Generation             ║\n');
fprintf('║    Attenuation (2:1 ratio) + Fixed SA-Killing        ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Configuration
% 2:1 SA:SE ratio attenuation levels
SE_folds = [1, 2.5, 5, 7.5, 10, 12.5, 15];
SA_folds = [2, 5, 10, 15, 20, 25, 30];

% Fixed SA-killing parameters
sa_killing_strength = 3;  % days⁻¹
sa_killing_duration = 2;  % days

patient_types = {'reversible', 'irreversible'};

fprintf('Configuration:\n');
fprintf('  Attenuation levels: %d (2:1 SA:SE ratio)\n', length(SE_folds));
fprintf('  SE fold-changes: [%s]\n', sprintf('%.1f ', SE_folds));
fprintf('  SA fold-changes: [%s]\n', sprintf('%.0f ', SA_folds));
fprintf('  SA-killing: strength=%.1f days⁻¹, duration=%.1f days\n\n', ...
        sa_killing_strength, sa_killing_duration);

fprintf('⚠️  This will take several hours!\n');
fprintf('Press any key to continue or Ctrl+C to cancel...\n');
pause;
fprintf('\n');

%% Setup paths
sa_killing_folder = fullfile('..', 'Effect of SA-killing');
if ~exist(sa_killing_folder, 'dir')
    error('Cannot find SA-killing folder at: %s', sa_killing_folder);
end

addpath(sa_killing_folder);

% Create output folders
if ~exist('data', 'dir'), mkdir('data'); end
if ~exist('figures', 'dir'), mkdir('figures'); end

%% Load original patient counts (for weighting)
fprintf('Loading patient counts for weighting...\n');

rev_file = fullfile(sa_killing_folder, 'data', 'reversible_SAkilling.csv');
irrev_file = fullfile(sa_killing_folder, 'data', 'irreversible_SAkilling.csv');

if ~exist(rev_file, 'file') || ~exist(irrev_file, 'file')
    error('Cannot find SAkilling files. Please run g_ExtractInitialConditions.m first');
end

rev_data = readmatrix(rev_file);
irrev_data = readmatrix(irrev_file);

n_rev_original = size(rev_data, 1);
n_irrev_original = size(irrev_data, 1);
n_total_original = n_rev_original + n_irrev_original;

fprintf('  Reversible patients: %d\n', n_rev_original);
fprintf('  Irreversible patients: %d\n', n_irrev_original);
fprintf('  Total patients: %d\n\n', n_total_original);

%% Initialize results storage
results = struct();
results.SE_folds = SE_folds;
results.SA_folds = SA_folds;
results.reversible_recovery = zeros(size(SE_folds));
results.irreversible_recovery = zeros(size(SE_folds));
results.all_sites_recovery = zeros(size(SE_folds));

%% Main loop: Test each attenuation level
total_start = tic;

for level_idx = 1:length(SE_folds)
    SE_fold = SE_folds(level_idx);
    SA_fold = SA_folds(level_idx);
    
    fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
    fprintf('║  Level %d/%d: SE=%.1fx, SA=%.0fx (ratio %.1f:1)       \n', ...
            level_idx, length(SE_folds), SE_fold, SA_fold, SA_fold/SE_fold);
    fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
    
    % Storage for this level
    level_results = struct();
    
    for type_idx = 1:length(patient_types)
        patient_type = patient_types{type_idx};
        
        fprintf('--- %s patients ---\n\n', upper(patient_type));
        
        %% STAGE 1: Apply Attenuation
        fprintf('STAGE 1: Applying attenuation (SA=%.0fx, SE=%.1fx)...\n', SA_fold, SE_fold);
        stage1_start = tic;
        [AllVirtualPatientTypes, ~] = g_AttenuationFlexible(patient_type, SA_fold, SE_fold);
        stage1_time = toc(stage1_start);
        fprintf('✓ Complete (%.1f min)\n\n', stage1_time/60);
        
        %% STAGE 2: Count recoveries from attenuation
        fprintf('STAGE 2: Counting attenuation recoveries...\n');
        
        patient_ids = unique(AllVirtualPatientTypes(:, 1));
        n_total = length(patient_ids);
        
        n_recovered_attenuation = 0;
        damaged_patient_ids = [];
        
        for i = 1:n_total
            patient_id = patient_ids(i);
            patient_rows = AllVirtualPatientTypes(AllVirtualPatientTypes(:, 1) == patient_id, :);
            
            % Check if ALL states have B* = 1 (complete recovery)
            if all(patient_rows(:, 22) == 1)
                n_recovered_attenuation = n_recovered_attenuation + 1;
            else
                damaged_patient_ids = [damaged_patient_ids; patient_id];
            end
        end
        
        fprintf('  Total patients: %d\n', n_total);
        fprintf('  Recovered (attenuation): %d (%.1f%%)\n', ...
                n_recovered_attenuation, 100*n_recovered_attenuation/n_total);
        fprintf('  Still damaged: %d\n\n', length(damaged_patient_ids));
        
        %% STAGE 3: Extract and apply SA-killing if needed
        if isempty(damaged_patient_ids)
            fprintf('✓ All patients recovered from attenuation alone!\n');
            n_recovered_sa_killing = 0;
        else
            fprintf('STAGE 3: Extracting damaged patients...\n');
            
            % Extract damaged patients
            damaged_mask = ismember(AllVirtualPatientTypes(:, 1), damaged_patient_ids);
            damaged_data = AllVirtualPatientTypes(damaged_mask, :);
            
            % Save damaged data temporarily - create dummy files for both types
            temp_rev_file = fullfile('data', sprintf('temp_attenuation_reversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold));
            temp_irrev_file = fullfile('data', sprintf('temp_attenuation_irreversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold));
            
            if strcmp(patient_type, 'reversible')
                writematrix(damaged_data, temp_rev_file);
                writematrix([], temp_irrev_file);  % Empty irreversible file
            else
                writematrix([], temp_rev_file);    % Empty reversible file
                writematrix(damaged_data, temp_irrev_file);
            end
            
            % Use proper g_ExtractInitialConditions for worst-case extraction
            temp_rev_output = fullfile('data', sprintf('temp_initial_reversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold));
            temp_irrev_output = fullfile('data', sprintf('temp_initial_irreversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold));
            
            % Call g_ExtractInitialConditions with custom paths
            g_ExtractInitialConditions('data', 'data', ...
                                       sprintf('temp_attenuation_reversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold), ...
                                       sprintf('temp_attenuation_irreversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold), ...
                                       sprintf('temp_initial_reversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold), ...
                                       sprintf('temp_initial_irreversible_SE%.1f_SA%.0f.csv', SE_fold, SA_fold));
            
            % Load extracted initial conditions from appropriate file
            if strcmp(patient_type, 'reversible')
                initial_conditions = readmatrix(temp_rev_output);
            else
                initial_conditions = readmatrix(temp_irrev_output);
            end
            fprintf('  Extracted %d initial conditions\n', size(initial_conditions, 1));
            
            % Save temporarily for SA-killing
            temp_file = fullfile(sa_killing_folder, 'data', ...
                                 sprintf('panel_a_line_%s_SE%.1f_SA%.0f_temp.csv', ...
                                         patient_type, SE_fold, SA_fold));
            writematrix(initial_conditions, temp_file);
            
            % Apply FIXED SA-killing
            fprintf('  Applying SA-killing (strength=%.1f, duration=%.1f)...\n', ...
                    sa_killing_strength, sa_killing_duration);
            
            stage3_start = tic;
            frac_recovered = run_fixed_sa_killing(initial_conditions, ...
                                                   sa_killing_strength, ...
                                                   sa_killing_duration);
            stage3_time = toc(stage3_start);
            
            n_recovered_sa_killing = round(frac_recovered * length(damaged_patient_ids));
            
            fprintf('  ✓ Complete (%.1f min)\n', stage3_time/60);
            fprintf('  Recovered from SA-killing: %d (%.1f%%)\n', ...
                    n_recovered_sa_killing, 100*frac_recovered);
            
            % Cleanup temporary files
            temp_files_to_clean = {temp_file, temp_rev_file, temp_irrev_file, temp_rev_output, temp_irrev_output};
            for f = 1:length(temp_files_to_clean)
                if exist(temp_files_to_clean{f}, 'file')
                    delete(temp_files_to_clean{f});
                end
            end
        end
        
        %% Calculate total recovery
        n_total_recovered = n_recovered_attenuation + n_recovered_sa_killing;
        recovery_pct = 100 * n_total_recovered / n_total;
        
        fprintf('\n═══ TOTAL RECOVERY ═══\n');
        fprintf('  Attenuation: %d\n', n_recovered_attenuation);
        fprintf('  SA-killing: %d\n', n_recovered_sa_killing);
        fprintf('  TOTAL: %d / %d (%.1f%%)\n\n', n_total_recovered, n_total, recovery_pct);
        
        % Store results
        level_results.(patient_type).n_total = n_total;
        level_results.(patient_type).n_recovered = n_total_recovered;
        level_results.(patient_type).recovery_pct = recovery_pct;
    end
    
    %% Calculate weighted combined recovery
    n_rev_recovered = level_results.reversible.n_recovered;
    n_irrev_recovered = level_results.irreversible.n_recovered;
    n_rev_total = level_results.reversible.n_total;
    n_irrev_total = level_results.irreversible.n_total;
    
    % Weighted by original patient counts
    combined_pct = 100 * (n_rev_recovered + n_irrev_recovered) / (n_rev_total + n_irrev_total);
    
    % Store in results
    results.reversible_recovery(level_idx) = level_results.reversible.recovery_pct;
    results.irreversible_recovery(level_idx) = level_results.irreversible.recovery_pct;
    results.all_sites_recovery(level_idx) = combined_pct;
    
    fprintf('═══ COMBINED RESULTS (Level %d) ═══\n', level_idx);
    fprintf('  All sites: %.1f%%\n', combined_pct);
    fprintf('  Reversible: %.1f%%\n', level_results.reversible.recovery_pct);
    fprintf('  Irreversible: %.1f%%\n', level_results.irreversible.recovery_pct);
end

total_time = toc(total_start);

%% Save results
fprintf('\n\nSaving results...\n');
save('data/panel_a_line_results.mat', 'results');
fprintf('  ✓ data/panel_a_line_results.mat\n\n');

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║              DATA GENERATION COMPLETE                 ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

fprintf('Total time: %.1f hours\n\n', total_time/3600);

fprintf('Summary:\n');
fprintf('  All sites: %.1f%% - %.1f%%\n', ...
        min(results.all_sites_recovery), max(results.all_sites_recovery));
fprintf('  Reversible: %.1f%% - %.1f%%\n', ...
        min(results.reversible_recovery), max(results.reversible_recovery));
fprintf('  Irreversible: %.1f%% - %.1f%%\n\n', ...
        min(results.irreversible_recovery), max(results.irreversible_recovery));

fprintf('Next step: Run run_Panel_a_LineGraph_Plot.m to generate figure\n');

%% Helper Functions

function frac_recovered = run_fixed_sa_killing(initial_conditions, delta_AS, t_end)
    % Run fixed SA-killing treatment on all sites
    
    n_sites = size(initial_conditions, 1);
    
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
    
    n_success = 0;
    
    if use_parallel
        parfor i = 1:n_sites
            if test_treatment(initial_conditions(i, :), delta_AS, t_end, options, options_event)
                n_success = n_success + 1;
            end
        end
    else
        for i = 1:n_sites
            if test_treatment(initial_conditions(i, :), delta_AS, t_end, options, options_event)
                n_success = n_success + 1;
            end
        end
    end
    
    frac_recovered = n_success / n_sites;
end

function success = test_treatment(site_data, delta_AS, t_end, options, options_event)
    % Test treatment on single site
    
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
    
    S = 1;
    
    % Phase 1: SA-killing
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, ...
        delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, ...
        A_pth, kappa_B, delta_B, delta_BA, delta_BE, delta_AS, S), ...
        [0, t_end], [A_0, E_0, B_0], options);
    
    % Phase 2: Recovery
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
    
    % Phase 3: Stability
    A_stab = max(1, y2(end, 1) - 1);
    E_stab = max(1, y2(end, 2) - 1);
    B_final = y2(end, 3);
    
    [~, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t2(end), t1(end) + 1e6], [A_stab, E_stab, B_final], options);
    
    success = (y3(end, 3) == 1);
end