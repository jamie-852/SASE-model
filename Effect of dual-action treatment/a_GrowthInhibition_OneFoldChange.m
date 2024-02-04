% This script computes the number of healthy skin states observed when
% bacterial growth attenuation by the skin is enhanced by X-fold 
% (example used here is 20-fold as seen in manuscript).

% How strongly is SA growth attenuation by the skin enhanced? 
fold_gAB = 20;

% How strongly is SE growth attenuation by the skin enhanced? 
fold_gEB = 20;

% Input virtual skin sites ('irrev_SAkilling.csv' or 'rev_SAkilling.csv')
skin_sites = readmatrix('irrev_SAkilling.csv');

AllSteadyStates = [];
AllStableStates = [];

ParamSet = skin_sites(:, 3:19);

parfor i = 1:size(ParamSet, 1)

    kappa_A         = ParamSet(i, 1);
    A_max           = ParamSet(i, 2); 
    
    % Enhancement of SA growth attenuation by the skin
    gamma_AB        = fold_gAB*ParamSet(i, 3);
    delta_AE        = ParamSet(i, 4);
    A_th            = ParamSet(i, 5); 
    E_pth           = ParamSet(i, 6); 
    gamma_AE        = ParamSet(i, 7); 

    kappa_E         = ParamSet(i, 8);
    E_max           = ParamSet(i, 9); 

    % Enhancement of SE growth attenuation by the skin
    gamma_EB        = fold_gEB*ParamSet(i, 10);
    delta_EA        = ParamSet(i, 11);
    E_th            = ParamSet(i, 12); 
    A_pth           = ParamSet(i, 13); 

    kappa_B         = ParamSet(i, 14);
    delta_B         = ParamSet(i, 15); 
    delta_BA        = ParamSet(i, 16); 
    delta_BE        = ParamSet(i, 17); 
    
    VirtualPatient = [kappa_A, A_max, gamma_AB, delta_AE, A_th, ... 
        E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
        E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE];
    
    [output_1] = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
    gamma_EB, E_th, kappa_B, delta_B);
    
    [output_2] = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
    gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA);
    
    [output_3] = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, ...
    kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B, delta_BE);
    
    [output_4] = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, gamma_AE, ...
    kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE);

    %% Scenario where SA and SE agr are inactive
    % ________________________________________________________________
    SteadyState_1 = real(output_1);

    % remove rows with only zeros
    SteadyState_1(~any(SteadyState_1,2), :) = [];

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
    SteadyState_3 = real(output_3);

    % remove rows with only zeros
    SteadyState_3(~any(SteadyState_3,2), : ) = [];

    % repeat parameter set for each steady state 
    Params = repelem(VirtualPatient, size(SteadyState_3, 1), 1);
    
    % matrix of parameter sets and their steady states for Case 3
    output_three = [Params, SteadyState_3];

    %% Scenario where both SA and SE agr are active
    % ________________________________________________________________
    SteadyState_4 = real(output_4);

    % remove rows with only zeros
    SteadyState_4(~any(SteadyState_4,2), : ) = [];

    % repeat parameter set for each steady state 
    Params = repelem(VirtualPatient, size(SteadyState_4, 1), 1);
    
    % matrix of parameter sets and their steady states for Case 4
    output_four = [Params, SteadyState_4];
    
    %% Combining all possible steady states for one patient
    % one matrix of all steady states for one patient
    SteadyStates = [output_one; output_two; output_three; output_four];

    % steady states for all irreversible patients 
    AllSteadyStates = [AllSteadyStates; SteadyStates];
end

parfor j = 1:size(AllSteadyStates, 1)
     if (AllSteadyStates(j, 21) < 0 && AllSteadyStates(j, 22) < 0 && ...
            AllSteadyStates(j, 23) < 0)
        AllStableStates = [AllStableStates; AllSteadyStates(j, :)];
     end 
end

% count the number of unique parameter sets
Param = AllStableStates(:, 1:17);

% find unique rows, retaining order using 'stable'
[C, ia, ic] = unique(Param, 'rows', 'stable'); 

% count occurances
count = accumarray(ic, 1);

% map occurances to 'ic' values
map = count(ic);

% numbered virtual patients
numVirtualPatients = [ic, map, Param];
AllVirtualPatients = [numVirtualPatients, AllStableStates(:, 18:23)];

% assign categories 1 - 9 for each skin site depending on characteristic SA
% and SE population sizes (see Supplementary Note 3)
a_PatientGroups;

% if SA and SE population sizes fall into categories 1 - 4 as described by 
% figure of Supplementary Note 3, there is a healthy skin state.
count_1 = sum(AllVirtualPatientTypes(:, 26) == 1);
count_2 = sum(AllVirtualPatientTypes(:, 26) == 2);
count_3 = sum(AllVirtualPatientTypes(:, 26) == 3);
count_4 = sum(AllVirtualPatientTypes(:, 26) == 4);

% compute total number of virtual skin sites that gain a healthy skin state
count = count_1 + count_2 + count_3 + count_4;
count_alt = sum(AllVirtualPatientTypes(:, 22) == 1);

% computes percentage with a healthy skin state
percentageoutput = count/length(skin_sites);

% the percentage of virtual skin sites with a healthy skin state for
% different enhancements of bacterial growth attenuation (fold_gAB and fold_gEB)
% can be found in Data/FoldChange_RevSystems and Data/FoldChange_IrrevSystems

% we simulate SA-killing from the damaged skin states with bacterial growth
% attenuation applied. 
writematrix(AllVirtualPatients, 'IrrevSystems2020FoldChange_17May.csv'); 