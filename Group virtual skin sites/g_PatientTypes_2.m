% g_PatientTypes_2.m
%
% Purpose: Plot virtual skin sites with TWO stable steady states
%          Groups by region combinations (pairs from regions 1-8)
%
% Inputs:  AllVirtualPatientTypes (workspace) or Two_StableStates.csv
% Outputs: data/Two_StableStates.csv, figures/PatientTypes_2_SteadyStates.png
%
% Author: Jamie Lee
% Date: 7 October 2025
% Version: 2.1 - Added organized output folders

clc;

fprintf('=== Plotting Patients with 2 Steady States ===\n\n');

%% Step 0: Create output folders if they don't exist
if ~exist('data', 'dir')
    mkdir('data');
    fprintf('Created data/ folder\n');
end
if ~exist('figures', 'dir')
    mkdir('figures');
    fprintf('Created figures/ folder\n');
end

%% Step 1: Load or filter data for 2-state patients
fprintf('[1/4] Loading data for 2-state patients...\n');

% Define data file paths
main_data_file = '../Analyse steady states/data/AllVirtualPatientTypes_latest.csv';
local_csv = 'data/Two_StableStates.csv';

% Option 1: Filter from workspace variable
if exist('AllVirtualPatientTypes', 'var')
    fprintf('  Using AllVirtualPatientTypes from workspace\n');
    PatientsTwo = [];
    for i = 1:size(AllVirtualPatientTypes, 1)
        if AllVirtualPatientTypes(i, 2) == 2
            PatientsTwo = [PatientsTwo; AllVirtualPatientTypes(i, :)];
        end 
    end
    writematrix(PatientsTwo, local_csv);
    fprintf('  ✓ Saved %s\n', local_csv);
    
% Option 2: Load from filtered file
elseif exist(local_csv, 'file')
    fprintf('  Loading from %s\n', local_csv);
    PatientsTwo = readmatrix(local_csv);
    fprintf('  ✓ Loaded\n');
    
% Option 3: Load and filter from main data file
elseif exist(main_data_file, 'file')
    fprintf('  Loading and filtering from %s\n', main_data_file);
    AllVirtualPatientTypes = readmatrix(main_data_file);
    PatientsTwo = [];
    for i = 1:size(AllVirtualPatientTypes, 1)
        if AllVirtualPatientTypes(i, 2) == 2
            PatientsTwo = [PatientsTwo; AllVirtualPatientTypes(i, :)];
        end 
    end
    writematrix(PatientsTwo, local_csv);
    fprintf('  ✓ Filtered and saved %s\n', local_csv);
    
else
    error(['No data found. Need one of:\n' ...
           '  1. AllVirtualPatientTypes variable in workspace\n' ...
           '  2. %s file\n' ...
           '  3. %s file'], local_csv, main_data_file);
end

fprintf('  Total: %d patients with 2 steady states\n', size(PatientsTwo, 1) / 2);

%% Step 2: Preprocess for log-scale plotting
fprintf('\n[2/4] Preprocessing for log-scale plotting...\n');

logPatientsTwo = PatientsTwo;

% Replace zero populations with 1 for log plotting
for i = 1:size(PatientsTwo, 1)
    if PatientsTwo(i, 20) == 0 && PatientsTwo(i, 21) == 0
        logPatientsTwo(i, 20) = 1;
        logPatientsTwo(i, 21) = 1;  
    elseif PatientsTwo(i, 20) == 0 && PatientsTwo(i, 21) > 0
        logPatientsTwo(i, 20) = 1;
    elseif PatientsTwo(i, 21) == 0 && PatientsTwo(i, 20) > 0
        logPatientsTwo(i, 21) = 1;  
    end
    
    % Set damaged barrier (B* < 1) to 0.1 for red coloring
    if PatientsTwo(i, 22) < 1
        logPatientsTwo(i, 22) = 0.1; 
    end 
end

fprintf('  ✓ Preprocessed %d rows\n', size(logPatientsTwo, 1));

%% Step 3: Sort into region combinations
fprintf('\n[3/4] Grouping by region combinations...\n');
fprintf('  Note: Regions 8 and 9 are merged\n');

% Initialize combination arrays (28 possible pairs from regions 1-8)
comb_1_2 = []; comb_1_3 = []; comb_1_4 = []; comb_1_5 = [];
comb_1_6 = []; comb_1_7 = []; comb_1_8 = [];
comb_2_3 = []; comb_2_4 = []; comb_2_5 = []; comb_2_6 = [];
comb_2_7 = []; comb_2_8 = [];
comb_3_4 = []; comb_3_5 = []; comb_3_6 = []; comb_3_7 = [];
comb_3_8 = [];
comb_4_5 = []; comb_4_6 = []; comb_4_7 = []; comb_4_8 = [];
comb_5_6 = []; comb_5_7 = []; comb_5_8 = [];
comb_6_7 = []; comb_6_8 = [];
comb_7_8 = [];

% Sort patients into combinations
for j = 1:(size(logPatientsTwo, 1) - 1)
    % Check if this and next row are same patient
    if logPatientsTwo(j, 1) ~= logPatientsTwo(j + 1, 1)
        continue;
    end
    
    % Get the two regions (merging 8 and 9)
    region1 = logPatientsTwo(j, 26);
    region2 = logPatientsTwo(j + 1, 26);
    if region1 == 9, region1 = 8; end
    if region2 == 9, region2 = 8; end
    
    % Sort to ensure consistent ordering
    regions = sort([region1, region2]);
    
    % Store the patient pair
    pair = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
    
    % Assign to appropriate combination
    if isequal(regions, [1, 2]), comb_1_2 = [comb_1_2; pair];
    elseif isequal(regions, [1, 3]), comb_1_3 = [comb_1_3; pair];
    elseif isequal(regions, [1, 4]), comb_1_4 = [comb_1_4; pair];
    elseif isequal(regions, [1, 5]), comb_1_5 = [comb_1_5; pair];
    elseif isequal(regions, [1, 6]), comb_1_6 = [comb_1_6; pair];
    elseif isequal(regions, [1, 7]), comb_1_7 = [comb_1_7; pair];
    elseif isequal(regions, [1, 8]), comb_1_8 = [comb_1_8; pair];
    elseif isequal(regions, [2, 3]), comb_2_3 = [comb_2_3; pair];
    elseif isequal(regions, [2, 4]), comb_2_4 = [comb_2_4; pair];
    elseif isequal(regions, [2, 5]), comb_2_5 = [comb_2_5; pair];
    elseif isequal(regions, [2, 6]), comb_2_6 = [comb_2_6; pair];
    elseif isequal(regions, [2, 7]), comb_2_7 = [comb_2_7; pair];
    elseif isequal(regions, [2, 8]), comb_2_8 = [comb_2_8; pair];
    elseif isequal(regions, [3, 4]), comb_3_4 = [comb_3_4; pair];
    elseif isequal(regions, [3, 5]), comb_3_5 = [comb_3_5; pair];
    elseif isequal(regions, [3, 6]), comb_3_6 = [comb_3_6; pair];
    elseif isequal(regions, [3, 7]), comb_3_7 = [comb_3_7; pair];
    elseif isequal(regions, [3, 8]), comb_3_8 = [comb_3_8; pair];
    elseif isequal(regions, [4, 5]), comb_4_5 = [comb_4_5; pair];
    elseif isequal(regions, [4, 6]), comb_4_6 = [comb_4_6; pair];
    elseif isequal(regions, [4, 7]), comb_4_7 = [comb_4_7; pair];
    elseif isequal(regions, [4, 8]), comb_4_8 = [comb_4_8; pair];
    elseif isequal(regions, [5, 6]), comb_5_6 = [comb_5_6; pair];
    elseif isequal(regions, [5, 7]), comb_5_7 = [comb_5_7; pair];
    elseif isequal(regions, [5, 8]), comb_5_8 = [comb_5_8; pair];
    elseif isequal(regions, [6, 7]), comb_6_7 = [comb_6_7; pair];
    elseif isequal(regions, [6, 8]), comb_6_8 = [comb_6_8; pair];
    elseif isequal(regions, [7, 8]), comb_7_8 = [comb_7_8; pair];
    end
end

fprintf('  ✓ Sorted into region combinations\n');

%% Step 4: Add dummy point for colormap scaling
fprintf('\n[4/4] Adding colormap scaling point...\n');

limits = zeros(1, 26); 
limits(22) = 1.2;

comb_1_5 = [comb_1_5; limits]; comb_1_6 = [comb_1_6; limits];
comb_1_7 = [comb_1_7; limits]; comb_1_8 = [comb_1_8; limits];
comb_2_5 = [comb_2_5; limits]; comb_2_6 = [comb_2_6; limits];
comb_2_7 = [comb_2_7; limits]; comb_2_8 = [comb_2_8; limits];
comb_3_5 = [comb_3_5; limits]; comb_3_6 = [comb_3_6; limits];
comb_3_7 = [comb_3_7; limits]; comb_3_8 = [comb_3_8; limits];
comb_4_5 = [comb_4_5; limits]; comb_4_6 = [comb_4_6; limits];
comb_4_7 = [comb_4_7; limits]; comb_4_8 = [comb_4_8; limits];
comb_5_7 = [comb_5_7; limits]; comb_5_8 = [comb_5_8; limits];
comb_6_7 = [comb_6_7; limits]; comb_6_8 = [comb_6_8; limits];
comb_7_8 = [comb_7_8; limits];

fprintf('  ✓ Ready for plotting\n');

%% Step 5: Create figure with subplots
fprintf('\nGenerating figure...\n');

figure('Name', 'Virtual Skin Sites - 2 Steady States', 'Position', [100, 100, 1400, 900]);

% Plot the most common combinations (21 subplots)
subplot(4, 6, 1);  plot_2state_combination(comb_1_5, 'Regions 1-5');
subplot(4, 6, 2);  plot_2state_combination(comb_1_6, 'Regions 1-6');
subplot(4, 6, 3);  plot_2state_combination(comb_1_7, 'Regions 1-7');
subplot(4, 6, 4);  plot_2state_combination(comb_1_8, 'Regions 1-8');
subplot(4, 6, 5);  plot_2state_combination(comb_2_5, 'Regions 2-5');
subplot(4, 6, 6);  plot_2state_combination(comb_2_6, 'Regions 2-6');
subplot(4, 6, 7);  plot_2state_combination(comb_2_7, 'Regions 2-7');
subplot(4, 6, 8);  plot_2state_combination(comb_2_8, 'Regions 2-8');
subplot(4, 6, 9);  plot_2state_combination(comb_3_5, 'Regions 3-5');
subplot(4, 6, 10); plot_2state_combination(comb_3_7, 'Regions 3-7');
subplot(4, 6, 11); plot_2state_combination(comb_3_8, 'Regions 3-8');
subplot(4, 6, 12); plot_2state_combination(comb_4_5, 'Regions 4-5');
subplot(4, 6, 13); plot_2state_combination(comb_4_6, 'Regions 4-6');
subplot(4, 6, 14); plot_2state_combination(comb_4_7, 'Regions 4-7');
subplot(4, 6, 15); plot_2state_combination(comb_4_8, 'Regions 4-8');
subplot(4, 6, 16); plot_2state_combination(comb_5_7, 'Regions 5-7');
subplot(4, 6, 17); plot_2state_combination(comb_5_8, 'Regions 5-8');
subplot(4, 6, 18); plot_2state_combination(comb_6_7, 'Regions 6-7');
subplot(4, 6, 19); plot_2state_combination(comb_6_8, 'Regions 6-8');
subplot(4, 6, 20); plot_2state_combination(comb_7_8, 'Regions 7-8');
subplot(4, 6, 21); plot_2state_combination(comb_3_6, 'Regions 3-6');

sgtitle('Virtual Skin Sites with 2 Steady States', 'FontSize', 16, 'FontWeight', 'bold');

% Save figure as PNG to figures/ folder
output_file = 'figures/PatientTypes_2_SteadyStates.png';
print(output_file, '-dpng', '-r300');
fprintf('✓ Figure saved as: %s\n', output_file);

fprintf('✓ Complete!\n\n');

%% Helper function for plotting
function plot_2state_combination(data, label)
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
    
    % Count actual patients (exclude dummy point, 2 rows per patient)
    n_patients = (size(data, 1) - 1) / 2;
    
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