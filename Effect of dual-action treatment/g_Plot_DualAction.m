% g_Plot_DualAction.m
%
% Purpose: Generate treatment response heatmaps for dual-action treatment
%          Creates 3 plots: All sites, Reversible only, Irreversible only
%
% Inputs:  data/reversible_treatment_results_dual_action.csv
%          data/irreversible_treatment_results_dual_action.csv
%          data/attenuation_recovery_stats.csv
%
% Outputs: figures/Figure5_AllSites.png
%          figures/Figure5_Reversible.png
%          figures/Figure5_Irreversible.png
%
% Usage:
%   g_Plot_DualAction()              % Default figure names
%   g_Plot_DualAction('Figure5')     % Custom prefix
%
% Author: Jamie Lee
% Date: October 20, 2025

function g_Plot_DualAction(fig_prefix)
    
    clc;
    fprintf('=== Generating Dual-Action Treatment Heatmaps ===\n\n');
    
    %% Setup
    if nargin < 1
        fig_prefix = 'Figure5';
    end
    
    % Input files
    rev_results_file = 'data/reversible_treatment_results_dual_action.csv';
    irrev_results_file = 'data/irreversible_treatment_results_dual_action.csv';
    attenuation_stats_file = 'data/attenuation_recovery_stats.csv';
    
    % Output folder
    output_folder = 'figures';
    mkdir(output_folder);  % Create folder (no error if exists)
    
    %% Load data
    fprintf('Loading data...\n');
    
    % Check files exist
    if ~exist(rev_results_file, 'file')
        error('Cannot find %s\nPlease run run_DualAction_Simplified.m first', rev_results_file);
    end
    if ~exist(irrev_results_file, 'file')
        error('Cannot find %s\nPlease run run_DualAction_Simplified.m first', irrev_results_file);
    end
    if ~exist(attenuation_stats_file, 'file')
        error('Cannot find %s\nPlease run run_DualAction_Simplified.m first', attenuation_stats_file);
    end
    
    % Load treatment results
    rev_results = readmatrix(rev_results_file);
    irrev_results = readmatrix(irrev_results_file);
    fprintf('  ✓ Loaded treatment results: %d combinations\n', size(rev_results, 1));
    
    % Load attenuation statistics
    stats = readmatrix(attenuation_stats_file);
    % stats format: [type_code, recovery_fraction, n_recovered, n_total]
    % type_code: 1 = reversible, 0 = irreversible
    
    reversible_row = stats(stats(:, 1) == 1, :);
    irreversible_row = stats(stats(:, 1) == 0, :);
    
    n_reversible = reversible_row(4);    % Total patients
    n_irreversible = irreversible_row(4); % Total patients
    n_total = n_reversible + n_irreversible;
    
    fprintf('  ✓ Patient counts (from attenuation analysis):\n');
    fprintf('    Reversible: %d (%.1f%%)\n', n_reversible, 100*n_reversible/n_total);
    fprintf('    Irreversible: %d (%.1f%%)\n', n_irreversible, 100*n_irreversible/n_total);
    fprintf('    Total: %d\n\n', n_total);
    
    %% Extract treatment parameters and account for attenuation recovery
    strengths = unique(rev_results(:, 1));
    durations = unique(rev_results(:, 2));
    reversible_success_sa_only = rev_results(:, 3);  % Success rate for SA-killing on damaged sites
    irreversible_success_sa_only = irrev_results(:, 3);  % Success rate for SA-killing on damaged sites
    
    n_strengths = length(strengths);
    n_durations = length(durations);
    
    fprintf('Treatment parameter space:\n');
    fprintf('  Strength: %.1f to %.1f (n=%d)\n', min(strengths), max(strengths), n_strengths);
    fprintf('  Duration: %.1f to %.1f days (n=%d)\n\n', min(durations), max(durations), n_durations);
    
    % Extract attenuation recovery rates (already loaded above)
    attenuation_recovery_rev = reversible_row(2);     % Recovery fraction
    attenuation_recovery_irrev = irreversible_row(2); % Recovery fraction
    
    fprintf('Attenuation-only recovery rates (from pipeline):\n');
    fprintf('  Reversible: %.1f%% (%d/%d patients)\n', attenuation_recovery_rev*100, reversible_row(3), n_reversible);
    fprintf('  Irreversible: %.1f%% (%d/%d patients)\n', attenuation_recovery_irrev*100, irreversible_row(3), n_irreversible);
    
    % Calculate TOTAL dual-action success rates
    % Total success = attenuation_recovery + (1 - attenuation_recovery) * sa_killing_success
    reversible_success_total = attenuation_recovery_rev + (1 - attenuation_recovery_rev) * reversible_success_sa_only;
    irreversible_success_total = attenuation_recovery_irrev + (1 - attenuation_recovery_irrev) * irreversible_success_sa_only;
    
    fprintf('\nTotal dual-action success ranges:\n');
    fprintf('  Reversible: %.1f%% - %.1f%%\n', min(reversible_success_total)*100, max(reversible_success_total)*100);
    fprintf('  Irreversible: %.1f%% - %.1f%%\n\n', min(irreversible_success_total)*100, max(irreversible_success_total)*100);
    
    %% Reshape data into matrices for plotting
    M_reversible = reshape(reversible_success_total, [n_durations, n_strengths])';
    M_irreversible = reshape(irreversible_success_total, [n_durations, n_strengths])';
    
    % Calculate weighted average for "all sites"
    weight_rev = n_reversible / (n_reversible + n_irreversible);
    weight_irrev = n_irreversible / (n_reversible + n_irreversible);
    M_all = weight_rev * M_reversible + weight_irrev * M_irreversible;
    
    %% Generate plots
    fprintf('Generating heatmaps...\n');
    
    % Plot 1: All damaged sites (weighted)
    create_heatmap(M_all, durations, strengths, ...
        '% of all damaged sites that recover', ...
        sprintf('%s_AllSites.png', fig_prefix));
    fprintf('  ✓ Saved: %s\n', sprintf('%s/%s_AllSites.png', output_folder, fig_prefix));
    
    % Plot 2: Reversible sites only
    create_heatmap(M_reversible, durations, strengths, ...
        '% of reversible sites that recover', ...
        sprintf('%s_Reversible.png', fig_prefix));
    fprintf('  ✓ Saved: %s\n', sprintf('%s/%s_Reversible.png', output_folder, fig_prefix));
    
    % Plot 3: Irreversible sites
    create_heatmap(M_irreversible, durations, strengths, ...
        '% of irreversible sites that recover', ...
        sprintf('%s_Irreversible.png', fig_prefix));
    fprintf('  ✓ Saved: %s\n', sprintf('%s/%s_Irreversible.png', output_folder, fig_prefix));
    
    fprintf('\n=== Plotting Complete ===\n');
    fprintf('Generated 3 heatmaps in %s/ folder\n\n', output_folder);
    
end

%% Helper function to create and save heatmap
function create_heatmap(M, durations, strengths, title_text, filename)
    
    % Ensure figures folder exists
    output_folder = 'figures';
    mkdir(output_folder);
    
    fig = figure('Position', [100, 100, 600, 500]);
    
    % Duration range for x-axis
    x_range = [min(durations), max(durations)];
    
    % Strength range for y-axis
    y_range = [min(strengths), max(strengths)];
    
    % Convert to percentage and define contour levels (every 10%)
    M_percent = M * 100;
    contour_levels = 40:10:90;  % 40%, 50%, 60%, 70%, 80%, 90%
    
    % Plot heatmap
    clims = [0, 95];  % 0% to 95%
    colormap('gray');
    imagesc(x_range, y_range, M_percent, clims);
    colorbar;
    
    % Add contour lines at specific levels only
    hold on;
    [C, h] = contour(M_percent, contour_levels, 'k-', 'LineWidth', 1.5);  % Black contours
    clabel(C, h, 'FontSize', 14, 'Color', 'k', 'FontWeight', 'bold', ...
           'LabelSpacing', 200);  % Black labels with better spacing
    hold off;
    
    % Labels and formatting
    xlabel('Duration [days]', 'FontSize', 16);
    ylabel('Strength [days^{-1}]', 'FontSize', 16);
    title(title_text, 'FontSize', 14, 'FontWeight', 'bold');
    
    ax = gca;
    ax.TickLength = [0.05, 0.05];
    ax.LineWidth = 0.75;
    ax.FontSize = 16;
    set(gca, 'YDir', 'normal');
    
    % Save figure
    output_path = fullfile(output_folder, filename);
    print(fig, output_path, '-dpng', '-r300');
    
    close(fig);
    
end