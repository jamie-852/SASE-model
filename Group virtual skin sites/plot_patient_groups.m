% plot_figure2_patient_distributions.m
%
% Purpose: Generate Figure 2 - Distribution of virtual skin sites
%          Groups patients by BARRIER STATUS (not state count):
%            - Asymptomatic: ALL states with B* = 1 (healthy)
%            - Reversible: Mix of B* = 1 and B* < 1 states
%            - Irreversible: ALL states with B* < 1 (damaged)
%          Within each category, organizes by state count for visual clarity
%
% Inputs:  data/AllVirtualPatientTypes_latest.csv
% Outputs: figures/Figure2_PatientDistributions_[date].png
%
% Author: Jamie Lee
% Date: 7 October 2025
% Version: 4.0 - Correct classification by barrier status, flexible plotting

clc;
% Don't clear all - preserve workspace variables
close all;

fprintf('=== Figure 2: Patient Distribution Analysis ===\n');
fprintf('Classification by BARRIER STATUS (B*), not state count\n');
fprintf('  - Asymptomatic: ALL states with B* = 1\n');
fprintf('  - Irreversible: ALL states with B* < 1\n');
fprintf('  - Reversible: MIX of B* = 1 and B* < 1\n');
fprintf('================================================\n\n');

tic;

%% Configuration
if ~exist('data_folder', 'var')
    data_folder = 'data';
end
if ~exist('figures_folder', 'var')
    figures_folder = 'figures';
end
if ~exist('date_str', 'var')
    date_str = datestr(now, 'yyyy-mm-dd');
end

%% Load data
fprintf('[1/3] Loading patient data...\n');
input_file = fullfile(data_folder, 'AllVirtualPatientTypes_latest.csv');

if ~exist(input_file, 'file')
    error('Input file not found: %s', input_file);
end

AllPatients = readmatrix(input_file);
fprintf('  ✓ Loaded %d steady states from %d unique patients\n', ...
    size(AllPatients, 1), length(unique(AllPatients(:, 1))));

%% Classify patients by barrier status
% CRITICAL: Classification is by B* (barrier integrity), NOT state count!
%
% For each patient, we:
%   1. Collect ALL their steady states
%   2. Extract ALL B* values (column 22)
%   3. Count healthy (B*=1) vs damaged (B*<1)
%   4. Classify:
%        - ALL healthy (n_healthy = n_total) → Asymptomatic
%        - ALL damaged (n_damaged = n_total) → Irreversible
%        - MIX (n_healthy > 0 AND n_damaged > 0) → Reversible
%
% Examples:
%   Patient with [B*=1, B*=1, B*=1] → Asymptomatic (3 states, all healthy)
%   Patient with [B*=0.8, B*=0.6] → Irreversible (2 states, all damaged)
%   Patient with [B*=1, B*=0.7] → Reversible (2 states, mixed)
%   Patient with [B*=1] → Asymptomatic (1 state, healthy)
%   Patient with [B*=0.9] → Irreversible (1 state, damaged)
%
fprintf('\n[2/3] Classifying patients by barrier status...\n');

% Get unique patient IDs
patient_ids = unique(AllPatients(:, 1));
n_patients = length(patient_ids);

% Initialize classification arrays
asymptomatic_data = [];
reversible_data = [];
irreversible_data = [];

% Classify each patient based on B* values
for i = 1:n_patients
    pid = patient_ids(i);
    
    % Get all states for this patient (use original data for B* check)
    patient_states = AllPatients(AllPatients(:, 1) == pid, :);
    B_values = patient_states(:, 22);  % Column 22 = B*
    
    % Count healthy vs damaged states
    n_healthy = sum(B_values == 1);      % B* = 1 (healthy)
    n_damaged = sum(B_values < 1);       % B* < 1 (damaged)
    n_total = length(B_values);
    
    % Classify based on barrier status
    if n_healthy == n_total
        % All states healthy → Asymptomatic
        asymptomatic_data = [asymptomatic_data; patient_states];
        
    elseif n_healthy > 0 && n_damaged > 0
        % Mix of healthy and damaged → Reversible
        reversible_data = [reversible_data; patient_states];
        
    elseif n_damaged == n_total
        % All states damaged → Irreversible
        irreversible_data = [irreversible_data; patient_states];
    end
end

% Get unique patient counts for each category
n_asymp = length(unique(asymptomatic_data(:, 1)));
n_rev = length(unique(reversible_data(:, 1)));
n_irrev = length(unique(irreversible_data(:, 1)));

fprintf('  ✓ Asymptomatic:  %d patients (%d states) - all B*=1\n', ...
    n_asymp, size(asymptomatic_data, 1));
fprintf('  ✓ Reversible:    %d patients (%d states) - mix of B*=1 and B*<1\n', ...
    n_rev, size(reversible_data, 1));
fprintf('  ✓ Irreversible:  %d patients (%d states) - all B*<1\n', ...
    n_irrev, size(irreversible_data, 1));

% Apply plotting transformations (log scale, damaged marker)
asymp_plot = preprocess_for_plotting(asymptomatic_data);
rev_plot = preprocess_for_plotting(reversible_data);
irrev_plot = preprocess_for_plotting(irreversible_data);

%% Generate figure
fprintf('\n[3/3] Generating Figure 2...\n');

% Create figure
fig = figure('Position', [100, 100, 1800, 1200]);

% Plot each group
fprintf('  → Plotting asymptomatic patients (all B*=1)...\n');
plot_asymptomatic_patients(asymp_plot);

fprintf('  → Plotting irreversible patients (all B*<1)...\n');
plot_irreversible_patients(irrev_plot);

fprintf('  → Plotting reversible patients (mix B*=1 and B*<1)...\n');
plot_reversible_patients(rev_plot);

% Add overall title
sgtitle('Virtual Skin Site Distribution by Barrier Status', ...
    'FontSize', 18, 'FontWeight', 'bold');

% Save figure
output_file = fullfile(figures_folder, ...
    sprintf('Figure2_PatientDistributions_%s.png', date_str));
saveas(fig, output_file);
fprintf('\n  ✓ Saved: %s\n', output_file);

% Also save as high-res
output_file_highres = fullfile(figures_folder, ...
    sprintf('Figure2_PatientDistributions_%s_highres.png', date_str));
print(fig, output_file_highres, '-dpng', '-r300');
fprintf('  ✓ Saved high-res: %s\n', output_file_highres);

%% Summary
elapsed = toc;
fprintf('\n=== Figure 2 Complete ===\n');
fprintf('Execution time: %.1f seconds\n', elapsed);
fprintf('Output: %s\n', output_file);

%% ========================================================================
%  HELPER FUNCTIONS
%  ========================================================================

function plot_data = preprocess_for_plotting(data)
    % Preprocess data for log-scale plotting
    % - Replace zero populations with 1 for log plotting
    % - Set damaged barrier states to 0.1 for red coloring
    
    plot_data = data;
    
    % Replace zero SA/SE populations with 1 for log plotting
    plot_data(plot_data(:, 20) == 0, 20) = 1;  % SA (column 20)
    plot_data(plot_data(:, 21) == 0, 21) = 1;  % SE (column 21)
    
    % Set damaged barrier states to 0.1 for red coloring
    % Healthy: B* = 1 (stays as 1 → orange)
    % Damaged: B* < 1 (set to 0.1 → red)
    plot_data(plot_data(:, 22) < 1, 22) = 0.1;
end

function plot_asymptomatic_patients(data)
    % Plot asymptomatic patients (ALL steady states with B* = 1)
    % 
    % IMPORTANT: Data already filtered to only include patients where
    % ALL states have B* = 1 (from classification step)
    % 
    % This function organizes by state count for display:
    %   - Shows 1-state patients (most common for asymptomatics)
    %   - Groups by single regions
    %   - Could be extended to show multi-state asymptomatics
    % 
    % Note: State count used ONLY for visual organization, NOT classification
    
    % Add fake datapoint for colormap scaling
    limits = zeros(1, 26);
    limits(22) = 1.2;
    
    patient_ids = unique(data(:, 1));
    
    % Organize by state count to match figure layout
    % Patients with 1 state (single region)
    data_1state = [];
    for i = 1:length(patient_ids)
        pid = patient_ids(i);
        patient_data = data(data(:, 1) == pid, :);
        if size(patient_data, 1) == 1
            data_1state = [data_1state; patient_data];
        end
    end
    
    % Plot patients with 1 state by region type
    regions_single = {
        1, 'Cat 1';           % No bacteria, healthy
        2, 'Cat 2';           % Low SA, healthy
        [3, 5], 'Cat 3/5h';   % SE present, healthy (merge 3 and 5 when both B*=1)
        4, 'Cat 4';           % Both low, healthy
        6, 'Cat 6';           % Low SA + high SE
        7, 'Cat 7';           % High SA
        [8, 9], 'Cat 8/9'     % High SA + SE (merged)
    };
    
    for idx = 1:length(regions_single)
        region_cats = regions_single{idx, 1};
        
        % Extract data for this region
        if length(region_cats) == 1
            region_data = data_1state(data_1state(:, 26) == region_cats, :);
        else
            % Multiple categories (3&5 or 8&9)
            mask = false(size(data_1state, 1), 1);
            for cat = region_cats
                mask = mask | (data_1state(:, 26) == cat);
            end
            region_data = data_1state(mask, :);
        end
        
        % Add limits for colormap
        region_data = [region_data; limits];
        
        % Plot
        subplot(2, 4, idx);
        make_scatter_plot(region_data);
        title(sprintf('%s\nn=%d', regions_single{idx, 2}, size(region_data, 1)-1), ...
            'FontSize', 11);
    end
end

function plot_irreversible_patients(data)
    % Plot irreversible patients (ALL steady states with B* < 1)
    %
    % IMPORTANT: Data already filtered to only include patients where
    % ALL states have B* < 1 (from classification step)
    %
    % This function organizes by state count for display:
    %   - Prioritizes 3-state patients (typical tristable pattern)
    %   - Falls back to other state counts if combination not found
    %   - Shows multi-region combinations
    %
    % Note: State count used ONLY for visual organization, NOT classification
    % A patient is here because ALL their B* < 1, regardless of how many states
    
    limits = zeros(1, 26);
    limits(22) = 1.2;
    
    patient_ids = unique(data(:, 1));
    
    % Group by state count
    % Most common for irreversible: 3 states (tristable)
    data_3states = [];
    data_other = [];
    
    for i = 1:length(patient_ids)
        pid = patient_ids(i);
        patient_data = data(data(:, 1) == pid, :);
        n_states = size(patient_data, 1);
        
        if n_states == 3
            data_3states = [data_3states; patient_data];
        else
            data_other = [data_other; patient_data];
        end
    end
    
    % Define region combinations (typically seen in 3-state irreversible)
    combinations = {
        [1, 5, 7], 'C1-C5-C7';
        [2, 5, 7], 'C2-C5-C7';
        [3, 5, 7], 'C3-C5-C7';
        [4, 5, 7], 'C4-C5-C7';
        [1, 6, 7], 'C1-C6-C7';
        [2, 6, 7], 'C2-C6-C7';
        [3, 6, 7], 'C3-C6-C7';
        [4, 6, 7], 'C4-C6-C7';
        [1, 5, 8], 'C1-C5-C8/9';
        [2, 5, 8], 'C2-C5-C8/9';
        [3, 5, 8], 'C3-C5-C8/9';
        [4, 5, 8], 'C4-C5-C8/9';
        [1, 6, 8], 'C1-C6-C8/9';
        [2, 6, 8], 'C2-C6-C8/9'
    };
    
    % Plot 3-state combinations (most common)
    for idx = 1:min(14, length(combinations))
        target_cats = combinations{idx, 1};
        % Extract from 3-state data, but don't require exactly 3
        comb_data = extract_combination_by_regions(data_3states, patient_ids, target_cats);
        
        % If no 3-state data, try other state counts
        if isempty(comb_data)
            comb_data = extract_combination_by_regions(data_other, patient_ids, target_cats);
        end
        
        comb_data = [comb_data; limits];
        
        % Plot position (top right quadrant)
        subplot(4, 7, idx);
        make_scatter_plot(comb_data);
        n_patients = length(unique(comb_data(1:end-1, 1)));
        title(sprintf('%s\nn=%d', combinations{idx, 2}, n_patients), 'FontSize', 9);
    end
end

function plot_reversible_patients(data)
    % Plot reversible patients (MIX of B*=1 and B*<1 states)
    %
    % IMPORTANT: Data already filtered to only include patients where
    % they have BOTH B*=1 states AND B*<1 states (from classification step)
    %
    % This function organizes by state count for display:
    %   - Prioritizes 2-state patients (typical bistable pattern)
    %   - Falls back to other state counts if combination not found
    %   - Shows multi-region combinations
    %
    % Note: State count used ONLY for visual organization, NOT classification
    % A patient is here because they have BOTH healthy AND damaged states
    
    limits = zeros(1, 26);
    limits(22) = 1.2;
    
    patient_ids = unique(data(:, 1));
    
    % Group by state count
    % Most common for reversible: 2 states (bistable)
    data_2states = [];
    data_other = [];
    
    for i = 1:length(patient_ids)
        pid = patient_ids(i);
        patient_data = data(data(:, 1) == pid, :);
        n_states = size(patient_data, 1);
        
        if n_states == 2
            data_2states = [data_2states; patient_data];
        else
            data_other = [data_other; patient_data];
        end
    end
    
    % Define region combinations (typically seen in 2-state reversible)
    combinations = {
        [1, 5], 'C1-C5';
        [1, 6], 'C1-C6';
        [1, 7], 'C1-C7';
        [1, 8], 'C1-C8/9';
        [2, 5], 'C2-C5';
        [2, 6], 'C2-C6';
        [2, 7], 'C2-C7';
        [2, 8], 'C2-C8/9';
        [3, 5], 'C3-C5';
        [3, 7], 'C3-C7';
        [3, 8], 'C3-C8/9';
        [4, 5], 'C4-C5';
        [4, 6], 'C4-C6';
        [4, 7], 'C4-C7';
        [4, 8], 'C4-C8/9';
        [5, 7], 'C5-C7';
        [5, 8], 'C5-C8/9';
        [6, 7], 'C6-C7';
        [6, 8], 'C6-C8/9';
        [7, 8], 'C7-C8/9'
    };
    
    % Starting row for reversible plots
    start_row = 15;  % After irreversible section
    
    % Plot 2-state combinations (most common)
    for idx = 1:min(28, length(combinations))
        target_cats = combinations{idx, 1};
        % Extract from 2-state data primarily
        comb_data = extract_combination_by_regions(data_2states, patient_ids, target_cats);
        
        % If no 2-state data, try other state counts
        if isempty(comb_data)
            comb_data = extract_combination_by_regions(data_other, patient_ids, target_cats);
        end
        
        comb_data = [comb_data; limits];
        
        % Plot in bottom section
        subplot(7, 7, start_row + idx - 1);
        make_scatter_plot(comb_data);
        n_patients = length(unique(comb_data(1:end-1, 1)));
        title(sprintf('%s\nn=%d', combinations{idx, 2}, n_patients), 'FontSize', 9);
    end
end

function comb_data = extract_combination_by_regions(data, patient_ids, target_cats)
    % Extract patients with specific region combination
    % Does NOT filter by number of states - only by which regions they occupy
    % Handles merging of regions 8 and 9
    
    if isempty(data)
        comb_data = [];
        return;
    end
    
    comb_data = [];
    
    % Replace 9 with 8 in target if present (8 and 9 are merged)
    target_cats(target_cats == 9) = 8;
    target_cats = unique(target_cats);
    
    % Check each patient
    for i = 1:length(patient_ids)
        pid = patient_ids(i);
        patient_data = data(data(:, 1) == pid, :);
        
        if isempty(patient_data)
            continue;
        end
        
        % Get categories for this patient (merge 8 and 9)
        patient_cats = patient_data(:, 26);
        patient_cats(patient_cats == 9) = 8;
        patient_cats = unique(patient_cats);
        
        % Check if matches target combination
        if length(patient_cats) == length(target_cats) && ...
           all(ismember(sort(patient_cats), sort(target_cats)))
            comb_data = [comb_data; patient_data];
        end
    end
end

function make_scatter_plot(data)
    % Create a standardized scatter plot
    % SA on x-axis (log10), SE on y-axis (log10), colored by B*
    
    if isempty(data) || size(data, 1) <= 1
        % Empty or only fake limit point
        axis([0 11 0 11]);
        set(gca, 'FontSize', 12);
        return;
    end
    
    % Extract data (excluding fake limit point if present)
    SA = log10(data(:, 20));
    SE = log10(data(:, 21));
    B_star = data(:, 22);
    
    % Create scatter plot
    scatter(SA, SE, 300, B_star, 'filled', 'o', 'MarkerFaceAlpha', 0.8);
    
    % Set colormap and limits
    caxis([0 1.5]);
    colormap autumn;  % Orange (healthy B*=1) to red (damaged B*=0.1)
    
    % Axis settings
    xticks([0 5 10]);
    xticklabels({'0', '10^5', '10^{10}'});
    yticks([0 5 10]);
    yticklabels({'0', '10^5', '10^{10}'});
    
    axis([0 11 0 11]);
    xlabel('SA', 'FontSize', 12);
    ylabel('SE', 'FontSize', 12);
    
    ax = gca;
    ax.TickLength = [0.05, 0.05];
    ax.LineWidth = 0.75;
    set(gca, 'FontSize', 12);
end