% g_PatientTypes_1.m
%
% Purpose: Plot virtual skin sites with ONE stable steady state
%          Groups by region categories (1-9, with regions 8 & 9 merged)
%
% Inputs:  AllVirtualPatientTypes (workspace) or One_StableState.csv
% Outputs: Figure with 8 subplots showing different single-state regions
%
% Author: Jamie Lee
% Date: 7 October 2025
% Version: 2.0 - Tidied and organized

clc;

fprintf('=== Plotting Patients with 1 Steady State ===\n\n');

%% Step 1: Load or filter data for 1-state patients
fprintf('[1/3] Loading data for 1-state patients...\n');

% Define data file path (relative to Group virtual skin sites folder)
data_file = '../Analyse steady states/data/AllVirtualPatientTypes_latest.csv';

% Option 1: Filter from workspace variable
if exist('AllVirtualPatientTypes', 'var')
    fprintf('  Using AllVirtualPatientTypes from workspace\n');
    PatientsOne = [];
    for i = 1:size(AllVirtualPatientTypes, 1)
        if AllVirtualPatientTypes(i, 2) == 1
            PatientsOne = [PatientsOne; AllVirtualPatientTypes(i, :)];
        end 
    end
    writematrix(PatientsOne, 'One_StableState.csv');
    fprintf('  ✓ Saved One_StableState.csv\n');
    
% Option 2: Load from filtered file
elseif exist('One_StableState.csv', 'file')
    fprintf('  Loading from One_StableState.csv\n');
    PatientsOne = readmatrix('One_StableState.csv');
    fprintf('  ✓ Loaded\n');
    
% Option 3: Load and filter from main data file
elseif exist(data_file, 'file')
    fprintf('  Loading and filtering from %s\n', data_file);
    AllVirtualPatientTypes = readmatrix(data_file);
    PatientsOne = [];
    for i = 1:size(AllVirtualPatientTypes, 1)
        if AllVirtualPatientTypes(i, 2) == 1
            PatientsOne = [PatientsOne; AllVirtualPatientTypes(i, :)];
        end 
    end
    writematrix(PatientsOne, 'One_StableState.csv');
    fprintf('  ✓ Filtered and saved One_StableState.csv\n');
    
else
    error(['No data found. Need one of:\n' ...
           '  1. AllVirtualPatientTypes variable in workspace\n' ...
           '  2. One_StableState.csv file in current directory\n' ...
           '  3. %s file'], data_file);
end

fprintf('  Total: %d patients with 1 steady state\n', size(PatientsOne, 1));

%% Step 2: Preprocess for log-scale plotting
fprintf('\n[2/3] Preprocessing for log-scale plotting...\n');

logPatientsOne = PatientsOne;

% Replace zero populations with 1 for log plotting
for i = 1:size(PatientsOne, 1)
    if PatientsOne(i, 20) == 0 && PatientsOne(i, 21) == 0
        logPatientsOne(i, 20) = 1;
        logPatientsOne(i, 21) = 1;  
    elseif PatientsOne(i, 20) == 0 && PatientsOne(i, 21) > 0
        logPatientsOne(i, 20) = 1;
    elseif PatientsOne(i, 21) == 0 && PatientsOne(i, 20) > 0
        logPatientsOne(i, 21) = 1;  
    end
    
    % Set damaged barrier (B* < 1) to 0.1 for red coloring
    if PatientsOne(i, 22) < 1
        logPatientsOne(i, 22) = 0.1;
    end
end

fprintf('  ✓ Preprocessed %d rows\n', size(logPatientsOne, 1));

%% Step 3: Sort into region categories
fprintf('\n[3/3] Grouping by region categories...\n');

% Region definitions (from Supplementary Note 3):
% 1. A* = 0, E* = 0, B* = 1
% 2. 0 < A* < A_th, E* = 0, B* = 1
% 3. A* = 0, 0 < E* < E_th, B* = 1 (includes region 5 with B*=1)
% 4. 0 < A* < A_th, 0 < E* < E_th, B* = 1
% 5. A* = 0, E_th <= E* <= E_max, B* < 1
% 6. 0 < A* < A_th, E_th <= E* <= E_max, B* = 1
% 7. A_th <= A* <= A_max, E* = 0
% 8/9. A_th <= A* <= A_max, E* > 0 (regions 8 and 9 merged)

case_1 = []; case_2 = []; case_3 = []; case_4 = [];
case_5 = []; case_6 = []; case_7 = []; case_9 = [];

for j = 1:size(logPatientsOne, 1)
    region = logPatientsOne(j, 26);
    B_star = logPatientsOne(j, 22);
    
    if region == 1
        case_1 = [case_1; logPatientsOne(j, :)];
    elseif region == 2
        case_2 = [case_2; logPatientsOne(j, :)];
    elseif region == 3 || (region == 5 && B_star == 1)
        % Combine region 3 with non-damaging region 5
        case_3 = [case_3; logPatientsOne(j, :)];
    elseif region == 4
        case_4 = [case_4; logPatientsOne(j, :)];
    elseif region == 5 && B_star < 1
        % Keep only damaging region 5
        case_5 = [case_5; logPatientsOne(j, :)];
    elseif region == 6
        case_6 = [case_6; logPatientsOne(j, :)];
    elseif region == 7
        case_7 = [case_7; logPatientsOne(j, :)];
    elseif region == 8 || region == 9
        % Merge regions 8 and 9
        case_9 = [case_9; logPatientsOne(j, :)];
    end
end

fprintf('  ✓ Sorted into 8 region categories\n');

%% Step 4: Add dummy point for colormap scaling
limits = zeros(1, 26); 
limits(22) = 1.2;

case_1 = [case_1; limits]; case_2 = [case_2; limits];
case_3 = [case_3; limits]; case_4 = [case_4; limits];
case_5 = [case_5; limits]; case_6 = [case_6; limits];
case_7 = [case_7; limits]; case_9 = [case_9; limits];

%% Step 5: Create figure with subplots
fprintf('\nGenerating figure...\n');

figure('Name', 'Virtual Skin Sites - 1 Steady State', 'Position', [100, 100, 1200, 600]);

cases = {case_1, case_2, case_3, case_4, case_5, case_6, case_7, case_9};
titles = {'Region 1', 'Region 2', 'Regions 3/5', 'Region 4', ...
          'Region 5*', 'Region 6', 'Region 7', 'Regions 8/9'};

for i = 1:8
    subplot(2, 4, i);
    plot_single_case(cases{i}, titles{i});
end

sgtitle('Virtual Skin Sites with 1 Steady State', 'FontSize', 16, 'FontWeight', 'bold');

% Save figure as PNG
output_file = 'PatientTypes_1_SteadyState.png';
print(output_file, '-dpng', '-r300');
fprintf('✓ Figure saved as: %s\n', output_file);

fprintf('✓ Figure complete!\n\n');

%% Helper function for plotting
function plot_single_case(data, region_name)
    % Plot a single region category
    
    if size(data, 1) <= 1
        % Empty or only dummy point
        text(0.5, 0.5, 'No data', 'HorizontalAlignment', 'center', ...
            'FontSize', 12, 'Units', 'normalized');
        axis([0 11 0 11]);
        set(gca, 'FontSize', 14);
        title(sprintf('%s\nn=0', region_name));
        return;
    end
    
    % Count actual patients (exclude dummy point)
    n_patients = size(data, 1) - 1;
    
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
    
    title(sprintf('%s\nn=%d', region_name, n_patients));
end