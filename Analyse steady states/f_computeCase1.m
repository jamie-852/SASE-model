%% Compute steady states for when both SA and SE agr are inactive
%% (sw_A and sw_E = 0) as described in Supplementary Note S3.1. 
%% ________________________________________________________________________
function [Case1] = f_computeCase1(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
    gamma_EB, E_th, kappa_B, delta_B)

% pre-define vector to store steady states  
SteadyStates = zeros(1, 3);

% pre-define vector to store eigenvalues
EigVal = zeros(1, 3);

% Compute steady states based on equations in S3.1.: 
A_1 = (1 - ((delta_B*(1+gamma_AB))/kappa_A))*A_max;
E_1 = (1 - ((delta_B*(1+gamma_EB))/kappa_E))*E_max;
B_1 = 1; 

% There are four possible steady states where SA and SE agr are inactive
% Compute each of these four cases

%% A* and E* > 0
if A_1 > 0 && A_1 < A_th && E_1 > 0 && E_1 < E_th
    SteadyStates(1, 1) = A_1; 
    SteadyStates(1, 2) = E_1;
    SteadyStates(1, 3) = B_1;
else 
    SteadyStates(1, 1) = 0; 
    SteadyStates(1, 2) = 0;
    SteadyStates(1, 3) = 0;
end 

%% A* = 0 and E* > 0
if E_1 > 0 && E_1 < E_th
    SteadyStates(2, 1) = 0;
    SteadyStates(2, 2) = E_1;
    SteadyStates(2, 3) = B_1;
else 
    SteadyStates(2, 1) = 0; 
    SteadyStates(2, 2) = 0;
    SteadyStates(2, 3) = 0;
end 

%% A* > 0 and E* = 0
if A_1 > 0 && A_1 < A_th
    SteadyStates(3, 1) = A_1;
    SteadyStates(3, 2) = 0;
    SteadyStates(3, 3) = B_1;
else 
    SteadyStates(3, 1) = 0; 
    SteadyStates(3, 2) = 0;
    SteadyStates(3, 3) = 0;
end 

%% A* and E* = 0
SteadyStates(4, 1) = 0; 
SteadyStates(4, 2) = 0; 
SteadyStates(4, 3) = B_1; 

%% ________________________________________________________________________
%% Check whether these steady states are really steady states

%% ________________________________________________________________________
%% Check whether these steady states are stable by computing the 
%% eigenvalues of their Jacobian matrix
for i = 1:size(SteadyStates, 1)
    J_h = [- delta_B - (kappa_A*(SteadyStates(i, 1)/A_max - ...
        1))/(SteadyStates(i, 3)*gamma_AB + 1) - ...
        (SteadyStates(i, 1)*kappa_A)/(A_max*(SteadyStates(i, 3)*gamma_AB + 1)), 0, ... 
        (SteadyStates(i, 1)*gamma_AB*kappa_A*(SteadyStates(i, 1)/A_max - 1))/(SteadyStates(i, 3)*gamma_AB + 1)^2;
        0, - delta_B - (kappa_E*(SteadyStates(i, 2)/E_max - 1))/(SteadyStates(i, 3)*gamma_EB + 1) - ...
        (SteadyStates(i, 2)*kappa_E)/(E_max*(SteadyStates(i, 3)*gamma_EB + 1)), ...
        (SteadyStates(i, 2)*gamma_EB*kappa_E*(SteadyStates(i, 2)/E_max - 1))/(SteadyStates(i, 3)*gamma_EB + 1)^2;
        0, 0, -kappa_B];
    
    % compute eigenvalues
    stab = eig(J_h);
    if SteadyStates(i, :) == 0
        EigVal(i, 1:3) = 0;
    else 
        EigVal(i, 1) = stab(1);
        EigVal(i, 2) = stab(2);
        EigVal(i, 3) = stab(3);
    end 
end 

%% Combine steady states and corresponding eigenvalues
Case1 = [SteadyStates, EigVal];