% g_ExampleSiteAnalysis.m
%
% Purpose: High-resolution treatment response analysis for ONE example patient
%          Shows narrow therapeutic window for reversible sites
%
% This script explores treatment parameter space at much finer resolution
% than g_TreatmentResponse.m to reveal the narrow window where treatment
% successfully restores healthy barrier (B* = 1).
%
% IMPORTANT: Looks up patient by ID (column 1), not by row index
%
% Inputs:  data/reversible_SAkilling.csv
% Outputs: figures/ExampleSite_TreatmentResponse.png
%          data/example_site_results.csv
%
% Usage:
%   g_ExampleSiteAnalysis()           % Analyze patient ID 289986
%   g_ExampleSiteAnalysis(patient_id) % Analyze specific patient
%
% Author: Jamie Lee
% Date: 13 October 2025

function g_ExampleSiteAnalysis(patient_id)
    
    clc;
    fprintf('=== Example Site Treatment Response Analysis ===\n\n');
    
    %% Configuration
    if nargin < 1
        patient_id = 289986;  % Default to reproduce figure in paper
    end
    
    fprintf('Patient to analyze: ID %d\n\n', patient_id);
    
    % Fine-grained parameter grid (much finer than main analysis)
    config.strength_start = 0;
    config.strength_step = 0.05;    % Fine resolution: 0.05 (vs 1.0 in main)
    config.strength_end = 5;
    
    config.duration_start = 1;
    config.duration_step = 0.1;     % Fine resolution: 0.1 (vs 0.5 in main)
    config.duration_end = 10;
    
    % Visualization markers (for specific treatment points)
    config.marker1 = [4, 4.1];      % [duration, strength] - successful
    config.marker2 = [4, 5.0];      % [duration, strength] - failed
    
    fprintf('Fine-resolution parameter grid:\n');
    fprintf('  Strength: %.2f to %.1f days⁻¹ (step %.2f)\n', ...
        config.strength_start, config.strength_end, config.strength_step);
    fprintf('  Duration: %.1f to %.1f days (step %.1f)\n\n', ...
        config.duration_start, config.duration_end, config.duration_step);
    
    %% Load patient data
    input_file = 'data/reversible_SAkilling.csv';
    
    if ~exist(input_file, 'file')
        error('Cannot find %s\nPlease run g_ExtractInitialConditions.m first', input_file);
    end
    
    fprintf('Loading patient data from treatment file...\n');
    fprintf('  File: %s\n', input_file);
    
    all_patients = readmatrix(input_file);
    
    % Find patient by ID (column 1), not by row index!
    patient_row = all_patients(all_patients(:, 1) == patient_id, :);
    
    if isempty(patient_row)
        error(['Patient ID %d not found in reversible_SAkilling.csv\n' ...
               'Available patient IDs range from %d to %d'], ...
               patient_id, min(all_patients(:, 1)), max(all_patients(:, 1)));
    end
    
    patient_data = patient_row(1, :);  % Take first row if multiple (shouldn't happen)
    
    fprintf('  ✓ Found patient ID: %d\n', patient_data(1));
    fprintf('  Initial state: SA*=%.0f, SE*=%.0f, B*=%.3f, Region=%d\n\n', ...
        patient_data(20), patient_data(21), patient_data(22), patient_data(26));
    
    %% Generate treatment combinations
    fprintf('Generating treatment grid...\n');
    treatment = generate_treatment_grid(config);
    n_treatments = size(treatment, 1);
    fprintf('  ✓ %d treatment combinations\n', n_treatments);
    fprintf('  Estimated runtime: %.0f seconds (%.1f minutes)\n\n', ...
        n_treatments * 0.5, n_treatments * 0.5 / 60);
    
    %% Run treatment simulations
    fprintf('Running treatment simulations...\n');
    fprintf('Progress: 0%%');
    
    treatment_output = zeros(n_treatments, 5);
    options = odeset('NonNegative', 1, 'RelTol', 1e-3, 'AbsTol', 1e-3);
    options_event = odeset('NonNegative', 1, 'Events', @(t, y)f_EventHealthy(t, y), ...
                           'RelTol', 1e-3, 'AbsTol', 1e-3);
    S = 1;  % Treatment applied when S = 1
    
    tic;
    for i = 1:n_treatments
        % Progress update
        if mod(i, floor(n_treatments/10)) == 0
            fprintf('\b\b\b\b%3d%%', round(100*i/n_treatments));
        end
        
        % Simulate this treatment combination
        [strength, duration, final_A, final_E, final_B] = ...
            simulate_treatment(patient_data, treatment(i, :), S, options, options_event);
        
        treatment_output(i, :) = [strength, duration, final_A, final_E, final_B];
    end
    fprintf('\b\b\b\b100%%\n');
    fprintf('  ✓ Complete (%.1f seconds = %.1f minutes)\n\n', toc, toc/60);
    
    %% Save results
    fprintf('Saving results...\n');
    output_folder = 'data';
    mkdir(output_folder);
    
    results_file = fullfile(output_folder, 'example_site_results.csv');
    writematrix(treatment_output, results_file);
    fprintf('  ✓ Saved: %s\n', results_file);
    fprintf('    (%d rows × 5 columns: strength, duration, final_A, final_E, final_B)\n\n', ...
        n_treatments);
    
    %% Generate visualization
    fprintf('Generating treatment response heatmap...\n');
    create_treatment_heatmap(treatment_output, config, patient_data(1));
    
    fprintf('\n=== Analysis Complete ===\n');
    fprintf('Outputs:\n');
    fprintf('  • Data: data/example_site_results.csv\n');
    fprintf('  • Figure: figures/ExampleSite_TreatmentResponse.png\n\n');
    
end

%% Helper: Generate treatment grid
function treatment = generate_treatment_grid(config)
    treatment = [];
    for strength = config.strength_start:config.strength_step:config.strength_end
        for duration = config.duration_start:config.duration_step:config.duration_end
            treatment = [treatment; strength, duration];
        end
    end
end

%% Helper: Simulate single treatment
function [strength, duration, final_A, final_E, final_B] = ...
    simulate_treatment(patient_data, treatment_params, S, options, options_event)
    
    % Extract parameters
    kappa_A  = patient_data(3);    kappa_E  = patient_data(10);
    A_max    = patient_data(4);    E_max    = patient_data(11);
    gamma_AB = patient_data(5);    gamma_EB = patient_data(12);
    delta_AE = patient_data(6);    delta_EA = patient_data(13);
    A_th     = patient_data(7);    E_th     = patient_data(14);
    E_pth    = patient_data(8);    A_pth    = patient_data(15);
    gamma_AE = patient_data(9);    kappa_B  = patient_data(16);
    delta_B  = patient_data(17);
    delta_BA = patient_data(18);
    delta_BE = patient_data(19);
    
    % Initial conditions (starting from one of the steady states)
    A_0 = patient_data(20);
    E_0 = patient_data(21);
    B_0 = patient_data(22);
    
    if A_0 <= 1, A_0 = 0; end
    if E_0 <= 1, E_0 = 0; end
    
    % Treatment parameters
    strength = treatment_params(1);
    duration = treatment_params(2);
    
    % Phase 1: Apply treatment
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, ...
        delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, ...
        A_pth, kappa_B, delta_B, delta_BA, delta_BE, strength, S), ...
        [0, duration], [A_0, E_0, B_0], options);
    
    % Add perturbation
    A_pert = max(1, y1(end, 1) - 1);
    E_pert = max(1, y1(end, 2) - 1);
    B_post = y1(end, 3);
    
    % Phase 2: Check convergence to healthy state
    [t2, y2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t1(end), t1(end) + 1e6], [A_pert, E_pert, B_post], options_event);
    
    % Phase 3: Test stability if healthy state reached
    if t2(end) < (t1(end) + 1e6)
        A_stab = max(1, y2(end, 1) - 1);
        E_stab = max(1, y2(end, 2) - 1);
        B_final = y2(end, 3);
        
        [~, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
            A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
            kappa_B, delta_B, delta_BA, delta_BE), ...
            [t2(end), t1(end) + 1e6], [A_stab, E_stab, B_final], options);
        
        final_A = y3(end, 1);
        final_E = y3(end, 2);
        final_B = y3(end, 3);
    else
        % Did not reach healthy state
        final_A = y2(end, 1);
        final_E = y2(end, 2);
        final_B = y2(end, 3);
    end
end

%% Helper: Create heatmap visualization
function create_treatment_heatmap(treatment_output, config, patient_id)
    
    % Create output folder
    output_folder = 'figures';
    mkdir(output_folder);
    
    % Extract data
    X = treatment_output(:, 2);  % Duration
    Y = treatment_output(:, 1);  % Strength
    Z = treatment_output(:, 5);  % Final B*
    
    % Create interpolated grid for smooth visualization
    N = 95;
    x = linspace(min(X), max(X), N);
    y = linspace(min(Y), max(Y), N);
    [Xi, Yi] = meshgrid(x, y);
    Zi = griddata(X, Y, Z, Xi, Yi);
    
    % Create figure
    fig = figure('Position', [100, 100, 700, 600]);
    
    % Plot surface
    surf(Xi, Yi, Zi, 'edgecolor', 'none');
    
    % Formatting
    colormap('autumn');
    caxis([0, 1.5]);
    alpha(1);
    colorbar;
    view(2);
    grid off;
    
    % Add markers for specific treatment points
    hold on;
    plot3(config.marker1(1), config.marker1(2), 10, 'x', ...
        'MarkerSize', 15, 'MarkerEdgeColor', [1 1 1], 'LineWidth', 2);
    plot3(config.marker2(1), config.marker2(2), 10, 'x', ...
        'MarkerSize', 15, 'MarkerEdgeColor', [0 0 0], 'LineWidth', 2);
    hold off;
    
    % Labels
    xlabel('Duration [days]', 'FontSize', 16);
    ylabel('Strength [days^{-1}]', 'FontSize', 16);
    title(sprintf('Treatment Response - Patient %d', patient_id), ...
        'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 16);
    axis([config.duration_start, config.duration_end, ...
          config.strength_start, config.strength_end]);
    
    % Add text annotation
    text(7, 1.5, {'Convergence to', 'a damaged', 'skin state'}, ...
        'Color', 'white', 'FontSize', 14, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
    
    % Save figure
    output_file = fullfile(output_folder, 'ExampleSite_TreatmentResponse.png');
    print(fig, output_file, '-dpng', '-r300');
    
    close(fig);
    fprintf('  ✓ Saved: %s\n', output_file);
end