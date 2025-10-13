% g_Plot_Main.m
%
% Purpose: Generate treatment response heatmaps (Figure 3)
%          Creates 3 plots: All sites, Reversible only, Irreversible only
%
% Inputs:  data/reversible_treatment_results.csv
%          data/reversible_SAkilling.csv (for patient counts)
%          data/irreversible_SAkilling.csv (for patient counts)
%
% Outputs: figures/Fig3_AllSites.png
%          figures/Fig3_Reversible.png
%          figures/Fig3_Irreversible.png
%
% Usage:
%   g_Plot()              % Default figure names
%   g_Plot('Supp')        % For supplementary figures (adds prefix)
%
% Author: Jamie Lee
% Date: 10 October 2025
% Version: 2.0 - Refactored for reproducibility

function g_Plot_Main(fig_prefix)
    
    clc;
    fprintf('=== Generating Treatment Response Heatmaps ===\n\n');
    
    %% Setup
    if nargin < 1
        fig_prefix = 'Fig3';
    end
    
    % Input files
    results_file = 'data/reversible_treatment_results.csv';
    reversible_file = 'data/reversible_SAkilling.csv';
    irreversible_file = 'data/irreversible_SAkilling.csv';
    
    % Output folder
    output_folder = 'figures';
    mkdir(output_folder);  % Create folder (no error if exists)
    
    %% Load data
    fprintf('Loading data...\n');
    
    % Check files exist
    if ~exist(results_file, 'file')
        error('Cannot find %s\nPlease run g_TreatmentResponse.m first', results_file);
    end
    if ~exist(reversible_file, 'file')
        error('Cannot find %s\nPlease run g_ExtractInitialConditions.m first', reversible_file);
    end
    if ~exist(irreversible_file, 'file')
        error('Cannot find %s\nPlease run g_ExtractInitialConditions.m first', irreversible_file);
    end
    
    % Load treatment results
    treat_plot = readmatrix(results_file);
    fprintf('  ✓ Loaded treatment results: %d combinations\n', size(treat_plot, 1));
    
    % Count patients for weighted average
    n_reversible = size(readmatrix(reversible_file), 1);
    n_irreversible = size(readmatrix(irreversible_file), 1);
    n_total = n_reversible + n_irreversible;
    
    fprintf('  ✓ Patient counts:\n');
    fprintf('    Reversible: %d (%.1f%%)\n', n_reversible, 100*n_reversible/n_total);
    fprintf('    Irreversible: %d (%.1f%%)\n', n_irreversible, 100*n_irreversible/n_total);
    fprintf('    Total: %d\n\n', n_total);
    
    %% Extract treatment parameters
    strengths = unique(treat_plot(:, 1));
    durations = unique(treat_plot(:, 2));
    reversible_success = treat_plot(:, 3);  % FIX: Was column 4, should be 3
    
    n_strengths = length(strengths);
    n_durations = length(durations);
    
    fprintf('Treatment parameter space:\n');
    fprintf('  Strength: %.1f to %.1f (n=%d)\n', min(strengths), max(strengths), n_strengths);
    fprintf('  Duration: %.1f to %.1f days (n=%d)\n\n', min(durations), max(durations), n_durations);
    
    %% Reshape data into matrices for plotting
    M_reversible = reshape(reversible_success, [n_durations, n_strengths])';
    M_irreversible = zeros(size(M_reversible));  % All zeros (never recover)
    
    % Calculate weighted average for "all sites"
    weight_rev = n_reversible / n_total;
    weight_irrev = n_irreversible / n_total;
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
    
    % Plot 3: Irreversible sites (all zeros)
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
    
    % Round for contour labels (nearest 10%)
    M_round = round(M * 100, -1);
    
    % Plot heatmap
    clims = [0, 0.95];
    colormap('gray');
    imagesc(x_range, y_range, M, clims);
    colorbar;
    
    % Add contour lines
    hold on;
    [C, h] = contour(M_round, 'w-', 'ShowText', 'on');
    clabel(C, h, 'FontSize', 15, 'color', 'w');
    h.LineWidth = 1;
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