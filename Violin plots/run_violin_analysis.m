% run_violin_analysis.m
%
% Purpose: Runner script for violin plot analysis
%          Works in both interactive and batch modes
%
% Usage:
%   Interactive MATLAB:
%       run_violin_analysis()  % Will prompt for choices
%
%   Batch mode:
%       run_violin_analysis('all', false)               % All patients, no regenerate
%       run_violin_analysis('SE_damaging', true)        % With damage, regenerate CSVs
%       run_violin_analysis('SE_nondamaging', false)    % Without damage
%       run_violin_analysis('generate_all')             % All three versions
%
% Arguments:
%   mode: 'all', 'SE_damaging', 'SE_nondamaging', or 'generate_all' (default: 'all')
%   regenerate_csv: true/false (default: false in batch, prompt in interactive)
%
% Author: Jamie Lee
% Date: 7 October 2025

function run_violin_analysis(mode, regenerate_csv)
    
    % Detect if running in batch mode
    is_batch = usejava('desktop') == 0;
    
    % Set defaults
    if nargin < 1
        if is_batch
            mode = 'all';
        else
            mode = [];  % Will prompt
        end
    end
    
    if nargin < 2
        if is_batch
            regenerate_csv = false;
        else
            regenerate_csv = [];  % Will prompt
        end
    end
    
    clc;
    
    fprintf('\n========================================\n');
    fprintf('  VIOLIN PLOT ANALYSIS - RUNNER\n');
    if is_batch
        fprintf('  (Running in batch mode)\n');
    end
    fprintf('========================================\n\n');
    
    %% Step 1: Check for/Generate CSV files
    fprintf('Step 1: Checking for classification CSV files...\n');
    
    files_exist = exist('asymp.csv', 'file') && ...
                  exist('reversible.csv', 'file') && ...
                  exist('irreversible.csv', 'file');
    
    % Determine if we should regenerate CSVs
    if ~files_exist
        % Files don't exist - must generate
        fprintf('  CSV files not found. Generating them now...\n\n');
        generate_classification_csvs();
        
    elseif isempty(regenerate_csv)
        % Interactive mode - ask user
        fprintf('  ✓ CSV files found\n');
        response = input('  Regenerate CSV files? (y/n): ', 's');
        if strcmpi(response, 'y')
            fprintf('\n');
            generate_classification_csvs();
        end
        
    elseif regenerate_csv
        % Batch mode - regenerate requested
        fprintf('  ✓ CSV files found\n');
        fprintf('  Regenerating CSV files (as requested)...\n\n');
        generate_classification_csvs();
        
    else
        % Batch mode - use existing files
        fprintf('  ✓ CSV files found (using existing)\n');
    end
    
    %% Step 2: Choose plotting mode
    if isempty(mode)
        % Interactive mode - prompt user
        fprintf('\nStep 2: Select violin plot mode:\n');
        fprintf('  1. All patients (original behavior)\n');
        fprintf('  2. Only patients WITH skin damaging SE strains (delta_BE > 0)\n');
        fprintf('  3. Only patients WITHOUT skin damaging SE strains (delta_BE = 0)\n');
        fprintf('  4. Generate all three versions\n');
        
        choice = input('Enter choice (1-4): ', 's');
        fprintf('\n');
        
        switch choice
            case '1'
                mode = 'all';
            case '2'
                mode = 'SE_damaging';
            case '3'
                mode = 'SE_nondamaging';
            case '4'
                mode = 'generate_all';
            otherwise
                fprintf('Invalid choice. Running default (all)...\n\n');
                mode = 'all';
        end
    else
        % Batch mode - use parameter
        fprintf('\nStep 2: Using mode: %s\n\n', mode);
    end
    
    %% Step 3: Generate plots
    switch mode
        case 'all'
            plot_violin_parameters('all');
        case 'SE_damaging'
            plot_violin_parameters('SE_damaging');
        case 'SE_nondamaging'
            plot_violin_parameters('SE_nondamaging');
        case 'generate_all'
            fprintf('Generating all three versions...\n\n');
            plot_violin_parameters('all');
            plot_violin_parameters('SE_damaging');
            plot_violin_parameters('SE_nondamaging');
        otherwise
            error('Invalid mode: %s. Use: all, SE_damaging, SE_nondamaging, or generate_all', mode);
    end
    
    fprintf('\n========================================\n');
    fprintf('  ✓ ANALYSIS COMPLETE\n');
    fprintf('========================================\n\n');
end