% g_PatientTypes_3.m
%
% Purpose: Plot virtual skin sites with THREE stable steady states
%          Groups by ALL region combinations found in data
%
% Inputs:  AllVirtualPatientTypes (workspace) or Three_StableState.csv
% Outputs: Figure with subplots showing ALL 3-state combinations
%          Saved as PatientTypes_3_SteadyStates.png
%
% Note: Dynamically detects all unique 3-region combinations in the data.
%       The number of subplots will vary depending on your dataset.
%
% Author: Jamie Lee
% Date: 7 October 2025
% Version: 2.1 - Now plots ALL combinations (not just common ones)

clc;

fprintf('=== Plotting Patients with 3 Steady States ===\n\n');

%% Step 1: Load or filter data for 3-state patients
fprintf('[1/4] Loading data for 3-state patients...\n');

% Define data file path (relative to Group virtual skin sites folder)
data_file = '../Analyse steady states/data/AllVirtualPatientTypes_latest.csv';

% Option 1: Filter from workspace variable
if exist('AllVirtualPatientTypes', 'var')
    fprintf('  Using AllVirtualPatientTypes from workspace\n');
    PatientsThree = [];
    for i = 1:size(AllVirtualPatientTypes, 1)
        if AllVirtualPatientTypes(i, 2) == 3
            PatientsThree = [PatientsThree; AllVirtualPatientTypes(i, :)];
        end 
    end
    writematrix(PatientsThree, 'Three_StableState.csv');
    fprintf('  ✓ Saved Three_StableState.csv\n');
    
% Option 2: Load from filtered file
elseif exist('Three_StableState.csv', 'file')
    fprintf('  Loading from Three_StableState.csv\n');
    PatientsThree = readmatrix('Three_StableState.csv');
    fprintf('  ✓ Loaded\n');
    
% Option 3: Load and filter from main data file
elseif exist(data_file, 'file')
    fprintf('  Loading and filtering from %s\n', data_file);
    AllVirtualPatientTypes = readmatrix(data_file);
    PatientsThree = [];
    for i = 1:size(AllVirtualPatientTypes, 1)
        if AllVirtualPatientTypes(i, 2) == 3
            PatientsThree = [PatientsThree; AllVirtualPatientTypes(i, :)];
        end 
    end
    writematrix(PatientsThree, 'Three_StableState.csv');
    fprintf('  ✓ Filtered and saved Three_StableState.csv\n');
    
else
    error(['No data found. Need one of:\n' ...
           '  1. AllVirtualPatientTypes variable in workspace\n' ...
           '  2. Three_StableState.csv file in current directory\n' ...
           '  3. %s file'], data_file);
end

fprintf('  Total: %d patients with 3 steady states\n', size(PatientsThree, 1) / 3);

%% Step 2: Preprocess for log-scale plotting
fprintf('\n[2/4] Preprocessing for log-scale plotting...\n');

logPatientsThree = PatientsThree;

% Replace zero populations with 1 for log plotting
for i = 1:size(PatientsThree, 1)
    % Handle SA and SE zeros
    if PatientsThree(i, 20) == 0 && PatientsThree(i, 21) == 0
        logPatientsThree(i, 20) = 1;
        logPatientsThree(i, 21) = 1;  
    elseif PatientsThree(i, 20) == 0 && PatientsThree(i, 21) > 0
        logPatientsThree(i, 20) = 1;
    elseif PatientsThree(i, 21) == 0 && PatientsThree(i, 20) > 0
        logPatientsThree(i, 21) = 1;  
    end

    % Set damaged barrier (B* < 1) to 0.1 for red coloring
    if PatientsThree(i, 22) < 1
        logPatientsThree(i, 22) = 0.1;
    end
end

fprintf('  ✓ Preprocessed %d rows\n', size(logPatientsThree, 1));

%% Step 3: Sort into ALL region combinations (dynamically detected)
fprintf('\n[3/4] Dynamically detecting ALL region combinations...\n');
fprintf('  Note: Regions 8 and 9 are merged\n');

% Storage for all combinations found
combinations = {};  % Will store data for each unique combination
combo_labels = {};  % Labels for each combination

% Sort patients into combinations
for k = 1:(size(logPatientsThree, 1) - 2)
    % Check if three consecutive rows have same patient ID
    if ~(logPatientsThree(k, 1) == logPatientsThree(k + 1, 1) && ...
         logPatientsThree(k + 1, 1) == logPatientsThree(k + 2, 1))
        continue;
    end
    
    % Get the three regions (merging 8 and 9)
    regions = [logPatientsThree(k, 26); 
               logPatientsThree(k + 1, 26); 
               logPatientsThree(k + 2, 26)];
    
    % Merge regions 8 and 9
    regions(regions == 9) = 8;
    
    % Sort to create consistent identifier
    regions = sort(regions);
    
    % Create label
    label = sprintf('Regions %d-%d-%d', regions(1), regions(2), regions(3));
    
    % Store the patient triplet
    triplet = [logPatientsThree(k, :); 
               logPatientsThree(k + 1, :); 
               logPatientsThree(k + 2, :)];
    
    % Find if this combination already exists
    idx = find(strcmp(combo_labels, label), 1);
    
    if isempty(idx)
        % New combination - add it
        combinations{end+1} = triplet;
        combo_labels{end+1} = label;
    else
        % Existing combination - append data
        combinations{idx} = [combinations{idx}; triplet];
    end
end

n_combos = length(combinations);
fprintf('  ✓ Found %d unique region combinations\n', n_combos);

% Print all combinations found
fprintf('  Combinations: ');
for i = 1:min(5, n_combos)
    fprintf('%s', combo_labels{i});
    if i < min(5, n_combos), fprintf(', '); end
end
if n_combos > 5
    fprintf(' ... and %d more', n_combos - 5);
end
fprintf('\n');

%% Step 4: Add dummy point for colormap scaling
fprintf('\n[4/4] Adding colormap scaling point...\n');

limits = zeros(1, 26); 
limits(22) = 1.2;

% Add limits to ALL combinations
for i = 1:n_combos
    combinations{i} = [combinations{i}; limits];
end

fprintf('  ✓ Ready for plotting\n');

%% Step 5: Create figure with subplots (dynamic grid)
fprintf('\nGenerating figure...\n');

% Calculate optimal subplot grid size
n_rows = ceil(sqrt(n_combos));
n_cols = ceil(n_combos / n_rows);

fprintf('  Creating %dx%d grid for %d combinations\n', n_rows, n_cols, n_combos);

figure('Name', 'Virtual Skin Sites - 3 Steady States', 'Position', [100, 100, 1000, 1000]);

% Plot ALL combinations found in the data
for i = 1:n_combos
    subplot(n_rows, n_cols, i);
    plot_3state_combination(combinations{i}, combo_labels{i});
end

sgtitle('Virtual Skin Sites with 3 Steady States (All Combinations)', 'FontSize', 16, 'FontWeight', 'bold');

% Save figure as PNG
output_file = 'PatientTypes_3_SteadyStates.png';
print(output_file, '-dpng', '-r300');
fprintf('✓ Figure saved as: %s\n', output_file);

fprintf('✓ Figure complete with %d unique combinations!\n\n', n_combos);

%% Helper function for plotting
function plot_3state_combination(data, label)
    % Plot a single combination subplot
    
    if size(data, 1) <= 1
        % Empty or only dummy point
        text(0.5, 0.5, 'No data', 'HorizontalAlignment', 'center', ...
            'FontSize', 12, 'Units', 'normalized');
        axis([0 11 0 11]);
        set(gca, 'FontSize', 14);
        title(sprintf('%s\nn=0', label));
        return;
    end
    
    % Count actual patients (exclude dummy point, 3 rows per patient)
    n_patients = (size(data, 1) - 1) / 3;
    
    % Create scatter plot
    scatter(log10(data(:, 20)), log10(data(:, 21)), ...
        300, data(:, 22), 'filled', 'o', 'MarkerFaceAlpha', 0.8);
    
    % Colormap setup
    caxis([0 1.5]);
    colormap autumn;
    
    % Axis formatting
    xticks([0 5 10]);
    xticklabels({'0', '10^5', '10^{10}'});
    yticks([0 5 10]);
    yticklabels({'0', '10^5', '10^{10}'});
    
    ax = gca;
    ax.TickLength = [0.05, 0.05];
    ax.LineWidth = 0.75;
    
    axis([0 11 0 11]);
    xlabel('SA', 'FontSize', 14);
    ylabel('SE', 'FontSize', 14);
    set(gca, 'FontSize', 14);
    
    title(sprintf('%s\nn=%d', label, n_patients));
end