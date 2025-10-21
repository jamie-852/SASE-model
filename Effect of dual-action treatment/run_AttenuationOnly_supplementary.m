% run_AttenuationOnly_supplementary.m
%
% Purpose: Generate dual-action attenuation results and heatmap figures (Figure S6b-d)
%
% Inputs:  ../Effect of SA-killing/data/reversible_SAkilling.csv
%          ../Effect of SA-killing/data/irreversible_SAkilling.csv
%
% Outputs: data/AttenuationOnly_All_Sites.csv (weighted combined results)
%          data/AttenuationOnly_Irreversible.csv (irreversible patients only)
%          data/AttenuationOnly_Reversible.csv (reversible patients only)
%          data/AttenuationOnly_Results.mat (complete results structure)
%          figures/FigureS6_AttenuationHeatmaps.png
%          figures/FigureS6_AttenuationHeatmaps.fig
%
% Usage:
%   run_AttenuationOnly_supplementary()
%
% Author: Jamie Lee
% Date: October 14, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║     Figure S6: Attenuation Heatmap Generation        ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Configuration
SA_folds = [1, 10, 20];
SE_folds = [1, 10, 20];
patient_types = {'reversible', 'irreversible'};

fprintf('Grid configuration:\n');
fprintf('  SA fold-changes: [%s]\n', sprintf('%d ', SA_folds));
fprintf('  SE fold-changes: [%s]\n', sprintf('%d ', SE_folds));
fprintf('  Total combinations: %d (3×3)\n\n', length(SA_folds) * length(SE_folds));

total_runs = length(SA_folds) * length(SE_folds) * length(patient_types);
fprintf('Total simulations: %d\n', total_runs);
fprintf('Estimated time: Approx. 1 hour with 12 cores\n\n');

%% Load patient counts for weighting
fprintf('Loading patient counts...\n');

rev_file = '../Effect of SA-killing/data/reversible_SAkilling.csv';
irrev_file = '../Effect of SA-killing/data/irreversible_SAkilling.csv';

if ~exist(rev_file, 'file') || ~exist(irrev_file, 'file')
    error('Cannot find initial condition files. Please run g_ExtractInitialConditions.m first');
end

rev_data = readmatrix(rev_file);
irrev_data = readmatrix(irrev_file);

n_rev = size(rev_data, 1);
n_irrev = size(irrev_data, 1);
n_total = n_rev + n_irrev;

fprintf('  Reversible patients: %d (%.1f%%)\n', n_rev, 100*n_rev/n_total);
fprintf('  Irreversible patients: %d (%.1f%%)\n', n_irrev, 100*n_irrev/n_total);
fprintf('  Total patients: %d\n\n', n_total);

%% Storage for results
results = struct();
results.SA_folds = SA_folds;
results.SE_folds = SE_folds;
results.reversible = zeros(length(SE_folds), length(SA_folds));
results.irreversible = zeros(length(SE_folds), length(SA_folds));
results.all_sites = zeros(length(SE_folds), length(SA_folds));

% Create output folder
if ~exist('data', 'dir'), mkdir('data'); end

%% Main loop
current_run = 0;
total_start = tic;

for sa_idx = 1:length(SA_folds)
    for se_idx = 1:length(SE_folds)
        SA_fold = SA_folds(sa_idx);
        SE_fold = SE_folds(se_idx);
        
        fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
        fprintf('║  Grid point: SA=%dx, SE=%dx                           \n', SA_fold, SE_fold);
        fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
        
        % Storage for this combination
        rev_pct = 0;
        irrev_pct = 0;
        
        for type_idx = 1:length(patient_types)
            patient_type = patient_types{type_idx};
            current_run = current_run + 1;
            
            fprintf('[Run %d/%d] %s patients\n', current_run, total_runs, patient_type);
            
            run_start = tic;
            
            % Run attenuation with these fold-changes
            [~, percentage] = g_AttenuationFlexible(patient_type, SA_fold, SE_fold);
            
            run_time = toc(run_start);
            fprintf('  ✓ Complete: %.1f%% gained healthy state (%.1f sec)\n\n', percentage, run_time);
            
            % Store results
            if strcmp(patient_type, 'reversible')
                rev_pct = percentage;
                results.reversible(se_idx, sa_idx) = percentage;
            else
                irrev_pct = percentage;
                results.irreversible(se_idx, sa_idx) = percentage;
            end
        end
        
        % Calculate weighted combined percentage
        % Weight by actual number of patients in each group
        rev_count_healthy = (rev_pct / 100) * n_rev;
        irrev_count_healthy = (irrev_pct / 100) * n_irrev;
        total_healthy = rev_count_healthy + irrev_count_healthy;
        combined_pct = 100 * total_healthy / n_total;
        
        results.all_sites(se_idx, sa_idx) = combined_pct;
        
        fprintf('═══ Summary for SA=%dx, SE=%dx ═══\n', SA_fold, SE_fold);
        fprintf('  Reversible: %.1f%% (%d/%d patients)\n', rev_pct, round(rev_pct/100*n_rev), n_rev);
        fprintf('  Irreversible: %.1f%% (%d/%d patients)\n', irrev_pct, round(irrev_pct/100*n_irrev), n_irrev);
        fprintf('  All sites (weighted): %.1f%% (%d/%d patients)\n\n', ...
                combined_pct, round(combined_pct/100*n_total), n_total);
    end
end

total_time = toc(total_start);
fprintf('\n╔═══════════════════════════════════════════════════════╗\n');
fprintf('║              SIMULATION COMPLETE                       ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
fprintf('Total time: %.1f hours\n\n', total_time/3600);

%% Save results
fprintf('Saving results...\n');

% Save matrices
writematrix(results.all_sites, 'data/AttenuationOnly_All_Sites.csv');
writematrix(results.irreversible, 'data/AttenuationOnly_Irreversible.csv');
writematrix(results.reversible, 'data/AttenuationOnly_Reversible.csv');

% Save complete results structure
save('data/AttenuationOnly_Results.mat', 'results');

fprintf('  ✓ data/AttenuationOnly_All_Sites.csv\n');
fprintf('  ✓ data/AttenuationOnly_Irreversible.csv\n');
fprintf('  ✓ data/AttenuationOnly_Reversible.csv\n');
fprintf('  ✓ data/AttenuationOnly_Results.mat\n\n');

%% Display results summary
fprintf('═══ RESULTS SUMMARY ═══\n\n');

fprintf('Figure S6 (b) - All damaged sites:\n');
disp(results.all_sites);

fprintf('\nFigure S6 (c) - Irreversible sites:\n');
disp(results.irreversible);

fprintf('\nFigure S6 (d) - Reversible sites:\n');
disp(results.reversible);

fprintf('\n');

%% Generate plots automatically
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║            Generating Heatmap Figures                 ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

g_Plot_AttenuationOnly();

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║            WORKFLOW COMPLETE                          ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');
fprintf('\nGenerated:\n');
fprintf('  → data/AttenuationOnly_All_Sites.csv\n');
fprintf('  → data/AttenuationOnly_Irreversible.csv\n');
fprintf('  → data/AttenuationOnly_Reversible.csv\n');
fprintf('  → figures/FigureS6_AttenuationHeatmaps.png\n');
fprintf('  → figures/FigureS6_AttenuationHeatmaps.fig\n\n');