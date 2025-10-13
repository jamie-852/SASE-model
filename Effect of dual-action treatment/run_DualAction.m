% run_DualAction.m
%
% Complete workflow runner for dual-action treatment analysis
% 
% This script reproduces Figure 3b-d with attenuation-modified parameters:
%   1. Apply 20x attenuation to gamma_AB and gamma_EB
%   2. Extract damaged initial conditions
%   3. Apply SA-killing treatment (varying strength and duration)
%   4. Generate treatment response heatmaps
%
% Workflow:
%   STAGE 1: Attenuation (20x enhancement)
%   STAGE 2: Extract damaged initial conditions  
%   STAGE 3: SA-killing treatment simulations
%   STAGE 4: Generate plots (Figure 3 panels b, c, d)
%
% Prerequisites:
%   - Must have g_ExtractInitialConditions.m in '../Effect of SA-killing/' folder
%   - Helper functions in '../Analyse steady states/' folder
%   - ODE solver functions in '../Effect of SA-killing/' folder
%
% Outputs:
%   - data/attenuation_[type]_20x.csv
%   - data/dual_action_reversible_20x_initial.csv
%   - data/dual_action_irreversible_20x_initial.csv
%   - data/reversible_treatment_results_dual_action_20x.csv
%   - figures/Fig3_DualAction_20x_*.png
%
% Usage:
%   matlab -batch "run('run_DualAction.m')"
%
% Author: Jamie Lee
% Date: 13 October 2025

clc;
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║       Complete Dual-Action Treatment Workflow         ║\n');
fprintf('║          (Attenuation + SA-Killing)                   ║\n');
fprintf('║                                                       ║\n');
fprintf('║  Reproduces: Figure 3b-d (with attenuation)          ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Configuration
fold_change = 20;  % Attenuation enhancement

fprintf('═══ Configuration ═══\n');
fprintf('Attenuation fold: %dx\n', fold_change);
fprintf('Treatment parameter ranges (matching Figure 3):\n');
fprintf('  Strength: 0 to 5 days⁻¹ (step 1.0)\n');
fprintf('  Duration: 1 to 4 days (step 0.5)\n');
fprintf('\n');

%% User confirmation
fprintf('═══ Workflow Overview ═══\n');
fprintf('This analysis will:\n');
fprintf('  1. Run attenuation (20x) for irreversible patients\n');
fprintf('  2. Run attenuation (20x) for reversible patients\n');
fprintf('  3. Extract damaged initial conditions\n');
fprintf('  4. Run SA-killing treatment simulations\n');
fprintf('  5. Generate treatment response heatmaps\n');
fprintf('\n');
fprintf('⚠️  Note: Steps 1-2 may take several hours\n');
fprintf('⚠️  Note: Step 4 may take 1-2 hours\n');
fprintf('\n');
fprintf('Press any key to continue or Ctrl+C to cancel...\n');
pause;
fprintf('\n');

%% Save original directory
original_dir = pwd;

%% STAGE 1: Attenuation Treatment
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  STAGE 1: Attenuation Treatment (20x)                 ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

fprintf('--- Running attenuation for irreversible patients ---\n');
tic;
g_AttenuationOnly('irreversible', fold_change);
stage1a_time = toc;
fprintf('✓ Irreversible complete (%.1f minutes)\n\n', stage1a_time/60);

fprintf('--- Running attenuation for reversible patients ---\n');
tic;
g_AttenuationOnly('reversible', fold_change);
stage1b_time = toc;
fprintf('✓ Reversible complete (%.1f minutes)\n\n', stage1b_time/60);

fprintf('✓ STAGE 1 COMPLETE (Total: %.1f minutes)\n\n', (stage1a_time + stage1b_time)/60);

%% STAGE 2: Extract Initial Conditions
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  STAGE 2: Extract Damaged Initial Conditions         ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

fprintf('Calling g_ExtractInitialConditions from SA-killing folder...\n');
fprintf('Using attenuation outputs as input\n\n');

tic;
% Call the flexible g_ExtractInitialConditions from SA-killing folder
% with custom paths pointing to our attenuation outputs
cd('../Effect of SA-killing');

g_ExtractInitialConditions('../Effect of dual-action treatment/data', ...
                           '../Effect of dual-action treatment/data', ...
                           sprintf('attenuation_reversible_%dx.csv', fold_change), ...
                           sprintf('attenuation_irreversible_%dx.csv', fold_change), ...
                           sprintf('dual_action_reversible_%dx_initial.csv', fold_change), ...
                           sprintf('dual_action_irreversible_%dx_initial.csv', fold_change));

cd(original_dir);
stage2_time = toc;

fprintf('✓ STAGE 2 COMPLETE (%.1f seconds)\n\n', stage2_time);

%% STAGE 3: SA-Killing Treatment Simulations
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  STAGE 3: SA-Killing Treatment Simulations            ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

% We need to temporarily change to SA-killing folder to access ODE functions
% but we'll read/write files from our local directory
fprintf('Accessing ODE solver functions from SA-killing folder...\n');

% Add SA-killing folder to path (for ODE functions)
addpath('../Effect of SA-killing');

% Read initial conditions from LOCAL data folder
src_file = sprintf('data/dual_action_reversible_%dx_initial.csv', fold_change);

if ~exist(src_file, 'file')
    error('Cannot find %s\nStage 2 may have failed', src_file);
end

fprintf('Using initial conditions: %s\n\n', src_file);

fprintf('Running SA-killing treatment simulations...\n');
fprintf('⚠️  This may take 1-2 hours depending on your system\n\n');

tic;
run_treatment_dual_action(src_file, fold_change);
stage3_time = toc;

fprintf('✓ STAGE 3 COMPLETE (%.1f minutes)\n\n', stage3_time/60);

%% STAGE 4: Generate Plots
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  STAGE 4: Generate Treatment Response Heatmaps        ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

tic;
generate_plots_dual_action(fold_change);
stage4_time = toc;

fprintf('✓ STAGE 4 COMPLETE (%.1f seconds)\n\n', stage4_time);

%% Final Summary
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║           COMPLETE WORKFLOW FINISHED                  ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

total_time = stage1a_time + stage1b_time + stage2_time + stage3_time + stage4_time;

fprintf('═══ Execution Summary ═══\n');
fprintf('Total time: %.1f hours\n', total_time/3600);
fprintf('  Stage 1 (Attenuation):     %.1f min\n', (stage1a_time + stage1b_time)/60);
fprintf('  Stage 2 (Extract ICs):     %.0f sec\n', stage2_time);
fprintf('  Stage 3 (SA-killing):      %.1f min\n', stage3_time/60);
fprintf('  Stage 4 (Plotting):        %.0f sec\n', stage4_time);
fprintf('\n');

fprintf('═══ Output Files ═══\n');
fprintf('Attenuation results:\n');
fprintf('  → data/attenuation_irreversible_20x.csv\n');
fprintf('  → data/attenuation_reversible_20x.csv\n');
fprintf('\n');
fprintf('Initial conditions:\n');
fprintf('  → data/dual_action_reversible_20x_initial.csv\n');
fprintf('  → data/dual_action_irreversible_20x_initial.csv\n');
fprintf('\n');
fprintf('Treatment results:\n');
fprintf('  → data/reversible_treatment_results_dual_action_20x.csv\n');
fprintf('\n');
fprintf('Figures (Figure 3 panels with attenuation):\n');
fprintf('  → figures/Fig3_DualAction_20x_AllSites.png\n');
fprintf('  → figures/Fig3_DualAction_20x_Reversible.png\n');
fprintf('  → figures/Fig3_DualAction_20x_Irreversible.png\n');
fprintf('\n');

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║                      SUCCESS!                         ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');

%% ========================================================================
%% LOCAL FUNCTIONS
%% ========================================================================

%% Helper: Run treatment with custom input file
function run_treatment_dual_action(input_file, fold_change)
    % Wrapper for g_TreatmentResponse that uses dual-action initial conditions
    
    % Load patient data
    sites = readmatrix(input_file);
    n_sites = size(sites, 1);
    
    fprintf('Loaded %d reversible sites (after %dx attenuation)\n\n', n_sites, fold_change);
    
    % Treatment parameter ranges (matching Figure 3)
    delta_AS_start = 0;
    delta_AS_step = 1;
    delta_AS_end = 5;
    t_end_start = 1;
    t_end_step = 0.5;
    t_end_end = 4;
    
    % Generate treatment combinations
    treatment = [];
    for strength = delta_AS_start:delta_AS_step:delta_AS_end
        for duration = t_end_start:t_end_step:t_end_end
            treatment = [treatment; strength, duration];
        end
    end
    n_treatments = size(treatment, 1);
    
    fprintf('Treatment combinations: %d\n', n_treatments);
    fprintf('Total simulations: %d\n\n', n_treatments * n_sites);
    
    % Run simulations (similar to g_TreatmentResponse logic)
    options = odeset('NonNegative', 1, 'RelTol', 1e-4, 'AbsTol', 1e-4);
    options_event = odeset('NonNegative', 1, 'Events', @(t, y)f_EventHealthy(t, y), ...
                           'RelTol', 1e-4, 'AbsTol', 1e-4);
    
    frac_success = zeros(n_treatments, 1);
    S = 1;
    
    fprintf('Running simulations...\n');
    fprintf('Progress: [');
    
    for i = 1:n_treatments
        n_success = 0;
        
        parfor ii = 1:n_sites
            if simulate_single_site_dual(sites(ii, :), treatment(i, :), S, ...
                                   options, options_event)
                n_success = n_success + 1;
            end
        end
        
        frac_success(i) = n_success / n_sites;
        
        if mod(i, max(1, floor(n_treatments/50))) == 0
            fprintf('=');
        end
    end
    
    fprintf(']\n\n');
    
    % Save results to LOCAL data folder
    output_file = sprintf('data/reversible_treatment_results_dual_action_%dx.csv', fold_change);
    treat_plot = [treatment, frac_success];
    writematrix(treat_plot, output_file);
    
    fprintf('✓ Saved: %s\n', output_file);
end

%% Helper: Simulate single site (dual-action version)
function success = simulate_single_site_dual(site_data, treatment_params, S, options, options_event)
    % Same as g_TreatmentResponse but explicitly for dual-action data
    
    kappa_A  = site_data(3);    kappa_E  = site_data(10);
    A_max    = site_data(4);    E_max    = site_data(11);
    gamma_AB = site_data(5);    gamma_EB = site_data(12);  % Already enhanced!
    delta_AE = site_data(6);    delta_EA = site_data(13);
    A_th     = site_data(7);    E_th     = site_data(14);
    E_pth    = site_data(8);    A_pth    = site_data(15);
    gamma_AE = site_data(9);    kappa_B  = site_data(16);
    delta_B  = site_data(17);
    delta_BA = site_data(18);
    delta_BE = site_data(19);
    
    A_0 = site_data(20);
    E_0 = site_data(21);
    B_0 = site_data(22);
    
    if A_0 <= 1, A_0 = 0; end
    if E_0 <= 1, E_0 = 0; end
    
    delta_AS = treatment_params(1);
    t_end = treatment_params(2);
    
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, ...
        delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, ...
        A_pth, kappa_B, delta_B, delta_BA, delta_BE, delta_AS, S), ...
        [0, t_end], [A_0, E_0, B_0], options);
    
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
    
    A_stab = max(1, y2(end, 1) - 1);
    E_stab = max(1, y2(end, 2) - 1);
    B_final = y2(end, 3);
    
    [~, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t2(end), t1(end) + 1e6], [A_stab, E_stab, B_final], options);
    
    success = (y3(end, 3) == 1);
end

%% Helper: Generate plots with dual-action results
function generate_plots_dual_action(fold_change)
    % Modified version of g_Plot_Main for dual-action results
    % Saves to LOCAL figures folder
    
    % Input files from LOCAL data folder
    results_file = sprintf('data/reversible_treatment_results_dual_action_%dx.csv', fold_change);
    reversible_file = sprintf('data/dual_action_reversible_%dx_initial.csv', fold_change);
    irreversible_file = sprintf('data/dual_action_irreversible_%dx_initial.csv', fold_change);
    
    % Load data
    treat_plot = readmatrix(results_file);
    n_reversible = size(readmatrix(reversible_file), 1);
    n_irreversible = size(readmatrix(irreversible_file), 1);
    n_total = n_reversible + n_irreversible;
    
    fprintf('Patient counts (still damaged after attenuation):\n');
    fprintf('  Reversible: %d\n', n_reversible);
    fprintf('  Irreversible: %d\n', n_irreversible);
    fprintf('  Total: %d\n\n', n_total);
    
    % Extract data
    strengths = unique(treat_plot(:, 1));
    durations = unique(treat_plot(:, 2));
    reversible_success = treat_plot(:, 3);
    
    n_strengths = length(strengths);
    n_durations = length(durations);
    
    % Reshape
    M_reversible = reshape(reversible_success, [n_durations, n_strengths])';
    M_irreversible = zeros(size(M_reversible));
    
    weight_rev = n_reversible / n_total;
    weight_irrev = n_irreversible / n_total;
    M_all = weight_rev * M_reversible + weight_irrev * M_irreversible;
    
    % Generate plots in LOCAL figures folder
    output_folder = 'figures';
    mkdir(output_folder);
    
    fig_suffix = sprintf('DualAction_%dx', fold_change);
    
    create_heatmap_dual(M_all, durations, strengths, ...
        '% of all damaged sites that recover', ...
        sprintf('Fig3_%s_AllSites.png', fig_suffix), output_folder);
    
    create_heatmap_dual(M_reversible, durations, strengths, ...
        '% of reversible sites that recover', ...
        sprintf('Fig3_%s_Reversible.png', fig_suffix), output_folder);
    
    create_heatmap_dual(M_irreversible, durations, strengths, ...
        '% of irreversible sites that recover', ...
        sprintf('Fig3_%s_Irreversible.png', fig_suffix), output_folder);
    
    fprintf('✓ Generated 3 heatmaps in figures/ folder\n');
end

%% Helper: Create heatmap
function create_heatmap_dual(M, durations, strengths, title_text, filename, output_folder)
    fig = figure('Position', [100, 100, 600, 500]);
    
    x_range = [min(durations), max(durations)];
    y_range = [min(strengths), max(strengths)];
    M_round = round(M * 100, -1);
    
    clims = [0, 0.95];
    colormap('gray');
    imagesc(x_range, y_range, M, clims);
    colorbar;
    
    hold on;
    [C, h] = contour(M_round, 'w-', 'ShowText', 'on');
    clabel(C, h, 'FontSize', 15, 'color', 'w');
    h.LineWidth = 1;
    hold off;
    
    xlabel('Duration [days]', 'FontSize', 16);
    ylabel('Strength [days^{-1}]', 'FontSize', 16);
    title(title_text, 'FontSize', 14, 'FontWeight', 'bold');
    
    ax = gca;
    ax.TickLength = [0.05, 0.05];
    ax.LineWidth = 0.75;
    ax.FontSize = 16;
    set(gca, 'YDir', 'normal');
    
    output_path = fullfile(output_folder, filename);
    print(fig, output_path, '-dpng', '-r300');
    
    close(fig);
end