% plot_violin_parameters.m
%
% Purpose: Create violin plots for model parameters across patient types
%
% Usage:
%   plot_violin_parameters('all')        % All patients
%   plot_violin_parameters('SE_damaging')     % Only with damage
%   plot_violin_parameters('SE_nondamaging')  % Only without damage
%
% Author: Jamie Lee
% Date: 7 October 2025

function plot_violin_parameters(filter_mode)
    
    if nargin < 1
        filter_mode = 'all';
    end
    
    clc;
    fprintf('=== Generating Violin Plots (%s) ===\n\n', filter_mode);
    
    %% Load data
    fprintf('[1/3] Loading data...\n');
    
    asymp_raw = readmatrix('asymp.csv');
    rev_raw = readmatrix('reversible.csv');
    irrev_raw = readmatrix('irreversible.csv');
    
    % Keep only first 19 columns
    asymp_raw = asymp_raw(:, 1:19);
    rev_raw = rev_raw(:, 1:19);
    irrev_raw = irrev_raw(:, 1:19);
    
    %% Filter based on mode
    fprintf('[2/3] Filtering data (mode: %s)...\n', filter_mode);
    
    switch filter_mode
        case 'all'
            % Original script behavior
            asymp = asymp_raw;
            reversible = unique(rev_raw, 'rows', 'stable');
            irreversible = unique(irrev_raw, 'rows', 'stable');
            
        case 'SE_damaging'
            % Keep only samples WITH skin damaging SE strains (delta_BE > 0, column 19)
            asymp = asymp_raw(asymp_raw(:, 19) > 0, :);
            reversible = rev_raw(rev_raw(:, 19) > 0, :);
            irreversible = irrev_raw(irrev_raw(:, 19) > 0, :);
            
        case 'SE_nondamaging'
            % Keep only samples WITHOUT skin damaging SE strains (delta_BE == 0, column 19)
            asymp = asymp_raw(asymp_raw(:, 19) == 0, :);
            reversible = rev_raw(rev_raw(:, 19) == 0, :);
            irreversible = irrev_raw(irrev_raw(:, 19) == 0, :);
            
        otherwise
            error('Invalid filter_mode. Use: ''all'', ''SE_damaging'', or ''SE_nondamaging''');
    end
    
    fprintf('  Asymptomatic: %d samples\n', size(asymp, 1));
    fprintf('  Reversible:   %d samples\n', size(reversible, 1));
    fprintf('  Irreversible: %d samples\n', size(irreversible, 1));
    
    %% Prepare plot data
    fprintf('[3/3] Creating violin plots...\n');
    
    % Define parameters to plot
    % Format: {column, ylabel, ytick_values, ytick_labels}
    parameters = {
        3,  'SA growth', [log10(9), log10(27)], {'9', '27'};
        5,  'Skin inhibition of SA growth', [log10(58.7), log10(5870)], {'58.7', '5870'};
        6,  'SA killing by SE', [log10(4.78), log10(478)], {'4.78', '478'};
        7,  'SA QS threshold', [log10(1.13e7), log10(1.13e9)], {'1.13\times10^{7}', '1.13\times10^{9}'};
        8,  'SE required to kill SA at half-strength', [log10(1.13e7), log10(1.13e9)], {'1.13\times10^{7}', '1.13\times10^{9}'};
        10, 'SE growth', [log10(9), log10(27)], {'9', '27'};
        12, 'Skin inhibition of SE growth', [log10(55.8), log10(5580)], {'55.8', '5580'};
        13, 'SE killing by SA', [log10(4.78), log10(478)], {'4.78', '478'};
        14, 'SE QS threshold', [log10(1.13e7), log10(1.13e9)], {'1.13\times10^{7}', '1.13\times10^{9}'};
        15, 'SA required to kill SE at half-strength', [log10(1.13e7), log10(1.13e9)], {'1.13\times10^{7}', '1.13\times10^{9}'};
        9,  'Strength of SA QS inhibition by SE', [log10(1.30e-9), log10(1.30e-7)], {'1.30\times10^{-9}', '1.30\times10^{-7}'};
        16, 'Skin recovery', [log10(0.0711*1e-1), log10(0.0711*10)], {'0.711\times10^{-2}', '0.711'};
        17, 'Skin desquamation', [log10(0.00289), log10(0.289)], {'0.289\times10^{-2}', '0.289'};
        18, 'Skin damage by SA', [log10(1e-10), log10(1e-8)], {'1\times10^{-10}', '1\times10^{-8}'};
        19, 'Skin damage by SE', [log10(1e-10), log10(1e-8)], {'1\times10^{-10}', '1\times10^{-8}'};
    };
    
    % Patient type labels
    PatientTypes = {'A', 'R', 'I'};
    
    % Colors: Asymptomatic (orange), Reversible (gray), Irreversible (red)
    violin_colors = [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255];
    
    %% Create figure
    figure(1); clf;
    set(gcf, 'Position', [100, 100, 1400, 900]);
    
    % Plot each parameter
    for idx = 1:length(parameters)
        col = parameters{idx, 1};
        ylabel_text = parameters{idx, 2};
        ytick_vals = parameters{idx, 3};
        ytick_labs = parameters{idx, 4};
        
        % Skip delta_BE if no damage data
        if col == 19 && strcmp(filter_mode, 'SE_nondamaging')
            continue;
        end
        
        % Create subplot
        subplot(3, 5, idx);
        
        % Prepare data for this parameter
        input_data = prepare_parameter_data(asymp, reversible, irreversible, col);
        
        % Create violin plot
        violinplot(input_data, PatientTypes, ...
            'Width', 0.25, ...
            'ViolinColor', violin_colors, ...
            'EdgeColor', [1,1,1], ...
            'ShowData', false, ...
            'ShowBox', false, ...
            'ShowWhiskers', false, ...
            'MedianColor', [0, 0, 0]);
        
        % Format axes
        yticks(ytick_vals);
        yticklabels(ytick_labs);
        
        ax = gca;
        ax.TickLength = [0.03, 0.03];
        ax.LineWidth = 0.75;
        ax.XAxis.FontSize = 12;
        
        ylabel(ylabel_text, 'FontSize', 12);
        
        % Rotate plot
        camroll(-90);
    end
    
    % Add title
    title_text = sprintf('Parameter Distributions Across Patient Types (%s)', filter_mode);
    sgtitle(title_text, 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    output_file = sprintf('ViolinPlots_%s.png', filter_mode);
    print(output_file, '-dpng', '-r300');
    fprintf('✓ Figure saved as: %s\n\n', output_file);
end

%% Helper function to prepare data for one parameter
function input_data = prepare_parameter_data(asymp, reversible, irreversible, col)
    % Extract parameter values
    a_param = asymp(:, col);
    r_param = reversible(:, col);
    i_param = irreversible(:, col);
    
    % Special handling for delta_BE (column 19) - remove zeros
    if col == 19
        a_param = a_param(a_param > 0);
        r_param = r_param(r_param > 0);
        i_param = i_param(i_param > 0);
    end
    
    % Log transform
    a_param = log10(a_param);
    r_param = log10(r_param);
    i_param = log10(i_param);
    
    % Create matrix (columns: Asymptomatic, Reversible, Irreversible)
    max_len = max([length(a_param), length(r_param), length(i_param)]);
    input_data = NaN(max_len, 3);
    
    input_data(1:length(a_param), 1) = a_param;
    input_data(1:length(r_param), 2) = r_param;
    input_data(1:length(i_param), 3) = i_param;
end