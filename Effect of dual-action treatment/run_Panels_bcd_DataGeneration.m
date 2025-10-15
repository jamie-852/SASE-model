% run_Panels_bcd_DataGeneration.m
%
% Generate data for Panels (b), (c), (d): 3×3 attenuation grids
% Tests all combinations of SA and SE fold-changes
%
% Author: Jamie Lee
% Date: October 14, 2025

clear; clc; close all;

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║     Panels (b-d): Attenuation Grid Data Generation   ║\n');
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
fprintf('Estimated time: 2-4 hours\n\n');

fprintf('⚠️  This will take a long time! Press Ctrl+C to cancel or any key to continue...\n');
pause;
fprintf('\n');

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
fprintf('║              DATA GENERATION COMPLETE                 ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');
fprintf('Total time: %.1f hours\n\n', total_time/3600);

%% Save results
fprintf('Saving results...\n');

% Save matrices
writematrix(results.all_sites, 'data/panel_b_all_sites.csv');
writematrix(results.irreversible, 'data/panel_c_irreversible.csv');
writematrix(results.reversible, 'data/panel_d_reversible.csv');

% Save complete results structure
save('data/panels_bcd_results.mat', 'results');

fprintf('  ✓ data/panel_b_all_sites.csv\n');
fprintf('  ✓ data/panel_c_irreversible.csv\n');
fprintf('  ✓ data/panel_d_reversible.csv\n');
fprintf('  ✓ data/panels_bcd_results.mat\n\n');

%% Display results summary
fprintf('═══ RESULTS SUMMARY ═══\n\n');

fprintf('Panel (b) - All damaged sites:\n');
disp(results.all_sites);

fprintf('\nPanel (c) - Irreversible sites:\n');
disp(results.irreversible);

fprintf('\nPanel (d) - Reversible sites:\n');
disp(results.reversible);

fprintf('\nNext step: Run run_Panels_bcd_Plot.m to generate figures\n');