% run_Panel_a_Plot.m
%
% Purpose: Generate treatment response heatmaps for Panel (a)
%          Creates 3 plots: All sites, Reversible only, Irreversible only
%
% Inputs:  data/reversible_dual_action.csv
%          data/irreversible_dual_action.csv
%          ../Effect of SA killing/data/reversible_SAkilling.csv (for patient counts)
%          ../Effect of SA killing/data/irreversible_SAkilling.csv (for patient counts)
%
% Outputs: figures/Panel_a_AllSites.png
%          figures/Panel_a_Reversible.png
%          figures/Panel_a_Irreversible.png
%
% Author: Jamie Lee
% Date: October 15, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║    Panel (a): Treatment Response Heatmaps            ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Setup
% Input files
results_file_rev = 'data/reversible_dual_action.csv';
results_file_irrev = 'data/irreversible_dual_action.csv';
reversible_file = '../Effect of SA-killing/data/reversible_SAkilling.csv';
irreversible_file = '../Effect of SA-killing/data/irreversible_SAkilling.csv';

% Output folder
output_folder = 'figures';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% Load data
fprintf('Loading data...\n');

% Check files exist
if ~exist(results_file_rev, 'file')
    error('Cannot find %s\nPlease run run_Panel_a_DataGeneration.m first', results_file_rev);
end
if ~exist(results_file_irrev, 'file')
    error('Cannot find %s\nPlease run run_Panel_a_DataGeneration.m first', results_file_irrev);
end
if ~exist(reversible_file, 'file')
    error('Cannot find %s\nPlease run SA killing analysis first', reversible_file);
end
if ~exist(irreversible_file, 'file')
    error('Cannot find %s\nPlease run SA killing analysis first', irreversible_file);
end

% Load treatment results
treat_reversible = readmatrix(results_file_rev);
treat_irreversible = readmatrix(results_file_irrev);
fprintf('  ✓ Loaded treatment results: %d combinations\n', size(treat_reversible, 1));

% Count patients for weighted average
n_reversible = size(readmatrix(reversible_file), 1);
n_irreversible = size(readmatrix(irreversible_file), 1);
n_total = n_reversible + n_irreversible;

fprintf('  ✓ Patient counts:\n');
fprintf('    Reversible: %d (%.1f%%)\n', n_reversible, 100*n_reversible/n_total);
fprintf('    Irreversible: %d (%.1f%%)\n', n_irreversible, 100*n_irreversible/n_total);
fprintf('    Total: %d\n\n', n_total);

%% Extract treatment parameters
strengths = unique(treat_reversible(:, 1));
durations = unique(treat_reversible(:, 2));
reversible_success = treat_reversible(:, 3);
irreversible_success = treat_irreversible(:, 3);

n_strengths = length(strengths);
n_durations = length(durations);

fprintf('Treatment parameter space:\n');
fprintf('  Strength: %.1f to %.1f days^{-1} (n=%d)\n', min(strengths), max(strengths), n_strengths);
fprintf('  Duration: %.1f to %.1f days (n=%d)\n\n', min(durations), max(durations), n_durations);

%% Reshape data into matrices for plotting
M_reversible = reshape(reversible_success, [n_durations, n_strengths])';
M_irreversible = reshape(irreversible_success, [n_durations, n_strengths])';

% Calculate weighted average for "all sites"
weight_rev = n_reversible / n_total;
weight_irrev = n_irreversible / n_total;
M_all = weight_rev * M_reversible + weight_irrev * M_irreversible;

fprintf('Calculated weighted average:\n');
fprintf('  Weight for reversible: %.1f%%\n', weight_rev * 100);
fprintf('  Weight for irreversible: %.1f%%\n\n', weight_irrev * 100);

%% Generate plots
fprintf('Generating heatmaps...\n');

% Plot 1: All damaged sites (weighted)
create_heatmap(M_all, durations, strengths, ...
    '{\bf b}  % of {\bf all damaged} sites that recover', ...
    'Panel_a_AllSites.png');
fprintf('  ✓ Saved: %s\n', fullfile(output_folder, 'Panel_a_AllSites.png'));

% Plot 2: Reversible sites only
create_heatmap(M_reversible, durations, strengths, ...
    '{\bf c}  % of {\bf reversible} sites that recover', ...
    'Panel_a_Reversible.png');
fprintf('  ✓ Saved: %s\n', fullfile(output_folder, 'Panel_a_Reversible.png'));

% Plot 3: Irreversible sites
create_heatmap(M_irreversible, durations, strengths, ...
    '{\bf d}  % of {\bf irreversible} sites that recover', ...
    'Panel_a_Irreversible.png');
fprintf('  ✓ Saved: %s\n', fullfile(output_folder, 'Panel_a_Irreversible.png'));

fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║              HEATMAP GENERATION COMPLETE              ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');
fprintf('Generated 3 heatmaps in %s/ folder\n\n', output_folder);

%% Helper function to create and save heatmap
function create_heatmap(M, durations, strengths, title_text, filename)
    
    % Ensure figures folder exists
    output_folder = 'figures';
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Create figure
    fig = figure('Position', [100, 100, 650, 550], 'Color', 'white');
    
    % Duration range for x-axis
    x_range = [min(durations), max(durations)];
    
    % Strength range for y-axis
    y_range = [min(strengths), max(strengths)];
    
    % Round for contour labels (nearest 10%)
    M_round = round(M, -1);
    
    % Plot heatmap with grayscale colormap
    clims = [0, 95];
    colormap('gray');
    imagesc(x_range, y_range, M, clims);
    
    % Add colorbar
    cb = colorbar;
    cb.Label.String = 'Recovery Rate (%)';
    cb.Label.FontSize = 14;
    cb.Label.FontWeight = 'bold';
    
    % Add white contour lines with labels
    hold on;
    [C, h] = contour(M_round, 'w-', 'ShowText', 'on');
    clabel(C, h, 'FontSize', 15, 'Color', 'w', 'FontWeight', 'bold');
    h.LineWidth = 1.5;
    hold off;
    
    % Labels and formatting
    xlabel('{\bf Duration} [days]', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0, 0.5, 0]);
    ylabel('{\bf Strength} [days^{-1}]', 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0, 0.5, 0]);
    title(title_text, 'FontSize', 14, 'FontWeight', 'normal');
    
    % Axis formatting
    ax = gca;
    ax.TickLength = [0.02, 0.02];
    ax.LineWidth = 1.2;
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    set(gca, 'YDir', 'normal');
    
    % Grid
    grid on;
    box on;
    
    % Save figure
    output_path = fullfile(output_folder, filename);
    print(fig, output_path, '-dpng', '-r300');
    saveas(fig, strrep(output_path, '.png', '.fig'));
    
    close(fig);
    
end