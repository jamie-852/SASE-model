% g_ClassificationFiles.m
% 
% Purpose: Generate classification files for violin plots
%          Separates virtual patients into three categories based on their
%          stable states and barrier function (B*) values
%
% Input:  AllVirtualPatientTypes.csv (or .mat) - 26 columns
%         Columns 1-17: Model parameters
%         Columns 18-20: Steady states (A*, E*, B*)
%         Columns 21-23: Eigenvalues
%         Columns 24-26: Classifications
%
% Output: Three CSV files for violin plot generation:
%         - asymp.csv: Patients with ONLY B*=1 (asymptomatic)
%         - rev_SAkilling.csv: Patients with B*=1 AND B*<1 (reversible)
%         - irrev_SAkilling.csv: Patients with ONLY B*<1 (irreversible)
%
% Author: [Your name]
% Date: [Date]
% Version: 1.0

%% Clear workspace and load data
clear all;
close all;
clc;

fprintf('=== Classification File Generator ===\n');
fprintf('Loading virtual patient data...\n');

% Load the AllVirtualPatientTypes file
% Adjust the filename if your file has a different name
filename = 'AllVirtualPatientTypes.csv';

if ~exist(filename, 'file')
    % Try .mat file if CSV doesn't exist
    filename_mat = 'AllVirtualPatientTypes.mat';
    if exist(filename_mat, 'file')
        data = load(filename_mat);
        % Extract the data array (adjust variable name if needed)
        fieldnames_list = fieldnames(data);
        all_data = data.(fieldnames_list{1});
    else
        error('Could not find AllVirtualPatientTypes.csv or .mat file');
    end
else
    all_data = readmatrix(filename);
end

fprintf('Loaded %d virtual patients\n', size(all_data, 1));

%% Extract relevant columns
% Assuming each virtual patient may have multiple rows (one per stable state)
% Column 1: Site ID
% Column 20: B* (barrier function steady state)
% Column 24: Type classification (if available)

site_ids = all_data(:, 1);
B_star = all_data(:, 20);

% Precision threshold for comparing B* to 1.0
% Adjust this threshold based on your numerical precision
B_threshold = 1e-6;  % B* is considered 1.0 if abs(B* - 1) < threshold

%% Group by virtual patient site ID
unique_sites = unique(site_ids);
n_sites = length(unique_sites);

fprintf('Processing %d unique virtual skin sites...\n', n_sites);

% Initialize storage for each category
asymp_sites = [];
rev_sites = [];
irrev_sites = [];

% Classification counters
n_asymp = 0;
n_rev = 0;
n_irrev = 0;

%% Classify each virtual patient
for i = 1:n_sites
    % Get all rows for this site
    site_mask = site_ids == unique_sites(i);
    site_data = all_data(site_mask, :);
    site_B_values = B_star(site_mask);
    
    % Check for healthy (B* ≈ 1) and damaged (B* < 1) states
    has_healthy = any(abs(site_B_values - 1.0) < B_threshold);
    has_damaged = any(site_B_values < (1.0 - B_threshold));
    
    % Classify based on stable states
    if has_healthy && ~has_damaged
        % Asymptomatic: Only healthy states (B* = 1)
        asymp_sites = [asymp_sites; site_data];
        n_asymp = n_asymp + 1;
        
    elseif has_healthy && has_damaged
        % Reversible: Both healthy and damaged states
        rev_sites = [rev_sites; site_data];
        n_rev = n_rev + 1;
        
    elseif ~has_healthy && has_damaged
        % Irreversible: Only damaged states (B* < 1)
        irrev_sites = [irrev_sites; site_data];
        n_irrev = n_irrev + 1;
        
    else
        % Edge case: no clear classification (shouldn't happen)
        warning('Site %d has no clear classification', unique_sites(i));
    end
end

%% Display classification summary
fprintf('\n=== Classification Summary ===\n');
fprintf('Asymptomatic (only B*=1):      %d sites (%.1f%%)\n', ...
    n_asymp, 100*n_asymp/n_sites);
fprintf('Reversible (B*=1 and B*<1):    %d sites (%.1f%%)\n', ...
    n_rev, 100*n_rev/n_sites);
fprintf('Irreversible (only B*<1):      %d sites (%.1f%%)\n', ...
    n_irrev, 100*n_irrev/n_sites);
fprintf('Total:                         %d sites\n', n_sites);

%% Save classification files
fprintf('\n=== Saving Classification Files ===\n');

% Save asymptomatic
if ~isempty(asymp_sites)
    writematrix(asymp_sites, 'asymp.csv');
    fprintf('Saved asymp.csv: %d rows\n', size(asymp_sites, 1));
else
    warning('No asymptomatic sites found');
end

% Save reversible
if ~isempty(rev_sites)
    writematrix(rev_sites, 'rev_SAkilling.csv');
    fprintf('Saved rev_SAkilling.csv: %d rows\n', size(rev_sites, 1));
else
    warning('No reversible sites found');
end

% Save irreversible
if ~isempty(irrev_sites)
    writematrix(irrev_sites, 'irrev_SAkilling.csv');
    fprintf('Saved irrev_SAkilling.csv: %d rows\n', size(irrev_sites, 1));
else
    warning('No irreversible sites found');
end

fprintf('\n=== Classification Complete ===\n');
fprintf('Files are ready for violin plot generation\n');

%% Optional: Create a summary visualization
figure('Position', [100, 100, 800, 600]);

% Pie chart of classifications
labels = {'Asymptomatic', 'Reversible', 'Irreversible'};
counts = [n_asymp, n_rev, n_irrev];
colors = [0.2, 0.8, 0.2;  % Green for asymptomatic
          1.0, 0.8, 0.0;  % Yellow for reversible
          0.8, 0.2, 0.2]; % Red for irreversible

pie(counts, labels);
colormap(colors);
title(sprintf('Virtual Patient Classification (N=%d)', n_sites), ...
      'FontSize', 14, 'FontWeight', 'bold');

% Save figure
saveas(gcf, 'classification_summary.png');
fprintf('Saved classification_summary.png\n');

%% End of script