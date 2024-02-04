%% Compute steady states for when SA is active and
%% SE agr is inactive (sw_A = 1 and sw_E = 0)
%% as described in Supplementary Note S3.2. 
% _______________________________________________________________________
function [Case2] = f_computeCase2(kappa_A, A_max, gamma_AB, A_th, kappa_E, E_max, ...
    gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA)

% pre-define vector to store steady states 
SteadyStates = zeros(1, 3);

% pre-define vector to store eigenvalues
EigVal = zeros(1, 3);

% There are two solutions to the quadratic solution for A* when SA agr 
% is active, A_2a and A_2b: 
A_2a = -(kappa_A*kappa_B - (kappa_A^2*kappa_B^2 + ...
    A_max^2*delta_B^2*delta_BA^2 + A_max^2*delta_BA^2*kappa_A^2 + ...
    2*A_max*delta_BA*kappa_A^2*kappa_B - ...
    2*A_max^2*delta_B*delta_BA^2*kappa_A - ...
    2*A_max*delta_B*delta_BA*kappa_A*kappa_B - ...
    4*A_max*delta_B*delta_BA*gamma_AB*kappa_A*kappa_B)^(1/2) + ...
    A_max*delta_B*delta_BA - A_max*delta_BA*kappa_A)/(2*delta_BA*kappa_A);

A_2b = -(kappa_A*kappa_B + (kappa_A^2*kappa_B^2 + ...
    A_max^2*delta_B^2*delta_BA^2 + A_max^2*delta_BA^2*kappa_A^2 + ...
    2*A_max*delta_BA*kappa_A^2*kappa_B - ...
    2*A_max^2*delta_B*delta_BA^2*kappa_A - ...
    2*A_max*delta_B*delta_BA*kappa_A*kappa_B - ...
    4*A_max*delta_B*delta_BA*gamma_AB*kappa_A*kappa_B)^(1/2) + ...
    A_max*delta_B*delta_BA - A_max*delta_BA*kappa_A)/(2*delta_BA*kappa_A);

% We compute the corresponding steady states for E* and A* based on A_2a 
% and A_2b: 
if isreal(A_2a) && (A_2a >= A_th && A_2a <= A_max)
    B_2a = kappa_B/(kappa_B + delta_BA*A_2a); 
    E_2a = E_max*(1-((delta_EA*(A_2a/(A_2a+A_pth))+delta_B)*((1 + ...
    gamma_EB*B_2a)/kappa_E)));
else 
    A_2a = 0;
    E_2a = 0;
    B_2a = 0;
end 

if isreal(A_2b) && (A_2b >= A_th && A_2b <= A_max) 
    B_2b = kappa_B/(kappa_B + delta_BA*A_2b);
    E_2b = E_max*(1-((delta_EA*(A_2b/(A_2b+A_pth))+delta_B)*((1 + ...
    gamma_EB*B_2b)/kappa_E)));
else 
    A_2b = 0;
    E_2b = 0;
    B_2b = 0;
end 

% There are four possible solutions
% Check whether steady states satisfy these conditions
%% A* and E* > 0
if isreal(A_2a) && (E_2a < E_th && E_2a > 0 && A_2a >= A_th && A_2a <= A_max) 
    SteadyStates(1, 1) = A_2a; 
    SteadyStates(1, 2) = E_2a; 
    SteadyStates(1, 3) = B_2a; 
else 
    SteadyStates(1, 1) = 0; 
    SteadyStates(1, 2) = 0; 
    SteadyStates(1, 3) = 0;
end

%% A* > 0 and E* = 0
if isreal(A_2a) && (A_2a >= A_th && A_2a <= A_max) 
    SteadyStates(2, 1) = A_2a; 
    SteadyStates(2, 2) = 0;
    SteadyStates(2, 3) = B_2a; 
else 
    SteadyStates(2, 1) = 0; 
    SteadyStates(2, 2) = 0; 
    SteadyStates(2, 3) = 0;
end

%% A* and E* > 0
if isreal(A_2b) && (E_2b < E_th && E_2b > 0 && A_2b >= A_th && A_2b <= A_max) 
    SteadyStates(3, 1) = A_2b; 
    SteadyStates(3, 2) = E_2b; 
    SteadyStates(3, 3) = B_2b; 
else 
    SteadyStates(3, 1) = 0; 
    SteadyStates(3, 2) = 0; 
    SteadyStates(3, 3) = 0;
end

%% A* > 0 and E* = 0
if isreal(A_2b) && (A_2b >= A_th && A_2b <= A_max) 
    SteadyStates(4, 1) = A_2b; 
    SteadyStates(4, 2) = 0; 
    SteadyStates(4, 3) = B_2b; 
else 
    SteadyStates(4, 1) = 0; 
    SteadyStates(4, 2) = 0; 
    SteadyStates(4, 3) = 0;
end

%% ________________________________________________________________________
%% Check whether these steady states are really steady states

%% ________________________________________________________________________
%% Check whether these steady states are stable by computing the 
%% eigenvalues of their Jacobian matrix
for i = 1:size(SteadyStates, 1)
    J_h = [- delta_B - (kappa_A*(SteadyStates(i, 1)/A_max - 1))/(SteadyStates(i, 3)*gamma_AB + 1) - (SteadyStates(i, 1)*kappa_A)/(A_max*(SteadyStates(i, 3)*gamma_AB + 1)), 0, (SteadyStates(i, 1)*gamma_AB*kappa_A*(SteadyStates(i, 1)/A_max - 1))/(SteadyStates(i, 3)*gamma_AB + 1)^2;
         -SteadyStates(i, 2)*(delta_EA/(SteadyStates(i, 1) + A_pth) - (SteadyStates(i, 1)*delta_EA)/(SteadyStates(i, 1) + A_pth)^2), - delta_B - (kappa_E*(SteadyStates(i, 2)/E_max - 1))/(SteadyStates(i, 3)*gamma_EB + 1) - (SteadyStates(i, 1)*delta_EA)/(SteadyStates(i, 1) + A_pth) - (SteadyStates(i, 2)*kappa_E)/(E_max*(SteadyStates(i, 3)*gamma_EB + 1)), (SteadyStates(i, 2)*gamma_EB*kappa_E*(SteadyStates(i, 2)/E_max - 1))/(SteadyStates(i, 3)*gamma_EB + 1)^2;
         -SteadyStates(i, 3)*delta_BA, 0,  - kappa_B - SteadyStates(i, 1)*delta_BA];
    
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
Case2 = [SteadyStates, EigVal];