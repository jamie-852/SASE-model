% run_supplementary.m
g_TreatmentResponse(0, 2.5, 10, 2, 12, 50);
g_Plot_Supplementary();

% run_supplementary.m
%
% Runner script to generate supplementary treatment response figures (Figure S2)
%
% This script:
%   1. Runs SA-killing treatment simulations (strength 0-10, duration 2-50 days)
%   2. Generates heatmap plots with exact values (no contour lines)
%
% Outputs:
%   - data/reversible_treatment_results.csv
%   - figures/FigS2_AllSites.png
%   - figures/FigS2_Reversible.png
%   - figures/FigS2_Irreversible.png
%
% Usage:
%   matlab -batch "run('run_supplementary.m')"
%
% Author: Jamie Lee
% Date: 11 October 2025

clc;
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  Generating Supplementary Figures (Figure S2)\n');
fprintf('═══════════════════════════════════════════════════════\n\n');

%% Step 1: Run treatment simulations
fprintf('[1/2] Running treatment response simulations...\n');
fprintf('      Parameters: Strength 0-10, Duration 2-50 days\n\n');

% Main text parameters: strength 0-10 (step 1), duration 2-50 days (step 2)
g_TreatmentResponse(0, 2, 10, 2, 2, 50);

fprintf('\n');

%% Step 2: Generate plots
fprintf('[2/2] Generating heatmap figures...\n\n');

g_Plot_Supplementary();

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  Figure S2 Generation Complete!\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('\nOutput files:\n');
fprintf('  → figures/FigS2_AllSites.png\n');
fprintf('  → figures/FigS2_Reversible.png\n');
fprintf('  → figures/FigS2_Irreversible.png\n\n');