% g_VisualiseExampleSite.m
%
% Purpose: Visualise ALL steady states for an example patient in SA-SE phase space
%          Shows where steady states fall relative to quorum sensing thresholds
%
% This creates a phase portrait showing:
%   - All steady state locations for this patient (dots)
%   - Barrier integrity values (colour)
%   - Quorum sensing thresholds (reference lines)
%
% IMPORTANT: This reads from AllVirtualPatientTypes_latest.csv to get ALL
%            steady states for the patient, not just one from reversible_SAkilling.csv
%
% Inputs:  ../Analyse steady states/data/AllVirtualPatientTypes_latest.csv
% Outputs: figures/ExampleSite_PhasePortrait.png
%
% Usage:
%   g_VisualiseExampleSite()           % Visualise patient ID 289986
%   g_VisualiseExampleSite(patient_id) % Visualise specific patient
%
% Author: Jamie Lee
% Date: 13 October 2025

function g_VisualiseExampleSite(patient_id)
    
    clc;
    fprintf('=== Example Site Phase Portrait Visualisation ===\n\n');
    
    %% Configuration
    if nargin < 1
        patient_id = 289986;  % Default to reproduce figure in paper
    end
    
    fprintf('Patient to visualize: ID %d\n\n', patient_id);
    
    %% Load data from main steady state file
    % This file contains ALL steady states for all patients
    input_file = '../Analyse steady states/data/AllVirtualPatientTypes_latest.csv';
    
    if ~exist(input_file, 'file')
        % Try alternative path
        input_file = 'data/AllVirtualPatientTypes_latest.csv';
        if ~exist(input_file, 'file')
            error(['Cannot find AllVirtualPatientTypes_latest.csv\n' ...
                   'Tried:\n  ../Analyse steady states/data/\n  data/']);
        end
    end
    
    fprintf('Loading patient data from main steady state file...\n');
    fprintf('  File: %s\n', input_file);
    
    all_data = readmatrix(input_file);
    
    % Get ALL steady states for this patient
    patient_rows = all_data(all_data(:, 1) == patient_id, :);
    
    if isempty(patient_rows)
        error('Patient ID %d not found in AllVirtualPatientTypes_latest.csv', patient_id);
    end
    
    n_states = size(patient_rows, 1);
    fprintf('  ✓ Found patient ID %d with %d steady state(s)\n\n', patient_id, n_states);
    
    %% Extract data for visualisation
    % Steady state populations (log scale)
    SA_stars = patient_rows(:, 20);  % Column 20: SA*
    SE_stars = patient_rows(:, 21);  % Column 21: SE*
    B_stars = patient_rows(:, 22);   % Column 22: B*
    
    % Quorum sensing thresholds (from first row - same for all states)
    A_th = patient_rows(1, 7);   % Column 7: SA QS threshold
    E_th = patient_rows(1, 14);  % Column 14: SE QS threshold
    
    fprintf('Patient characteristics:\n');
    fprintf('  SA QS threshold (A_th): %.2e CFU/cm²\n', A_th);
    fprintf('  SE QS threshold (E_th): %.2e CFU/cm²\n', E_th);
    fprintf('  Number of steady states: %d\n', n_states);
    fprintf('  Barrier values (B*): ');
    fprintf('%.3f ', B_stars);
    fprintf('\n\n');
    
    %% Create visualisation
    fprintf('Generating phase portrait...\n');
    
    fig = create_phase_portrait(SA_stars, SE_stars, B_stars, A_th, E_th, patient_id, n_states);
    
    %% Save figure
    output_folder = 'figures';
    mkdir(output_folder);
    
    output_file = fullfile(output_folder, 'ExampleSite_PhasePortrait.png');
    print(fig, output_file, '-dpng', '-r300');
    
    fprintf('  ✓ Saved: %s\n', output_file);
    
    close(fig);
    
    fprintf('\n=== Visualisation Complete ===\n');
    fprintf('Figure shows ALL %d steady state(s) in SA-SE phase space\n', n_states);
    fprintf('  • Dot positions: (SA*, SE*) populations\n');
    fprintf('  • Dot colours: Barrier integrity (green=healthy, red=damaged)\n');
    fprintf('  • Reference lines: Quorum sensing thresholds\n\n');
    
end

%% Helper: Create phase portrait figure
function fig = create_phase_portrait(SA_stars, SE_stars, B_stars, A_th, E_th, patient_id, n_states)
    
    % Create figure
    fig = figure('Position', [100, 100, 600, 600]);
    
    % Handle zero values for log plotting (replace with 1)
    SA_plot = SA_stars;
    SE_plot = SE_stars;
    SA_plot(SA_plot == 0) = 1;
    SE_plot(SE_plot == 0) = 1;
    
    % Create scatter plot (log scale)
    % Size depends on number of states (larger if only 1 or 2)
    if n_states <= 2
        marker_size = 400;
    else
        marker_size = 300;
    end
    
    scatter(log10(SA_plot), log10(SE_plot), ...
        marker_size, B_stars, 'filled', 'o', 'MarkerFaceAlpha', 0.8, ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    
    % Colour mapping for barrier integrity
    caxis([0, 1.5]);
    colormap('autumn');
    
    hold on;
    
    % Add reference lines for quorum sensing thresholds
    if A_th > 0
        xline(log10(A_th), 'k--', 'LineWidth', 1.5, ...
            'Label', 'A_{th}', 'LabelOrientation', 'horizontal', ...
            'FontSize', 12);
    end
    
    if E_th > 0
        yline(log10(E_th), 'k--', 'LineWidth', 1.5, ...
            'Label', 'E_{th}', 'LabelOrientation', 'horizontal', ...
            'FontSize', 12);
    end
    
    hold off;
    
    % Axis formatting
    xticks([0, 5, 10]);
    xticklabels({'0', '10^5', '10^{10}'});
    yticks([0, 5, 10]);
    yticklabels({'0', '10^5', '10^{10}'});
    
    ax = gca;
    ax.TickLength = [0.05, 0.05];
    ax.LineWidth = 0.75;
    ax.FontSize = 14;
    
    axis([0, 11, 0, 11]);
    
    % Labels
    xlabel('SA* [CFU/cm²]', 'FontSize', 14);
    ylabel('SE* [CFU/cm²]', 'FontSize', 14);
    title(sprintf('Phase Portrait - Patient %d (%d steady states)', patient_id, n_states), ...
        'FontSize', 14, 'FontWeight', 'bold');
    
    % Add colorbar for barrier integrity
    c = colorbar;
    c.Label.String = 'Barrier Integrity (B*)';
    c.Label.FontSize = 12;
    
end