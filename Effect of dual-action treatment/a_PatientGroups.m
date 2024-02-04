%% Script to analyse what type of stable state each patient has
% Assign patient to specific number (1 - 9) based on categories outlined in
% Supplementary Note 3
%% ________________________________________________________________________

% load saved matrix of patients
%AllVirtualPatients = readmatrix('AllVirtualPatients.csv');

AllVirtualPatients = real(AllVirtualPatients);

% store each case (1 - 9) in a vector
category = zeros(length(AllVirtualPatients), 1); 

% fixed parameters needed for checking conditions
A_max = AllVirtualPatients(1, 4); 
E_max = AllVirtualPatients(1, 11); 

parfor i = 1:size(AllVirtualPatients, 1)
    % parameters required to check type of stable state
    A_th            = AllVirtualPatients(i, 7); 
    gamma_AE        = AllVirtualPatients(i, 9);
    E_th            = AllVirtualPatients(i, 14);

    % steady state values
    A_ss            = AllVirtualPatients(i, 20); 
    E_ss            = AllVirtualPatients(i, 21); 
    B_ss            = AllVirtualPatients(i, 22); 
    
    % check whether agr-switches are on or off
    if E_ss >= E_th
        sw_E = 1;
    else
        sw_E = 0;
    end 
    
    if A_ss >= A_th*(1+gamma_AE*sw_E*E_ss)
        sw_A = 1;
    else
        sw_A = 0;
    end 

    % 1. A* = 0, E* = 0 and B* = 1                (sw_A = sw_E = 0)
    if (A_ss == 0 && E_ss == 0 && B_ss == 1) && (sw_A == 0 && sw_E == 0)
        category(i) = 1;
    end

    % 2. 0 < A* < A_th, E* = 0 and B* = 1         (sw_A = sw_E = 0)
    if (A_ss > 0 && A_ss < A_th && E_ss == 0 && B_ss == 1) && (sw_A == 0 ...
        && sw_E == 0)
        category(i) = 2;
    end 

    % 3. A* = 0, 0 < E* < E_th and B* = 1         (sw_A = sw_E = 0)
    if ((A_ss == 0 && E_ss < E_th && E_ss > 0 && B_ss == 1) && (sw_A == 0 ...
        && sw_E == 0)) || ((A_ss == 0 && E_ss >= E_th && E_ss <= E_max) && (sw_A == ...
        0 && sw_E == 1) && B_ss == 1)
        category(i) = 3;
    end 

    % 4. 0 < A* < A_th, 0 < E* < E_th and B* = 1  (sw_A = sw_E = 0)
    if (A_ss < A_th && A_ss > 0 && E_ss < E_th && E_ss > 0 && B_ss == 1) ...
        && (sw_A == 0 && sw_E == 0)
        category(i) = 4;
    end 

    % 5. A* = 0, E_th <= E* <= E_max and B* < 1   (sw_A = 0 and sw_E = 1)
    if ((A_ss == 0 && E_ss >= E_th && E_ss <= E_max) && (sw_A == ...
        0 && sw_E == 1) && B_ss < 1)
        category(i) = 5;
    end

    % 6. 0 < A* <= A_max, E_th <= E* <= E_max and B* = 1   (sw_A = 0 and sw_E = 1)
    if (A_ss <= A_max && A_ss > 0 && E_ss >= E_th && E_ss <= E_max) && ...
        (sw_A == 0 && sw_E == 1)
        category(i) = 6;
    end

    % 7. A_th <= A* <= A_max, E* = 0              (sw_A = 1 and sw_E = 0)
    if (A_ss >= A_th && A_ss <= A_max && E_ss == 0) && (sw_A == 1 && sw_E == 0)
        category(i) = 7;
    end

    % 8. A_th <= A* <= A_max, 0 < E* <= E_th      (sw_A = 1 and sw_E = 0)
    if (A_ss >= A_th && A_ss <= A_max && E_ss > 0 && E_ss <= E_th) && ...
        (sw_A == 1 && sw_E == 0)
        category(i) = 8;
    end

    % 9. A_th <= A* <= A_max, A_th <= E* <= E_max (sw_A = 1 and sw_E = 1)
    if (A_ss >= A_th && A_ss <= A_max && E_ss >= E_th && E_ss <= E_max) && ...
        (sw_A == 1 && sw_E == 1)
        category(i) = 9;
    end
end

AllVirtualPatientTypes = [AllVirtualPatients, category];