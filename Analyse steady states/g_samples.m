clc
clear all
% ranges explored for each parameter value defined in Table 1 of 
% Supplementary Note S2

% number of samples (10^6)
% vectors describe lower and upper bounds of parameters
% all parameters are sampled from a log uniform distribution

% initialise random number generator to make the results in this example
% repeatable 
rng(0, 'twister');

%% growth, inhibitions and killing of S. aureus: ________________________
%kappa_A         = [9, 27]
%log(kappa_A)    = [0.954, 1.431]
log_kappa_A = (1.431 - 0.954).*rand(10^6,1) + 0.954;

%A_max           = 11.1*10^8;
%log(A_max)      = 9.045;
A_max = repelem(11.1*10^8, 10^6);
A_max = A_max.';

%gamma_AB        = [587*10^(-1), 587*10]      
%log(gamma_AB)   = [1.769, 3.769]
log_gamma_AB = (3.769 - 1.769).*rand(10^6,1) + 1.769;

%delta_AE        = [478*10^(-2), 478]          
%log(delta_AE)   = [0.679, 2.679]
log_delta_AE = (2.679 - 0.679).*rand(10^6,1) + 0.679;

%A_th            = [1.13*10^(-1), 11.1]*10^8    
%log(A_th)       = [7.053, 9.045]
log_A_th = (9.045 - 7.053).*rand(10^6,1) + 7.053;

%E_pth           = [1.13*10^(-1), 11.1]*10^8    
%log(E_pth)      = [7.053, 9.045]
log_E_pth = (9.045 - 7.053).*rand(10^6,1) + 7.053;

%gamma_AE        = [1.30*10^(-1), 1.30*10]*10^(-8)                  
%log(gamma_AE)   = [-8.886, -6.886]
log_gamma_AE = (-6.886 - (-8.886)).*rand(10^6,1) -8.886;

%% growth, inhibitions and killings of S. epidermidis: ___________________
%kappa_E         = [9, 27]
%log(kappa_E)    = [0.954, 1.431]
log_kappa_E = (1.431 - 0.954).*rand(10^6,1) + 0.954;

%E_max           = 11.1*10^8;
%log(E_max)      = 9.045;
E_max = repelem(11.1*10^8, 10^6);
E_max = E_max.';

%gamma_EB        = [558*10^(-1), 558*10]   
%log(gamma_EB)   = [1.747, 3.747]
log_gamma_EB = (3.747 - 1.747).*rand(10^6,1) + 1.747;

%delta_EA        = [478*10^(-2), 478]
%log(delta_EA)   = [0.679, 2.679]
log_delta_EA = (2.679 - 0.679).*rand(10^6,1) + 0.679;

%E_th            = [1.13*10^(-1), 11.1]*10^8   
%log(E_th)       = [7.053, 9.045]
log_E_th = (9.045 - 7.053).*rand(10^6,1) + 7.053;

%A_pth           = [1.13*10^(-1), 11.1]*10^8  
%log(A_pth)      = [7.053, 9.045]
log_A_pth = (9.045 - 7.053).*rand(10^6,1) + 7.053;

%% turnover and damage to barrier integrity: _____________________________
%kappa_B         = [0.0711*10^(-1), 0.0711*10]
%log(kappa_B)    = [-2.148, -0.148]
log_kappa_B = (-0.148 - (-2.148)).*rand(10^6,1) -2.148;

%delta_B         = [0.0289*10^(-1), 0.0289*10]
%log(delta_B)    = [-2.539, -0.539]
log_delta_B = (-0.539 - (-2.539)).*rand(10^6,1) -2.539;

%delta_BA        = [0.1*10^(-1), 0.1*10]*10^(-8)
%log(delta_BA)   = [-10, -8]
log_delta_BA = (-8 - (-10)).*rand(10^6,1) -10;

%delta_BE        = [0, 0.1*10]*10^(-8)
%log(delta_BE)   = [-12, -8]
log_delta_BE = (-8 - (-12)).*rand(10^6,1) -12;

% combine parameter samples in one giant matrix
samples = [log_kappa_A, A_max, log_gamma_AB, log_delta_AE, log_A_th, log_E_pth, ...
    log_gamma_AE, log_kappa_E, E_max, log_gamma_EB, log_delta_EA, log_E_th, ...
    log_A_pth, log_kappa_B, log_delta_B, log_delta_BA, log_delta_BE];

writematrix(samples,'SampledParameters_Apr2023.csv');