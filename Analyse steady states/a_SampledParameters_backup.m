%% Compute steady states for all sampled parameters 
% _______________________________________________________________________
clc
clear all

% load SampledParameters.csv file where parameters are sampled using 
% gen_samples.m
ds = tabularTextDatastore('data/SampledParameters_latest.csv');

% pre-define output matrix
AllSteadyStates  = zeros(1, 23); 

% store derivatives 
n_ss    = zeros(1, 3);

while hasdata(ds)
    T = read(ds);
    ParamSet = table2array(T); 
    
    parfor i = 1:size(ParamSet, 1)
        kappa_A         = 10^ParamSet(i, 1);
        A_max           = ParamSet(i, 2); 

        gamma_AB        = 10^ParamSet(i, 3);
        delta_AE        = 10^ParamSet(i, 4);
        A_th            = 10^ParamSet(i, 5); 
        E_pth           = 10^ParamSet(i, 6); 
        gamma_AE        = 10^ParamSet(i, 7); 
    
        kappa_E         = 10^ParamSet(i, 8);
        E_max           = ParamSet(i, 9); 
        gamma_EB        = 10^ParamSet(i, 10);
        delta_EA        = 10^ParamSet(i, 11);
        E_th            = 10^ParamSet(i, 12); 
        A_pth           = 10^ParamSet(i, 13); 
    
        kappa_B         = 10^ParamSet(i, 14);
        delta_B         = 10^ParamSet(i, 15); 
        delta_BA        = 10^ParamSet(i, 16);
        
        if ParamSet(i, 17) < -10 
            delta_BE = 0;
        else
            delta_BE    = 10^ParamSet(i, 17); 
        end
        
        % parameter set for one virtual patient
        VirtualPatient = [kappa_A, A_max, gamma_AB, delta_AE, A_th, ... 
            E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
            E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE];
        
        % compute steady states for each scenario 
        [output_1] = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
    gamma_EB, E_th, kappa_B, delta_B);
        
        [output_2] = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
    gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA);
        
        [output_3] = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, ...
    kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B, delta_BE)
        
        [output_4] = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, gamma_AE, ...
    kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE)
        
%% Scenario where SA and SE agr are inactive
% ________________________________________________________________
        SteadyState_1 = output_1

        % remove rows with only zeros
        SteadyState_1(~any(SteadyState_1,2), :) = []

        % repeat parameter set for each steady state 
        Params = repelem(VirtualPatient, size(SteadyState_1, 1), 1);
        
        % matrix of parameter sets and their steady states for Case 1
        output_one = [Params, SteadyState_1];

        %% Scenario where only SA agr are active
        % ________________________________________________________________
        SteadyState_2 = output_2;

        % remove rows with only zeros
        SteadyState_2(~any(SteadyState_2,2), : ) = [];

        % repeat parameter set for each steady state 
        Params = repelem(VirtualPatient, size(SteadyState_2, 1), 1);
        
        % matrix of parameter sets and their steady states for Case 2
        output_two = [Params, SteadyState_2];

        %% Scenario where only SE agr are active
        % ________________________________________________________________
        SteadyState_3 = output_3;

        % remove rows with only zeros
        SteadyState_3(~any(SteadyState_3,2), : ) = [];

        % repeat parameter set for each steady state 
        Params = repelem(VirtualPatient, size(SteadyState_3, 1), 1);
        
        % matrix of parameter sets and their steady states for Case 3
        output_three = [Params, SteadyState_3];

        %% Scenario where both SA and SE agr are active
        % ________________________________________________________________
        SteadyState_4 = output_4;

        % remove rows with only zeros
        SteadyState_4(~any(SteadyState_4,2), : ) = [];

        % repeat parameter set for each steady state 
        Params = repelem(VirtualPatient, size(SteadyState_4, 1), 1);
        
        % matrix of parameter sets and their steady states for Case 4
        output_four = [Params, SteadyState_4];
        
        %% Combining all possible steady states for one patient
        % one matrix of all steady states for one patient
        SteadyStates = [output_one; output_two; output_three; output_four];

        % steady states for all 10^6 virtual patients
        AllSteadyStates = [AllSteadyStates; SteadyStates];
    end 
end 

writematrix(AllSteadyStates, 'AllSteadyStates.csv');