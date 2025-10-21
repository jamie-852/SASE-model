% g_Plot_AttenuationOnly.m
%
% Purpose: Generate attenuation heatmap figures (Figure S6b-d)
%
% Inputs:  data/AttenuationOnly_All_Sites.csv
%          data/AttenuationOnly_Irreversible.csv
%          data/AttenuationOnly_Reversible.csv
%
% Outputs: figures/FigureS6_AttenuationHeatmaps.png
%          figures/FigureS6_AttenuationHeatmaps.fig
%
% Usage:
%   g_Plot_AttenuationOnly()
%
% Author: Jamie Lee
% Date: October 14, 2025

function g_Plot_AttenuationOnly()
    
    clc;
    fprintf('=== Generating Attenuation Heatmap Figures ===\n\n');
    
    %% Load data
    fprintf('Loading data...\n');
    
    % Check files exist
    if ~exist('data/AttenuationOnly_All_Sites.csv', 'file')
        error('Data files not found!\nPlease run run_AttenuationOnly_supplementary.m first');
    end
    
    panel_b = readmatrix('data/AttenuationOnly_All_Sites.csv');
    panel_c = readmatrix('data/AttenuationOnly_Irreversible.csv');
    panel_d = readmatrix('data/AttenuationOnly_Reversible.csv');
    
    fprintf('  ✓ Loaded all data files\n\n');
    
    %% Configuration
    SA_folds = [1, 10, 20];
    SE_folds = [1, 10, 20];
    
    % Create sepia colormap (brown/tan gradient)
    sepia_colors = [
        0.15, 0.08, 0.03;   % Dark brown (low %)
        0.35, 0.22, 0.12;
        0.55, 0.40, 0.28;
        0.70, 0.58, 0.45;
        0.82, 0.72, 0.62;
        0.92, 0.86, 0.80    % Light tan (high %)
    ];
    sepia_map = interp1(linspace(0, 1, size(sepia_colors, 1)), sepia_colors, linspace(0, 1, 256));
    
    % Create output folder
    output_folder = 'figures';
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    %% Create figure with 3 panels
    fprintf('Generating heatmaps...\n');
    
    fig = figure('Position', [100, 100, 1600, 450], 'Color', 'white');
    
    % Panel (b): All damaged sites
    subplot(1, 3, 1);
    create_heatmap(panel_b, SA_folds, SE_folds, sepia_map, 'All Damaged Sites');
    
    % Panel (c): Irreversible sites
    subplot(1, 3, 2);
    create_heatmap(panel_c, SA_folds, SE_folds, sepia_map, 'Irreversible Sites');
    
    % Panel (d): Reversible sites
    subplot(1, 3, 3);
    create_heatmap(panel_d, SA_folds, SE_folds, sepia_map, 'Reversible Sites');
    
    %% Save figure
    fprintf('Saving figures...\n');
    saveas(fig, fullfile(output_folder, 'FigureS6_AttenuationHeatmaps.png'));
    saveas(fig, fullfile(output_folder, 'FigureS6_AttenuationHeatmaps.fig'));
    fprintf('  ✓ %s\n', fullfile(output_folder, 'FigureS6_AttenuationHeatmaps.png'));
    fprintf('  ✓ %s\n\n', fullfile(output_folder, 'FigureS6_AttenuationHeatmaps.fig'));

    close(fig);
    
    fprintf('=== Plotting Complete ===\n');
    fprintf('Generated 3-panel heatmap in %s/ folder\n\n', output_folder);
    
end

%% Helper function to create individual heatmap
function create_heatmap(data, SA_folds, SE_folds, colormap_data, plot_title)
    % Display heatmap
    imagesc(SA_folds, SE_folds, data);
    
    % Apply sepia colormap
    colormap(colormap_data);
    caxis([0, 100]);
    
    % Formatting
    set(gca, 'YDir', 'normal');
    set(gca, 'XTick', SA_folds, 'YTick', SE_folds);
    set(gca, 'FontSize', 14);
    set(gca, 'TickLength', [0, 0]);
    set(gca, 'LineWidth', 1.2);
    set(gca, 'XColor', 'black', 'YColor', 'black');
    
    % Labels
    xlabel('SA Attenuation', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0, 0, 0]);
    ylabel('SE Attenuation', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0, 0, 0]);
    title(plot_title, 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0, 0, 0]);
    
    % Add percentage text inside each cell
    for i = 1:length(SE_folds)
        for j = 1:length(SA_folds)
            value = round(data(i, j));
            
            % Choose text color for readability
            if value < 45
                text_color = [1, 1, 1];  % White
            else
                text_color = [0, 0, 0];  % Black
            end
            
            text(SA_folds(j), SE_folds(i), sprintf('%d', value), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'FontSize', 16, ...
                 'FontWeight', 'bold', ...
                 'Color', text_color);
        end
    end
    
    box on;
end