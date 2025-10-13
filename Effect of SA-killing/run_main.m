% run_main.m
%
% Runner script to generate main text treatment response figures (Figure 3)
%
% This script:
%   1. Runs SA-killing treatment simulations (strength 0-5, duration 1-4 days)
%   2. Generates heatmap plots with contour lines
%
% Outputs:
%   - data/reversible_treatment_results.csv
%   - figures/Fig3_AllSites.png
%   - figures/Fig3_Reversible.png
%   - figures/Fig3_Irreversible.png
%
% Usage:
%   matlab -batch "run('run_main.m')"
%
% Author: Jamie Lee
% Date: 11 October 2025

clc;
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  Generating Main Text Figures (Figure 3)\n');
fprintf('═══════════════════════════════════════════════════════\n\n');

%% Step 1: Run treatment simulations
fprintf('[1/2] Running treatment response simulations...\n');
fprintf('      Parameters: Strength 0-5, Duration 1-4 days\n\n');

% Main text parameters: strength 0-5 (step 1), duration 1-4 days (step 0.5)
g_TreatmentResponse(0, 1, 5, 1, 0.5, 4);

fprintf('\n');

%% Step 2: Generate plots
fprintf('[2/2] Generating heatmap figures...\n\n');

g_Plot();

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  Figure 3 Generation Complete!\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('\nOutput files:\n');
fprintf('  → figures/Fig3_AllSites.png\n');
fprintf('  → figures/Fig3_Reversible.png\n');
fprintf('  → figures/Fig3_Irreversible.png\n\n');