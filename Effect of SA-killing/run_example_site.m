% run_example_site.m
%
% Runner script to generate example site treatment response figure
%
% This script analyzes ONE example reversible patient in high resolution
% to demonstrate the narrow therapeutic window for successful treatment.
%
% Prerequisites:
%   - Must have run g_ExtractInitialConditions.m (part of run_main.m)
%   - data/reversible_SAkilling.csv must exist (for treatment simulations)
%   - ../Analyse steady states/data/AllVirtualPatientTypes_latest.csv must exist (for phase portrait)
%
% Outputs:
%   - figures/ExampleSite_PhasePortrait.png (shows ALL steady states)
%   - data/example_site_results.csv (detailed treatment results grid)
%   - figures/ExampleSite_TreatmentResponse.png (treatment heatmap)
%
% Usage:
%   matlab -batch "run('run_example_site.m')"
%
% Author: Jamie Lee
% Date: 13 October 2025

clc;
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║        Example Site Treatment Response Analysis       ║\n');
fprintf('║              (Supplementary Figure)                   ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

%% Check prerequisites
fprintf('═══ Prerequisites Check ═══\n');

ic_file = 'data/reversible_SAkilling.csv';
steady_state_file = '../Analyse steady states/data/AllVirtualPatientTypes_latest.csv';

if ~exist(ic_file, 'file')
    error(['Missing initial condition file!\n' ...
           'Please run run_main.m first (which includes g_ExtractInitialConditions.m)']);
end

if ~exist(steady_state_file, 'file')
    % Try alternative path
    steady_state_file = 'data/AllVirtualPatientTypes_latest.csv';
    if ~exist(steady_state_file, 'file')
        error(['Missing steady state file!\n' ...
               'Cannot find AllVirtualPatientTypes_latest.csv']);
    end
end

fprintf('✓ Initial condition file found: %s\n', ic_file);
fprintf('✓ Steady state file found: %s\n\n', steady_state_file);

%% Configuration
patient_to_analyze = 289986;  % Patient ID (not row index!)

fprintf('═══ Analysis Configuration ═══\n');
fprintf('Patient to analyze: ID %d\n', patient_to_analyze);
fprintf('\n');
fprintf('⚠️  IMPORTANT: This is the Patient ID (column 1), not a row number!\n');
fprintf('   To find available patient IDs, check reversible_SAkilling.csv\n');
fprintf('\n');
fprintf('This analysis will:\n');
fprintf('  1. Visualize ALL patient steady states (phase portrait)\n');
fprintf('     → Reads from: AllVirtualPatientTypes_latest.csv\n');
fprintf('     → Shows all 2-3 steady states for this reversible patient\n');
fprintf('\n');
fprintf('  2. Run high-resolution treatment simulations\n');
fprintf('     → Reads from: reversible_SAkilling.csv (ONE initial condition)\n');
fprintf('     → Tests 9,191 treatment combinations\n');
fprintf('\n');
fprintf('Fine-resolution parameter grid:\n');
fprintf('  Strength: 0 to 5 days⁻¹ (step 0.05) = 101 values\n');
fprintf('  Duration: 1 to 10 days (step 0.1) = 91 values\n');
fprintf('  Total combinations: 9,191\n');
fprintf('\n');
fprintf('⚠️  Note: This is MUCH finer resolution than main analysis\n');
fprintf('    Main analysis: 42 combinations\n');
fprintf('    This analysis: 9,191 combinations (~220x more detail)\n');
fprintf('\n');

%% Step 1: Visualize ALL steady states
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 1/2: Visualize ALL Patient Steady States       ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

tic;
g_VisualiseExampleSite(patient_to_analyze);
elapsed_viz = toc;

fprintf('\n✓ Step 1 complete (%.1f seconds)\n\n', elapsed_viz);

%% Step 2: Run treatment analysis
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║  STEP 2/2: High-Resolution Treatment Analysis        ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

tic;
g_ExampleSiteAnalysis(patient_to_analyze);
elapsed_analysis = toc;

%% Summary
fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║              ANALYSIS COMPLETE                        ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n\n');

total_elapsed = elapsed_viz + elapsed_analysis;

fprintf('═══ Execution Summary ═══\n');
fprintf('Total time: %.1f minutes\n', total_elapsed/60);
fprintf('  Step 1 (Phase portrait): %.0f seconds\n', elapsed_viz);
fprintf('  Step 2 (Treatment sims): %.0f seconds (%.1f minutes)\n', elapsed_analysis, elapsed_analysis/60);
fprintf('Simulations: 9,191 treatment combinations\n');
fprintf('Patient analyzed: ID %d\n\n', patient_to_analyze);

fprintf('═══ Output Files ═══\n');
fprintf('Phase Portrait:\n');
fprintf('  → figures/ExampleSite_PhasePortrait.png\n');
fprintf('    Shows ALL steady states in SA-SE space\n');
fprintf('    (Read from AllVirtualPatientTypes_latest.csv)\n');
fprintf('\n');
fprintf('Detailed Results:\n');
fprintf('  → data/example_site_results.csv\n');
fprintf('    (9,191 rows: strength, duration, final_A, final_E, final_B)\n');
fprintf('\n');
fprintf('Treatment Heatmap:\n');
fprintf('  → figures/ExampleSite_TreatmentResponse.png\n');
fprintf('    High-resolution treatment response map\n');
fprintf('    (Based on ONE initial condition from reversible_SAkilling.csv)\n');
fprintf('\n');

fprintf('═══ What These Figures Show ═══\n');
fprintf('\n');
fprintf('FIGURE 1: Phase Portrait (ExampleSite_PhasePortrait.png)\n');
fprintf('  • Shows WHERE the patient''s steady states are located\n');
fprintf('  • Multiple dots: This patient has 2-3 steady states (reversible!)\n');
fprintf('  • Dot positions: (SA*, SE*) bacterial populations\n');
fprintf('  • Dot colors: Barrier integrity (green=healthy, red=damaged)\n');
fprintf('  • Dashed lines: Quorum sensing thresholds (A_th, E_th)\n');
fprintf('  • Helps understand: Why this patient is reversible\n');
fprintf('\n');
fprintf('FIGURE 2: Treatment Response (ExampleSite_TreatmentResponse.png)\n');
fprintf('  • Shows HOW the patient responds to different treatments\n');
fprintf('  • Starting from ONE of the damaged steady states\n');
fprintf('  • Yellow/Orange: Successful (converges to B* = 1)\n');
fprintf('  • Red: Failed (remains at B* < 1)\n');
fprintf('  • Reveals: NARROW therapeutic window\n');
fprintf('  • Key finding: Only specific strength/duration combos work!\n');
fprintf('\n');

fprintf('═══ To Analyze Different Patients ═══\n');
fprintf('Edit run_example_site.m and change:\n');
fprintf('  patient_to_analyze = %d;  %% Must be a valid Patient ID!\n', patient_to_analyze);
fprintf('\n');
fprintf('To find valid Patient IDs:\n');
fprintf('  1. Open data/reversible_SAkilling.csv\n');
fprintf('  2. Look at column 1 (Patient ID)\n');
fprintf('  3. Choose any ID from that column\n\n');

fprintf('╔═══════════════════════════════════════════════════════╗\n');
fprintf('║                        DONE!                          ║\n');
fprintf('╚═══════════════════════════════════════════════════════╝\n');