% g_Plot_Supplementary.m
%
% Purpose: Generate supplementary treatment response heatmaps with exact values
%          Shows percentage recovery in each cell (no contour lines)
%
% Inputs:  data/reversible_treatment_results.csv
%          data/reversible_SAkilling.csv (for patient counts)
%          data/irreversible_SAkilling.csv (for patient counts)
%
% Outputs: figures/SuppFig_AllSites.png
%          figures/SuppFig_Reversible.png
%          figures/SuppFig_Irreversible.png
%
% Usage:
%   g_Plot_Supplementary()
%
% Author: Jamie Lee
% Date: 11 October 2025

function g_Plot_Supplementary()
    
    clc;
    fprintf('=== Generating Supplementary Treatment Response Heatmaps ===\n\n');
    
    %% Setup
    fig_prefix = 'FigS2';
    
    % Input files
    results_file = 'data/reversible_treatment_results.csv';
    reversible_file = 'data/reversible_SAkilling.csv';
    irreversible_file = 'data/irreversible_SAkilling.csv';
    
    % Output folder
    output_folder = 'figures';
    mkdir(output_folder);
    
    %% Load data
    fprintf('Loading data...\n');
    
    % Check files exist
    if ~exist(results_file, 'file')
        error('Cannot find %s\nPlease run g_TreatmentResponse with supplementary parameters first', results_file);
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
    reversible_success = treat_plot(:, 3);
    
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
    
    %% Generate plots with exact values
    fprintf('Generating heatmaps with exact values...\n');
    
    % Plot 1: All damaged sites (weighted)
    create_heatmap_with_values(M_all, durations, strengths, ...
        '% of damaged skin sites that recover', ...
        sprintf('%s_AllSites.png', fig_prefix));
    fprintf('  ✓ Saved: %s\n', sprintf('%s/%s_AllSites.png', output_folder, fig_prefix));
    
    % Plot 2: Irreversible sites (all zeros)
    create_heatmap_with_values(M_irreversible, durations, strengths, ...
        '% of irreversible sites that recover', ...
        sprintf('%s_Irreversible.png', fig_prefix));
    fprintf('  ✓ Saved: %s\n', sprintf('%s/%s_Irreversible.png', output_folder, fig_prefix));
    
    % Plot 3: Reversible sites only
    create_heatmap_with_values(M_reversible, durations, strengths, ...
        '% of reversible sites that recover', ...
        sprintf('%s_Reversible.png', fig_prefix));
    fprintf('  ✓ Saved: %s\n', sprintf('%s/%s_Reversible.png', output_folder, fig_prefix));
    
    fprintf('\n=== Plotting Complete ===\n');
    fprintf('Generated 3 supplementary heatmaps in %s/ folder\n\n', output_folder);
    
end

%% Helper function to create heatmap with exact percentage values
function create_heatmap_with_values(M, durations, strengths, title_text, filename)
    
    % Ensure figures folder exists
    output_folder = 'figures';
    mkdir(output_folder);
    
    % Create figure
    fig = figure('Position', [100, 100, 800, 600]);
    
    % Duration range for x-axis
    x_range = [min(durations), max(durations)];
    
    % Strength range for y-axis
    y_range = [min(strengths), max(strengths)];
    
    % Plot heatmap
    clims = [0, 1.0];
    colormap('gray');
    imagesc(x_range, y_range, M, clims);
    
    % Add text labels showing exact percentages
    [n_rows, n_cols] = size(M);
    
    % Calculate actual positions for text
    dur_vals = linspace(min(durations), max(durations), n_cols);
    str_vals = linspace(min(strengths), max(strengths), n_rows);
    
    for i = 1:n_rows
        for j = 1:n_cols
            % Get percentage value
            pct_value = round(M(i, j) * 100);
            
            % Choose text color based on background (white for dark, black for light)
            if M(i, j) < 0.5
                text_color = 'w';
            else
                text_color = 'k';
            end
            
            % Add text at center of cell
            text(dur_vals(j), str_vals(i), sprintf('%d', pct_value), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 12, ...
                'FontWeight', 'bold', ...
                'Color', text_color);
        end
    end
    
    % Add colorbar
    colorbar;
    
    % Labels and formatting
    xlabel('Duration [days]', 'FontSize', 16);
    ylabel('Strength [days^{-1}]', 'FontSize', 16);
    title(title_text, 'FontSize', 14, 'FontWeight', 'bold');
    
    ax = gca;
    ax.TickLength = [0.05, 0.05];
    ax.LineWidth = 0.75;
    ax.FontSize = 16;
    set(gca, 'YDir', 'normal');
    
    % Set axis ticks to match data points
    set(gca, 'XTick', durations);
    set(gca, 'YTick', strengths);
    
    % Save figure
    output_path = fullfile(output_folder, filename);
    print(fig, output_path, '-dpng', '-r300');
    
    close(fig);
    
end