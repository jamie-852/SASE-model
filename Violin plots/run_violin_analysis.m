% run_violin_analysis.m
%
% Purpose: Runner script for violin plot analysis
%
% Usage:
%       run_violin_analysis()                           % Default: all patients, no regenerate
%       run_violin_analysis('all', false)               % All patients, no regenerate
%       run_violin_analysis('SE_damaging', true)        % With damage, regenerate CSVs
%       run_violin_analysis('SE_nondamaging', false)    % Without damage
%       run_violin_analysis('generate_all')             % All three versions
%
% Arguments:
%   mode: 'all', 'SE_damaging', 'SE_nondamaging', or 'generate_all' (default: 'all')
%   regenerate_csv: true/false (default: false)
%
% Author: Jamie Lee
% Date: 7 October 2025

function run_violin_analysis(mode, regenerate_csv)
    
    % Set defaults
    if nargin < 1
        mode = 'all';
    end
    
    if nargin < 2
        regenerate_csv = false;
    end
    
    clc;
    
    fprintf('\n========================================\n');
    fprintf('  VIOLIN PLOT ANALYSIS - RUNNER\n');
    fprintf('========================================\n\n');
    
    %% Step 1: Check for/Generate CSV files
    fprintf('Step 1: Checking for classification CSV files...\n');
    
    files_exist = exist('../Analyse steady states/data/asymp.csv', 'file') && ...
                  exist('../Analyse steady states/data/reversible.csv', 'file') && ...
                  exist('../Analyse steady states/data/irreversible.csv', 'file');
    
    % Determine if we should regenerate CSVs
    if ~files_exist
        % Files don't exist - must generate
        fprintf('  CSV files not found. Generating them now...\n\n');
        run('../Analyse steady states/g_classification_csvs.m');
        
    elseif regenerate_csv
        % Regenerate requested
        fprintf('  ✓ CSV files found\n');
        fprintf('  Regenerating CSV files (as requested)...\n\n');
        run('../Analyse steady states/g_classification_csvs.m');
        
    else
        % Use existing files
        fprintf('  ✓ CSV files found (using existing)\n');
    end
    
    %% Step 2: Choose plotting mode
    fprintf('\nStep 2: Using mode: %s\n\n', mode);
    
    %% Step 3: Generate plots
    switch mode
        case 'all'
            g_violin_plot('all');
        case 'SE_damaging'
            g_violin_plot('SE_damaging');
        case 'SE_nondamaging'
            g_violin_plot('SE_nondamaging');
        case 'generate_all'
            fprintf('Generating all three versions...\n\n');
            g_violin_plot('all');
            g_violin_plot('SE_damaging');
            g_violin_plot('SE_nondamaging');
        otherwise
            error('Invalid mode: %s. Use: all, SE_damaging, SE_nondamaging, or generate_all', mode);
    end
    
    fprintf('\n========================================\n');
    fprintf('  ✓ ANALYSIS COMPLETE\n');
    fprintf('========================================\n\n');
end