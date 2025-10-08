% generate_classification_csvs.m
%
% Purpose: Generate CSV files for asymptomatic, reversible, and irreversible
%          virtual skin sites based on barrier status (B*) classification
%
% Inputs:  AllVirtualPatientTypes.csv (or from workspace)
% Outputs: asymp.csv, reversible.csv, irreversible.csv
%
% Classification:
%   - Asymptomatic: ALL steady states have B* = 1 (healthy barrier)
%   - Irreversible: ALL steady states have B* < 1 (damaged barrier)
%   - Reversible: MIX of B* = 1 and B* < 1 states
%
% Author: Jamie Lee
% Date: 7 October 2025

clc;

fprintf('=== Generating Classification CSV Files ===\n\n');

%% Step 1: Load data
fprintf('[1/3] Loading data...\n');

data_file = '../Analyse steady states/data/AllVirtualPatientTypes_latest.csv';

if exist('AllVirtualPatientTypes', 'var')
    fprintf('  Using AllVirtualPatientTypes from workspace\n');
    data = AllVirtualPatientTypes;
elseif exist(data_file, 'file')
    fprintf('  Loading from %s\n', data_file);
    data = readmatrix(data_file);
else
    error('No data found. Need AllVirtualPatientTypes in workspace or %s', data_file);
end

fprintf('  ✓ Loaded %d rows\n', size(data, 1));

%% Step 2: Classify patients by barrier status
fprintf('\n[2/3] Classifying patients by barrier status (B*)...\n');

asymptomatic = [];
irreversible = [];
reversible = [];

i = 1;
while i <= size(data, 1)
    num_states = data(i, 2);  % Column 2: number of steady states
    
    % Extract all rows for this patient
    patient_rows = data(i:(i + num_states - 1), :);
    
    % Extract B* values (column 22)
    B_values = patient_rows(:, 22);
    
    % Count healthy vs damaged states
    n_healthy = sum(B_values == 1);
    n_damaged = sum(B_values < 1);
    n_total = length(B_values);
    
    % Classify based on B* distribution
    if n_healthy == n_total
        % ALL healthy → Asymptomatic
        asymptomatic = [asymptomatic; patient_rows];
    elseif n_damaged == n_total
        % ALL damaged → Irreversible
        irreversible = [irreversible; patient_rows];
    else
        % MIX → Reversible
        reversible = [reversible; patient_rows];
    end
    
    % Move to next patient
    i = i + num_states;
end

fprintf('  ✓ Classification complete:\n');
fprintf('    Asymptomatic: %d patients\n', size(asymptomatic, 1));
fprintf('    Irreversible: %d patients\n', size(irreversible, 1));
fprintf('    Reversible:   %d patients\n', size(reversible, 1));

%% Step 3: Save CSV files
fprintf('\n[3/3] Saving CSV files...\n');

writematrix(asymptomatic, 'asymp.csv');
fprintf('  ✓ Saved asymp.csv (%d rows)\n', size(asymptomatic, 1));

writematrix(irreversible, 'irreversible.csv');
fprintf('  ✓ Saved irreversible.csv (%d rows)\n', size(irreversible, 1));

writematrix(reversible, 'reversible.csv');
fprintf('  ✓ Saved reversible.csv (%d rows)\n', size(reversible, 1));

fprintf('\n=== CSV Generation Complete ===\n\n');