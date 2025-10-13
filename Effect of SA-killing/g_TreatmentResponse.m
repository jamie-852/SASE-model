% g_TreatmentResponse.m
%
% Purpose: Simulate SA-killing treatment response for reversible skin sites
%          Tests combinations of treatment strength and duration
%
% Inputs:  data/reversible_SAkilling.csv (initial conditions)
% Outputs: data/reversible_treatment_results.csv
%
% Usage:
%   g_TreatmentResponse()                    % Default: strength 0-5, duration 1-4
%   g_TreatmentResponse(0, 1, 5, 1, 0.5, 4)  % Custom ranges (main text)
%   g_TreatmentResponse(0, 2.5, 10, 2, 12, 50) % Supplementary Figure ranges
%
% Author: Jamie Lee
% Date: 10 October 2025
% Version: 2.0 - Refactored for reproducibility

function g_TreatmentResponse(delta_AS_start, delta_AS_step, delta_AS_end, ...
                              t_end_start, t_end_step, t_end_end)
    
    clc;
    fprintf('=== SA-Killing Treatment Response Analysis ===\n\n');
    
    %% Default parameters (Figure 3b-d: main text)
    if nargin < 6
        delta_AS_start  = 0;    % Treatment strength start
        delta_AS_step   = 1;    % Treatment strength step
        delta_AS_end    = 5;    % Treatment strength end
        
        t_end_start     = 1;    % Treatment duration start (days)
        t_end_step      = 0.5;  % Treatment duration step
        t_end_end       = 4;    % Treatment duration end (days)
    end
    
    fprintf('Treatment parameter ranges:\n');
    fprintf('  Strength: %.1f to %.1f (step %.1f)\n', delta_AS_start, delta_AS_end, delta_AS_step);
    fprintf('  Duration: %.1f to %.1f days (step %.1f)\n\n', t_end_start, t_end_end, t_end_step);
    
    %% Setup paths
    input_file = 'data/reversible_SAkilling.csv';
    output_folder = 'data';
    output_file = fullfile(output_folder, 'reversible_treatment_results.csv');
    
    % Ensure output folder exists
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    %% Check input file exists
    if ~exist(input_file, 'file')
        error('Cannot find %s\nPlease run g_ExtractInitialConditions.m first', input_file);
    end
    
    %% Load reversible patient data
    fprintf('Loading reversible patient data...\n');
    sites = readmatrix(input_file);
    n_sites = size(sites, 1);
    fprintf('  ✓ Loaded %d reversible skin sites\n\n', n_sites);
    
    %% Generate treatment combinations
    fprintf('Generating treatment combinations...\n');
    treatment = [];
    for strength = delta_AS_start:delta_AS_step:delta_AS_end
        for duration = t_end_start:t_end_step:t_end_end
            treatment = [treatment; strength, duration];
        end 
    end
    n_treatments = size(treatment, 1);
    fprintf('  ✓ %d treatment combinations to test\n\n', n_treatments);
    
    %% ODE solver options
    options = odeset('NonNegative', 1, 'RelTol', 1e-4, 'AbsTol', 1e-4);
    options_event = odeset('NonNegative', 1, 'Events', @(t, y)f_EventHealthy(t, y), ...
                           'RelTol', 1e-4, 'AbsTol', 1e-4);
    
    %% Test for parallel processing availability
    use_parallel = check_parallel_available();
    if use_parallel
        fprintf('Using parallel processing\n');
    else
        fprintf('Parallel processing not available, using sequential processing\n');
    end
    fprintf('Estimated runtime: %s\n\n', estimate_runtime(n_treatments, n_sites, use_parallel));
    
    %% Main treatment simulation loop
    fprintf('Running treatment simulations...\n');
    fprintf('Progress: [');
    
    frac_success = zeros(n_treatments, 1);
    S = 1;  % Therapy applied when S = 1
    
    % Track timing for better estimate
    tic;
    first_complete = false;
    
    for i = 1:n_treatments
        % Count successful treatments
        n_success = 0;
        
        if use_parallel
            parfor ii = 1:n_sites
                if simulate_single_site(sites(ii, :), treatment(i, :), S, ...
                                       options, options_event)
                    n_success = n_success + 1;
                end
            end
        else
            for ii = 1:n_sites
                if simulate_single_site(sites(ii, :), treatment(i, :), S, ...
                                       options, options_event)
                    n_success = n_success + 1;
                end
            end
        end
        
        frac_success(i) = n_success / n_sites;
        
        % After first treatment, update time estimate
        if ~first_complete
            elapsed_first = toc;
            estimated_total = elapsed_first * n_treatments;
            fprintf('] \nUpdated estimate: %s (based on first treatment)\nProgress: [', ...
                format_time(estimated_total));
            first_complete = true;
        end
        
        % Update progress bar
        if first_complete && mod(i, max(1, floor(n_treatments/50))) == 0
            fprintf('=');
        end
    end
    
    fprintf(']\n');
    elapsed_total = toc;
    fprintf('Actual runtime: %s\n\n', format_time(elapsed_total));
    
    %% Save results
    fprintf('Saving results...\n');
    treat_plot = [treatment, frac_success];
    writematrix(treat_plot, output_file);
    fprintf('  ✓ Saved: %s\n', output_file);
    
    %% Summary
    fprintf('\n=== Analysis Complete ===\n');
    fprintf('Results summary:\n');
    fprintf('  Treatments tested: %d\n', n_treatments);
    fprintf('  Sites per treatment: %d\n', n_sites);
    fprintf('  Overall success rate: %.1f%% - %.1f%%\n', ...
            min(frac_success)*100, max(frac_success)*100);
    fprintf('\nResults saved to: %s\n', output_file);
    fprintf('Run g_Plot.m to visualize results\n\n');
    
end

%% Helper: Simulate single site treatment
function success = simulate_single_site(site_data, treatment_params, S, options, options_event)
    % Returns true if treatment successfully restores healthy barrier (B* = 1)
    
    % Extract parameters (columns 3-19)
    kappa_A  = site_data(3);    kappa_E  = site_data(10);
    A_max    = site_data(4);    E_max    = site_data(11);
    gamma_AB = site_data(5);    gamma_EB = site_data(12);
    delta_AE = site_data(6);    delta_EA = site_data(13);
    A_th     = site_data(7);    E_th     = site_data(14);
    E_pth    = site_data(8);    A_pth    = site_data(15);
    gamma_AE = site_data(9);    kappa_B  = site_data(16);
    delta_B  = site_data(17);
    delta_BA = site_data(18);
    delta_BE = site_data(19);
    
    % Extract initial conditions (columns 20-22)
    A_0 = site_data(20);
    E_0 = site_data(21);
    B_0 = site_data(22);
    
    % Handle near-zero populations
    if A_0 <= 1, A_0 = 0; end
    if E_0 <= 1, E_0 = 0; end
    
    % Extract treatment parameters
    delta_AS = treatment_params(1);  % Treatment strength
    t_end = treatment_params(2);     % Treatment duration
    
    % Phase 1: Apply SA-killing treatment
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, ...
        delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, ...
        A_pth, kappa_B, delta_B, delta_BA, delta_BE, delta_AS, S), ...
        [0, t_end], [A_0, E_0, B_0], options);
    
    % Add perturbation after treatment
    A_pert = max(1, y1(end, 1) - 1);
    E_pert = max(1, y1(end, 2) - 1);
    B_post = y1(end, 3);
    
    % Phase 2: Check if system reaches healthy state (B* = 1)
    [t2, y2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t1(end), t1(end) + 1e6], [A_pert, E_pert, B_post], options_event);
    
    % Check if healthy state reached before timeout
    if t2(end) >= (t1(end) + 1e6)
        success = false;
        return;
    end
    
    % Phase 3: Test stability of healthy state with perturbation
    A_stab = max(1, y2(end, 1) - 1);
    E_stab = max(1, y2(end, 2) - 1);
    B_final = y2(end, 3);
    
    [~, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), ...
        [t2(end), t1(end) + 1e6], [A_stab, E_stab, B_final], options);
    
    % Success if final barrier is healthy (B* = 1)
    success = (y3(end, 3) == 1);
end

%% Helper: Check if parallel processing is available
function available = check_parallel_available()
    try
        pool = gcp('nocreate');
        if isempty(pool)
            parpool('local', 'SpmdEnabled', false);
        end
        available = true;
    catch
        available = false;
    end
end

%% Helper: Estimate runtime
function time_str = estimate_runtime(n_treatments, n_sites, use_parallel)
    % Very rough estimate - will be updated after first treatment completes
    total_sims = n_treatments * n_sites;
    
    if use_parallel
        % Assume 4-core speedup (rough guess)
        time_seconds = total_sims * 0.5 / 4;
    else
        time_seconds = total_sims * 0.5;
    end
    
    time_str = sprintf('%s (rough estimate, will update)', format_time(time_seconds));
end

%% Helper: Format time nicely
function time_str = format_time(seconds)
    if seconds < 60
        time_str = sprintf('%.0f seconds', seconds);
    elseif seconds < 3600
        time_str = sprintf('%.0f minutes', seconds/60);
    else
        time_str = sprintf('%.1f hours', seconds/3600);
    end
end