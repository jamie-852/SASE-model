clc 
clear all
%% Script to plot patient types with three stable states
% Separate patients types depending on (1) number of stable states and (2)
% location of stable states
% _______________________________________________________________________
% identify patients with three stable states
%{
PatientsThree = [];

parfor i = 1:length(AllVirtualPatientTypes)
    if AllVirtualPatientTypes(i, 2) == 3
        PatientsThree = [PatientsThree; AllVirtualPatientTypes(i, :)];
    end 
end 

writematrix(PatientsThree, 'Three_StableState.csv');
%}

% duplicate to plot 
% for those with 0 CFU/cm^2 at stable state, set them = 1 so they lie on
% axis in log10 scale.

PatientsThree = readmatrix('Three_StableState.csv');

logPatientsThree = PatientsThree;
for i = 1:length(PatientsThree)
    if PatientsThree(i, 20) == 0 && PatientsThree(i, 21) == 0
        logPatientsThree(i, 20) = 1;
        logPatientsThree(i, 21) = 1;  
    elseif PatientsThree(i, 20) == 0 && PatientsThree(i, 21) > 0
        logPatientsThree(i, 20) = 1;
    elseif PatientsThree(i, 21) == 0 && PatientsThree(i, 20) > 0
        logPatientsThree(i, 21) = 1;  
    end

    % we define a healthy state by B = 1 and a damaged state by B < 1
    if PatientsThree(i, 22) < 1
        logPatientsThree(i, 22) = 0.1;
    end
end

%% create a scatter plot for each case
% ________________________________________________________________________
% combine 8. and 9. based on Supplementary Note 3

% 1. A* = 0, E* = 0 and B* = 1                (sw_A = sw_E = 0)
% 2. 0 < A* < A_th, E* = 0 and B* = 1         (sw_A = sw_E = 0)
% 3. A* = 0, 0 < E* < E_th and B* = 1         (sw_A = sw_E = 0)
% 4. 0 < A* < A_th, 0 < E* < E_th and B* = 1  (sw_A = sw_E = 0)
% 5. A* = 0, E_th <= E* <= E_max and B* = 1   (sw_A = 0 and sw_E = 1)
% 6. 0 < A* < A_th, E_th <= E* <= E_max and B* = 1   (sw_A = 0 and sw_E = 1)
% 7. A_th <= A* <= A_max, E* = 0              (sw_A = 1 and sw_E = 0)
% 8. A_th <= A* <= A_max, 0 < E* <= E_th      (sw_A = 1 and sw_E = 0)
% 9. A_th <= A* <= A_max, A_th <= E* <= E_max (sw_A = 1 and sw_E = 1)

% consider all possible combinations (8 choose 3 = 56)
v = uint16([1 2 3 4 5 6 7 8 9]);
C = nchoosek(v,uint16(3));

% sort patient based on the types of stable states they have
comb = [];
for j = 1 : length(C)
    for k = 1 : (length(logPatientsThree)-2)
        if (logPatientsThree(k, 1) == logPatientsThree(k + 1, 1) && logPatientsThree(k + 1, 1) == ...
            logPatientsThree(k + 2, 1)) && ((logPatientsThree(k, 26) == C(j, 1) || logPatientsThree(k + 1, 26) == C(j, 1) || ...
            logPatientsThree(k + 2, 26) == C(j, 1)) && (logPatientsThree(k, 26) == C(j, 2) || ...
            logPatientsThree(k + 1, 26) == C(j, 2) || logPatientsThree(k + 2, 26) == C(j, 2)) ...
            && (logPatientsThree(k, 26) == C(j, 3) || logPatientsThree(k + 1, 26) == C(j, 3) || ...
            logPatientsThree(k + 2, 26) == C(j, 3)))

            order = [logPatientsThree(k, :); logPatientsThree(k + 1, :); ...
                logPatientsThree(k + 2, :)];

            comb = [comb; order];
        end
    end 
end 
%}

% separate patients into each patient type (20 combinations in this sample)
comb_1 = []; 
comb_2 = []; 
comb_3 = []; 
comb_4 = []; 
comb_5 = []; 
comb_6 = []; 
comb_7 = []; 
comb_8 = []; 
comb_9 = []; 
comb_10 = []; 
comb_11 = []; 
comb_12 = []; 
comb_13 = []; 
comb_14 = []; 
comb_15 = []; 
comb_16 = []; 
comb_17 = []; 
comb_18 = []; 
comb_19 = []; 
comb_20 = [];
comb_21 = []; 
comb_22 = []; 
comb_23 = []; 
comb_24 = []; 
comb_25 = []; 
comb_26 = []; 
comb_27 = []; 
comb_28 = []; 
comb_29 = []; 
comb_30 = [];
comb_31 = [];

parfor k = 1 : (length(comb) - 2)
    if (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 5 || ...
            comb(k + 1, 26) == 5 || comb(k + 2, 26) == 5) ...
            && (comb(k, 26) == 7 || comb(k + 1, 26) == 7 || ...
            comb(k + 2, 26) == 7))

        add_1 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_1 = [comb_1; add_1];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 5 || ...
            comb(k + 1, 26) == 5 || comb(k + 2, 26) == 5) ...
            && (comb(k, 26) == 8 || comb(k + 1, 26) == 8 || ...
            comb(k + 2, 26) == 8))

        add_2 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_2 = [comb_2; add_2];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 5 || ...
            comb(k + 1, 26) == 5 || comb(k + 2, 26) == 5) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_3 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_3 = [comb_3; add_3];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
            comb(k + 2, 26) == 6))

        add_4 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_4 = [comb_4; add_4];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 8 || ...
            comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
            && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
            comb(k + 2, 26) == 6))

        add_5 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_5 = [comb_5; add_5];

   elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 9 || ...
            comb(k + 1, 26) == 9 || comb(k + 2, 26) == 9) ...
            && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
            comb(k + 2, 26) == 6))

        add_6 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_6 = [comb_6; add_6];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 8 || ...
            comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_7 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_7 = [comb_7; add_7];
     
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
            comb(k + 2, 26) == 5))

        add_8 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_8 = [comb_8; add_8];
   
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 8 || ...
            comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
            && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
            comb(k + 2, 26) == 5))

        add_9 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_9 = [comb_9; add_9];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 9 || ...
            comb(k + 1, 26) == 9 || comb(k + 2, 26) == 9) ...
            && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
            comb(k + 2, 26) == 5))

        add_10 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_10 = [comb_10; add_10];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
            comb(k + 2, 26) == 6))

        add_11 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_11 = [comb_11; add_11];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
        comb(k + 2, 26) == 2) && (comb(k, 26) == 8 || ...
        comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
        && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
        comb(k + 2, 26) == 6))

        add_12 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_12 = [comb_12; add_12];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
        comb(k + 2, 26) == 3) && (comb(k, 26) == 7 || ...
        comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
        && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
        comb(k + 2, 26) == 5))

        add_13 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_13 = [comb_13; add_13];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
        comb(k + 2, 26) == 3) && (comb(k, 26) == 8 || ...
        comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
        && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
        comb(k + 2, 26) == 5))

        add_14 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_14 = [comb_14; add_14];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
        comb(k + 2, 26) == 3) && (comb(k, 26) == 7 || ...
        comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
        && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
        comb(k + 2, 26) == 6))

        add_15 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_15 = [comb_15; add_15];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
        comb(k + 2, 26) == 3) && (comb(k, 26) == 6 || ...
        comb(k + 1, 26) == 6 || comb(k + 2, 26) == 6) ...
        && (comb(k, 26) == 8 || comb(k + 1, 26) == 8 || ...
        comb(k + 2, 26) == 8))

        add_16 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_16 = [comb_16; add_16];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
        comb(k + 2, 26) == 4) && (comb(k, 26) == 7 || ...
        comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
        && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
        comb(k + 2, 26) == 5))

        add_17 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_17 = [comb_17; add_17];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
        comb(k + 2, 26) == 4) && (comb(k, 26) == 8 || ...
        comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
        && (comb(k, 26) == 5 || comb(k + 1, 26) == 5 || ...
        comb(k + 2, 26) == 5))

        add_18 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_18 = [comb_18; add_18];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
        comb(k + 2, 26) == 4) && (comb(k, 26) == 7 || ...
        comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
        && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
        comb(k + 2, 26) == 6))

        add_19 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_19 = [comb_19; add_19];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
        ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
        comb(k + 2, 26) == 4) && (comb(k, 26) == 8 || ...
        comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
        && (comb(k, 26) == 6 || comb(k + 1, 26) == 6 || ...
        comb(k + 2, 26) == 6))

        add_20 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_20 = [comb_20; add_20];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 8 || comb(k + 1, 26) == 8 || ...
            comb(k + 2, 26) == 8))

        add_21 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_21 = [comb_21; add_21];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 8 || comb(k + 1, 26) == 8 || ...
            comb(k + 2, 26) == 8))

        add_22 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_22 = [comb_22; add_22];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
            comb(k + 2, 26) == 3) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 8 || comb(k + 1, 26) == 8 || ...
            comb(k + 2, 26) == 8))

        add_23 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_23 = [comb_23; add_23];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
            comb(k + 2, 26) == 4) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 8 || comb(k + 1, 26) == 8 || ...
            comb(k + 2, 26) == 8))

        add_24 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_24 = [comb_24; add_24];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 1 || comb(k + 1, 26) == 1 || ...
            comb(k + 2, 26) == 1) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_25 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_25 = [comb_25; add_25];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_26 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_26 = [comb_26; add_26];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
            comb(k + 2, 26) == 3) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_27 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_27 = [comb_27; add_27];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
            comb(k + 2, 26) == 4) && (comb(k, 26) == 7 || ...
            comb(k + 1, 26) == 7 || comb(k + 2, 26) == 7) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_28 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_28 = [comb_28; add_28];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 2 || comb(k + 1, 26) == 2 || ...
            comb(k + 2, 26) == 2) && (comb(k, 26) == 8 || ...
            comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_29 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_29 = [comb_29; add_29];

    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 3 || comb(k + 1, 26) == 3 || ...
            comb(k + 2, 26) == 3) && (comb(k, 26) == 8 || ...
            comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_30 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_30 = [comb_30; add_30];
    
    elseif (comb(k, 1) == comb(k + 1, 1) && comb(k + 1, 1) == comb(k + 2, 1)) && ... 
            ((comb(k, 26) == 4 || comb(k + 1, 26) == 4 || ...
            comb(k + 2, 26) == 4) && (comb(k, 26) == 8 || ...
            comb(k + 1, 26) == 8 || comb(k + 2, 26) == 8) ...
            && (comb(k, 26) == 9 || comb(k + 1, 26) == 9 || ...
            comb(k + 2, 26) == 9))

        add_31 = [comb(k, :); comb(k + 1, :); ...
                comb(k + 2, :)];
        comb_31 = [comb_31; add_31];
    end 
end 
%}

% add an extra "fake" barrier integrity value so that the colormap has less
% contrast. 

limits = zeros(1, 26); 
limits(22) = 1.2;
comb_1 = [comb_1; limits]; 
comb_2 = [comb_2; limits]; 
comb_3 = [comb_3; limits]; 
comb_4 = [comb_4; limits]; 
comb_5 = [comb_5; limits];  
comb_6 = [comb_6; limits]; 
comb_7 = [comb_7; limits]; 
comb_8 = [comb_8; limits]; 
comb_9 = [comb_9; limits]; 
comb_10 = [comb_10; limits]; 
comb_11 = [comb_11; limits]; 
comb_12 = [comb_12; limits]; 
comb_13 = [comb_13; limits]; 
comb_14 = [comb_14; limits]; 
comb_15 = [comb_15; limits]; 
comb_16 = [comb_16; limits];
comb_17 = [comb_17; limits];  
comb_18 = [comb_18; limits]; 
comb_19 = [comb_19; limits]; 
comb_20 = [comb_20; limits]; 
comb_21 = [comb_21; limits]; 
comb_22 = [comb_22; limits]; 
comb_23 = [comb_23; limits]; 
comb_24 = [comb_24; limits]; 
comb_25 = [comb_25; limits]; 
comb_26 = [comb_26; limits];
comb_27 = [comb_27; limits];  
comb_28 = [comb_28; limits]; 

% _________________________________________________________________________
subplot(4,5,1)
scatter(log10(comb_1(:,20)), log10(comb_1(:,21)), ...
    300, comb_1(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');

caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4, 5, 2)
scatter(log10(comb_8(:,20)), log10(comb_8(:,21)), ...
    300, comb_8(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,3)
scatter(log10(comb_13(:,20)), log10(comb_13(:,21)), ...
    300, comb_13(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,4)
scatter(log10(comb_17(:,20)), log10(comb_17(:,21)), ...
    300, comb_17(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');

caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,5)
scatter(log10(comb_4(:,20)), log10(comb_4(:,21)), ...
    300, comb_4(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,6)
scatter(log10(comb_11(:,20)), log10(comb_11(:,21)), ...
    300, comb_11(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,7)
scatter(log10(comb_15(:,20)), log10(comb_15(:,21)), ...
    300, comb_15(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)


subplot(4,5,8)
scatter(log10(comb_19(:,20)), log10(comb_19(:,21)), ...
    300, comb_19(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,9)
scatter(log10(comb_2(:,20)), log10(comb_2(:,21)), ...
    300, comb_2(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');

hold on 
scatter(log10(comb_3(:,20)), log10(comb_3(:,21)), ...
    300, comb_3(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)


subplot(4,5,10)
scatter(log10(comb_9(:,20)), log10(comb_9(:,21)), ...
    300, comb_9(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');

caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)


subplot(4,5,11)
scatter(log10(comb_14(:,20)), log10(comb_14(:,21)), ...
    300, comb_14(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,12)
scatter(log10(comb_18(:,20)), log10(comb_18(:,21)), ...
    300, comb_18(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,13)
scatter(log10(comb_5(:,20)), log10(comb_5(:,21)), ...
    300, comb_5(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');

caxis([0 1.5]);
colormap autumn
axis([0 11 0 11])

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,14)
scatter(log10(comb_12(:,20)), log10(comb_12(:,21)), ...
    300, comb_12(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn


xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,15)
scatter(log10(comb_16(:,20)), log10(comb_16(:,21)), ...
    300, comb_16(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,16)
scatter(log10(comb_20(:,20)), log10(comb_20(:,21)), ...
    300, comb_20(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,17)
scatter(log10(comb_25(:,20)), log10(comb_25(:,21)), ...
    300, comb_25(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(4,5,18)
scatter(log10(comb_30(:,20)), log10(comb_30(:,21)), ...
    300, comb_30(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)
%}