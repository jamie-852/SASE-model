%% Compute steady states for when SE is active and
%% SA agr is inactive (sw_A = 0 and sw_E = 1)
%% as described in Supplementary Note S3.3. and S3.4.
% _______________________________________________________________________
function [Case3] = f_computeCase3(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, ...
    kappa_E, E_max, gamma_EB, E_th, kappa_B, delta_B, delta_BE)

% pre-define vector to store steady states
SteadyStates = zeros(1, 3);

% pre-define vector to store eigenvalues
EigVal = zeros(1, 3);

% There are two scenarios depending on whether SE is non-skin-damaging or 
% skin-damaging
% _________________________________________________________________________
% Consider the scenario where SE is non-skin-damaging and delta_BE = 0
if delta_BE == 0
    E_3 = (1 - ((delta_B*(1+gamma_EB))/kappa_E))*E_max;
    if E_3 >= E_th && E_3 <= E_max
        B_3 = 1;
        A_3 = A_max*(1 - ((delta_AE*(E_3/(E_3+E_pth))+delta_B)*((1 + ...
    gamma_AB*B_3)/kappa_A)));
        
    else 
        E_3 = 0;
        B_3 = 0;
        A_3 = 0;
    end 

    if A_3 < A_th && A_3 > 0 && E_3 >= E_th && E_3 <= E_max 
        SteadyStates(1, 1) = A_3; 
        SteadyStates(1, 2) = E_3; 
        SteadyStates(1, 3) = B_3; 
    else 
        SteadyStates(1, 1) = 0; 
        SteadyStates(1, 2) = 0; 
        SteadyStates(1, 3) = 0;
    end
    
    if E_3 >= E_th && E_3 <= E_max
        SteadyStates(2, 1) = 0; 
        SteadyStates(2, 2) = E_3;
        SteadyStates(2, 3) = B_3; 
    else 
        SteadyStates(2, 1) = 0; 
        SteadyStates(2, 2) = 0; 
        SteadyStates(2, 3) = 0;
    end
end

% _________________________________________________________________________
% Consider the scenario where SE is skin-damaging and delta_BE > 0
if delta_BE > 0
    % There are two solutions for E* (E_4a and E_4b)
    E_4a = -(kappa_B*kappa_E - (kappa_B^2*kappa_E^2 + ...
    E_max^2*delta_B^2*delta_BE^2 + E_max^2*delta_BE^2*kappa_E^2 + ...
    2*E_max*delta_BE*kappa_B*kappa_E^2 - ...
    2*E_max^2*delta_B*delta_BE^2*kappa_E - ...
    2*E_max*delta_B*delta_BE*kappa_B*kappa_E - ...
    4*E_max*delta_B*delta_BE*gamma_EB*kappa_B*kappa_E)^(1/2) + ...
    E_max*delta_B*delta_BE - E_max*delta_BE*kappa_E)/(2*delta_BE*kappa_E);

    E_4b = -(kappa_B*kappa_E + (kappa_B^2*kappa_E^2 + ...
        E_max^2*delta_B^2*delta_BE^2 + E_max^2*delta_BE^2*kappa_E^2 + ...
        2*E_max*delta_BE*kappa_B*kappa_E^2 - ...
        2*E_max^2*delta_B*delta_BE^2*kappa_E - ...
        2*E_max*delta_B*delta_BE*kappa_B*kappa_E - ...
        4*E_max*delta_B*delta_BE*gamma_EB*kappa_B*kappa_E)^(1/2) + ...
        E_max*delta_B*delta_BE - E_max*delta_BE*kappa_E)/(2*delta_BE*kappa_E);

    % if E_4a and E_4b are within population sizes for agr to be switched
    % on, compute the corresponding values for A* and B*
    if isreal(E_4a) && (E_4a >= E_th && E_4a <= E_max)
        B_4a = kappa_B/(kappa_B + delta_BE*E_4a); 
        A_4a = A_max*(1 - ((delta_AE*(E_4a/(E_4a+E_pth))+delta_B)*((1 + ...
        gamma_AB*B_4a)/kappa_A)));
    else 
        E_4a = 0;
        B_4a = 0;
        A_4a = 0;
    end 
    
    if isreal(E_4b) && (E_4b >= E_th && E_4b <= E_max)
        B_4b = kappa_B/(kappa_B + delta_BE*E_4b);
        A_4b = A_max*(1 - ((delta_AE*(E_4b/(E_4b+E_pth))+delta_B)*((1 + ...
        gamma_AB*B_4b)/kappa_A)));
    else 
        E_4b = 0;
        B_4b = 0;
        A_4b = 0;
    end 

    if isreal(E_4a) && (A_4a < A_th && A_4a > 0 && E_4a >= E_th && E_4a <= E_max) 
        SteadyStates(1, 1) = A_4a; 
        SteadyStates(1, 2) = E_4a; 
        SteadyStates(1, 3) = B_4a; 
    else 
        SteadyStates(1, 1) = 0; 
        SteadyStates(1, 2) = 0; 
        SteadyStates(1, 3) = 0;
    end
    
    if isreal(E_4a) && (E_4a >= E_th && E_4a <= E_max)
        SteadyStates(2, 1) = 0; 
        SteadyStates(2, 2) = E_4a;
        SteadyStates(2, 3) = B_4a; 
    else 
        SteadyStates(2, 1) = 0; 
        SteadyStates(2, 2) = 0; 
        SteadyStates(2, 3) = 0;
    end
    
    if isreal(E_4b) && (A_4b < A_th && A_4b > 0 && E_4b >= E_th && E_4b <= E_max) 
        SteadyStates(3, 1) = A_4b; 
        SteadyStates(3, 2) = E_4b; 
        SteadyStates(3, 3) = B_4b; 
    else 
        SteadyStates(3, 1) = 0; 
        SteadyStates(3, 2) = 0; 
        SteadyStates(3, 3) = 0;
    end
    
    if isreal(E_4b) && (E_4b >= E_th && E_4b <= E_max) 
        SteadyStates(4, 1) = 0; 
        SteadyStates(4, 2) = E_4b; 
        SteadyStates(4, 3) = B_4b; 
    else 
        SteadyStates(4, 1) = 0; 
        SteadyStates(4, 2) = 0; 
        SteadyStates(4, 3) = 0;
    end
end

% ________________________________________________________________________
% Check whether these steady states are stable by computing the 
% eigenvalues of their Jacobian matrix

for i = 1:size(SteadyStates, 1)
    J_h = [- delta_B - (kappa_A*(SteadyStates(i, 1)/A_max - 1))/(SteadyStates(i, 3)*gamma_AB + 1) - ...
        (SteadyStates(i, 2)*delta_AE)/(SteadyStates(i, 2) + E_pth) - ...
        (SteadyStates(i, 1)*kappa_A)/(A_max*(SteadyStates(i, 3)*gamma_AB + 1)), ...
        -SteadyStates(i, 1)*(delta_AE/(SteadyStates(i, 2) + E_pth) - ...
        (SteadyStates(i, 2)*delta_AE)/(SteadyStates(i, 2) + E_pth)^2), ...
        (SteadyStates(i, 1)*gamma_AB*kappa_A*(SteadyStates(i, 1)/A_max - ...
        1))/(SteadyStates(i, 3)*gamma_AB + 1)^2;
        0, - delta_B - (kappa_E*(SteadyStates(i, 2)/E_max - ...
        1))/(SteadyStates(i, 3)*gamma_EB + 1) - ...
        (SteadyStates(i, 2)*kappa_E)/(E_max*(SteadyStates(i, 3)*gamma_EB + 1)), ...
        (SteadyStates(i, 2)*gamma_EB*kappa_E*(SteadyStates(i, 2)/E_max - 1))/(SteadyStates(i, 3)*gamma_EB + 1)^2;
        0, -SteadyStates(i, 3)*delta_BE,  - kappa_B - SteadyStates(i, 2)*delta_BE];

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
Case3 = [SteadyStates, EigVal];
