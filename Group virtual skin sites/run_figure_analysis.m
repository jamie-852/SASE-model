% run_figure2_analysis.m
%
% Runner script to generate Figure 2 patient distribution plots
% Classifies patients by barrier status (B*), not by state count:
%   - Asymptomatic: All states with B* = 1
%   - Reversible: Mix of B* = 1 and B* < 1
%   - Irreversible: All states with B* < 1
%
% Can be run standalone or called from main pipeline
%
% Usage:
%   Standalone: run('run_figure2_analysis.m')
%   From main:  run_figure2_analysis(config)
%
% Author: Jamie Lee
% Date: 7 October 2025
% Version: 2.0 - Updated for barrier status classification

function run_figure_analysis(config)
    % If called without config, use defaults
    if nargin == 0
        config.data_folder = 'data';
        config.figures_folder = 'figures';
        config.date_str = datestr(now, 'yyyy-mm-dd');
    end
    
    fprintf('═══════════════════════════════════════════════════\n');
    fprintf('  Figure 2: Patient Distribution Analysis\n');
    fprintf('  Classification by Barrier Status (B*)\n');
    fprintf('═══════════════════════════════════════════════════\n\n');
    
    % Set workspace variables for the plotting script
    assignin('base', 'data_folder', config.data_folder);
    assignin('base', 'figures_folder', config.figures_folder);
    assignin('base', 'date_str', config.date_str);
    
    % Run the plotting script
    evalin('base', 'run(''plot_figure2_patient_distributions.m'')');
    
    fprintf('\n═══════════════════════════════════════════════════\n');
    fprintf('  Figure 2 Complete!\n');
    fprintf('═══════════════════════════════════════════════════\n');
end