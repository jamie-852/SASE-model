% run_Panel_a_LineGraph_Plot.m
%
% Generate line graph for Panel (a): Recovery vs. attenuation strength
%
% Requires: data/panel_a_line_results.mat (from run_Panel_a_LineGraph_DataGeneration.m)
%
% Output: figures/Panel_a_LineGraph.png
%
% Author: Jamie Lee
% Date: October 15, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║       Panel (a): Generating Line Graph               ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Load data
fprintf('Loading data...\n');

if ~exist('data/panel_a_line_results.mat', 'file')
    error('Data file not found!\nPlease run run_Panel_a_LineGraph_DataGeneration.m first');
end

load('data/panel_a_line_results.mat', 'results');

fprintf('  ✓ Loaded results\n\n');

%% Create figure
fig = figure('Position', [100, 100, 600, 500], 'Color', 'white');

%% Plot data with filled circles
hold on;

% Plot all three lines with black filled circles
h_all = plot(results.SA_folds, results.all_sites_recovery, '-o', ...
             'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'black', ...
             'MarkerEdgeColor', 'black', 'Color', 'black', ...
             'DisplayName', 'All damaged sites');

h_rev = plot(results.SA_folds, results.reversible_recovery, '-o', ...
             'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.5, 0.5], ...
             'MarkerEdgeColor', 'black', 'Color', [0.5, 0.5, 0.5], ...
             'DisplayName', 'Reversible');

h_irrev = plot(results.SA_folds, results.irreversible_recovery, '-o', ...
               'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', [0.8, 0.8, 0.8], ...
               'MarkerEdgeColor', 'black', 'Color', [0.8, 0.8, 0.8], ...
               'DisplayName', 'Irreversible');

hold off;

%% Format primary x-axis (SA attenuation)
xlabel('{\bf Strength of}\newline{\bf SA attenuation}', ...
       'FontSize', 14, 'FontWeight', 'bold', 'Color', [0, 0, 0.8]);
set(gca, 'XTick', results.SA_folds);
xlim([0, max(results.SA_folds) + 2]);

%% Format y-axis
ylabel('{\bf % of all damaged sites}\newline{\bf that recover}', ...
       'FontSize', 14, 'FontWeight', 'bold');
ylim([30, 90]);
set(gca, 'YTick', 30:10:90);
set(gca, 'FontSize', 14);

%% Add secondary x-axis (SE attenuation) at top
ax1 = gca;
ax2 = axes('Position', ax1.Position, ...
           'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', ...
           'Color', 'none');

% Link axes
linkaxes([ax1, ax2], 'y');
ax2.YLim = ax1.YLim;
ax2.YTick = [];

% Set SE values on top axis
ax2.XLim = ax1.XLim;
ax2.XTick = results.SA_folds;
ax2.XTickLabel = arrayfun(@(x) sprintf('%.1f', x), results.SE_folds, 'UniformOutput', false);
ax2.FontSize = 14;

xlabel(ax2, '{\bf Strength of}\newline{\bf SE attenuation}', ...
       'FontSize', 14, 'FontWeight', 'bold', 'Color', [0, 0, 0.8]);

%% Add legend
legend([h_all, h_rev, h_irrev], 'Location', 'southeast', 'FontSize', 11);

%% Grid
grid(ax1, 'on');
box(ax1, 'on');

%% Add panel label
text(-5, 88, '{\bf a}', 'FontSize', 20, 'FontWeight', 'bold', 'Units', 'data');

%% Save figure
fprintf('Saving figure...\n');
saveas(fig, 'figures/Panel_a_LineGraph.png');
saveas(fig, 'figures/Panel_a_LineGraph.fig');
fprintf('  ✓ figures/Panel_a_LineGraph.png\n');
fprintf('  ✓ figures/Panel_a_LineGraph.fig\n\n');

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║                   FIGURE COMPLETE                     ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');