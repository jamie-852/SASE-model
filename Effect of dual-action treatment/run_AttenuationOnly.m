% run_AttenuationOnly.m
%
% Runner script for attenuation-only treatment analysis
%
% This script simulates the effect of enhancing the skin's bacterial growth
% attenuation (gamma_AB and gamma_EB parameters) to determine how many
% patients with damaged skin can gain healthy states through this treatment.
%
% The attenuation-only treatment modifies the skin's parameters to make it
% more hostile to bacterial growth, potentially allowing damaged sites to recover.
%
% Prerequisites:
%   - Must have run g_ExtractInitialConditions.m
%   - ../Effect of SA-killing/data/irreversible_SAkilling.csv and/or 
%     ../Effect of SA-killing/data/reversible_SAkilling.csv must exist
%   - Helper functions from '../Analyse steady states/' must be in path
%
% Outputs:
%   - data/attenuation_[type]_[fold]x.csv (modified patients)
%   - data/attenuation_summary_[type]_[fold]x.csv (statistics)
%   - data/attenuation_combined_summary.csv (all results)
%
% Usage:
%   matlab -batch "run('run_AttenuationOnly.m')"
%
% Author: Jamie Lee
% Date: 13 October 2025

clc;
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║        Attenuation-Only Treatment Analysis           ║\n');
fprintf('║      (Parameter Enhancement Simulation)              ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Add path to helper functions
helper_path = '../Analyse steady states';
if exist(helper_path, 'dir')
    addpath(helper_path);
    fprintf('Added helper functions to path: %s\n', helper_path);
    
    % Verify critical functions exist
    required_functions = {'f_computeCase1', 'f_computeCase2', 'f_computeCase3', ...
                          'f_computeCase4', 'a_PatientGroups'};
    
    for i = 1:length(required_functions)
        if exist(required_functions{i}, 'file') ~= 2
            error('Cannot find %s.m in path. Please check helper functions folder.', ...
                  required_functions{i});
        end
    end
    fprintf('✓ All required helper functions found\n');
else
    error(['Cannot find helper functions folder: %s\n' ...
           'Please ensure ''Analyse steady states'' folder exists'], helper_path);
end
fprintf('\n');

%% Check prerequisites
fprintf('═══ Prerequisites Check ═══\n');

% Check for initial condition files
irrev_file = '../Effect of SA-killing/data/irreversible_SAkilling.csv';
rev_file = '../Effect of SA-killing/data/reversible_SAkilling.csv';

has_irrev = exist(irrev_file, 'file');
has_rev = exist(rev_file, 'file');

if ~has_irrev && ~has_rev
    error(['Missing initial condition files!\n' ...
           'Please run g_ExtractInitialConditions.m first']);
end

if has_irrev
    fprintf('✓ Found: %s\n', irrev_file);
    irrev_data = readmatrix(irrev_file);
    fprintf('  Irreversible patients: %d\n', size(irrev_data, 1));
end

if has_rev
    fprintf('✓ Found: %s\n', rev_file);
    rev_data = readmatrix(rev_file);
    fprintf('  Reversible patients: %d\n', size(rev_data, 1));
end

fprintf('\n');

%% Configuration
fprintf('═══ Analysis Configuration ═══\n');
fprintf('Treatment: Attenuation-Only Parameter Enhancement\n');
fprintf('  Mechanism: Enhance gamma_AB and gamma_EB\n');
fprintf('  Effect: Increases skin''s bacterial growth attenuation\n');
fprintf('\n');

% Fold-change values to test
fold_changes = [10, 20];  % Test 10x and 20x enhancement

fprintf('Fold-change values to test: ');
fprintf('%dx ', fold_changes);
fprintf('\n\n');

fprintf('Patient types to analyze:\n');
if has_irrev
    fprintf('  • Irreversible patients (%d sites)\n', size(irrev_data, 1));
end
if has_rev
    fprintf('  • Reversible patients (%d sites)\n', size(rev_data, 1));
end
fprintf('\n');

%% Analysis pipeline
total_runs = length(fold_changes) * (has_irrev + has_rev);
current_run = 0;

fprintf('═══ Running Simulations ═══\n');
fprintf('Total simulations: %d\n\n', total_runs);

results_summary = [];

for fold = fold_changes
    
    %% Irreversible patients
    if has_irrev
        current_run = current_run + 1;
        fprintf('╔═══════════════════════════════════════════════════════╗\n');
        fprintf('║  Simulation %d/%d: Irreversible @ %dx              ║\n', current_run, total_runs, fold);
        fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
        
        tic;
        g_AttenuationOnly('irreversible', fold);
        elapsed = toc;
        
        % Read summary
        summary_file = sprintf('data/attenuation_summary_irreversible_%dx.csv', fold);
        if exist(summary_file, 'file')
            summary = readmatrix(summary_file);
            results_summary = [results_summary; 0, summary];  % 0 = irreversible
        end
        
        fprintf('✓ Complete (%.1f seconds)\n\n', elapsed);
    end
    
    %% Reversible patients
    if has_rev
        current_run = current_run + 1;
        fprintf('╔═══════════════════════════════════════════════════════╗\n');
        fprintf('║  Simulation %d/%d: Reversible @ %dx                ║\n', current_run, total_runs, fold);
        fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
        
        tic;
        g_AttenuationOnly('reversible', fold);
        elapsed = toc;
        
        % Read summary
        summary_file = sprintf('data/attenuation_summary_reversible_%dx.csv', fold);
        if exist(summary_file, 'file')
            summary = readmatrix(summary_file);
            results_summary = [results_summary; 1, summary];  % 1 = reversible
        end
        
        fprintf('✓ Complete (%.1f seconds)\n\n', elapsed);
    end
end

%% Final Summary
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║            ALL SIMULATIONS COMPLETE                   ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

fprintf('═══ Results Summary ═══\n');
fprintf('%-15s %-10s %-12s %-12s %-10s\n', ...
    'Patient Type', 'Fold', 'Original', 'Healthy', 'Success');
fprintf('%-15s %-10s %-12s %-12s %-10s\n', ...
    '---------------', '----------', '------------', '------------', '----------');

for i = 1:size(results_summary, 1)
    if results_summary(i, 1) == 0
        type_str = 'Irreversible';
    else
        type_str = 'Reversible';
    end
    
    fprintf('%-15s %-10dx %-12d %-12d %-9.1f%%\n', ...
        type_str, results_summary(i, 2), results_summary(i, 3), ...
        results_summary(i, 4), results_summary(i, 5));
end

fprintf('\n');

% Save combined summary
combined_summary_file = 'data/attenuation_combined_summary.csv';
writematrix(results_summary, combined_summary_file);
fprintf('✓ Combined summary saved: %s\n', combined_summary_file);
fprintf('  Columns: [is_reversible, fold_change, n_original, n_healthy, percentage]\n\n');

fprintf('═══ Output Files Generated ═══\n');
fprintf('Modified patient data:\n');
for fold = fold_changes
    if has_irrev
        fprintf('  → data/attenuation_irreversible_%dx.csv\n', fold);
    end
    if has_rev
        fprintf('  → data/attenuation_reversible_%dx.csv\n', fold);
    end
end

fprintf('\nSummary statistics:\n');
for fold = fold_changes
    if has_irrev
        fprintf('  → data/attenuation_summary_irreversible_%dx.csv\n', fold);
    end
    if has_rev
        fprintf('  → data/attenuation_summary_reversible_%dx.csv\n', fold);
    end
end
fprintf('  → data/attenuation_combined_summary.csv\n\n');

fprintf('═══ Next Steps ═══\n');
fprintf('1. Review the percentage of patients gaining healthy states\n');
fprintf('2. For patients still with damaged states, consider:\n');
fprintf('   → Run dual-action treatment (attenuation + SA-killing)\n');
fprintf('   → Use: run_DualAction.m\n');
fprintf('\n');

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║                        DONE!                          ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');