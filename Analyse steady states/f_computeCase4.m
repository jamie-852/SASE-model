%% Compute steady states for when both SA and SE are active (sw_A and sw_E = 1)
%% as described in Supplementary Note S3.5.
% _______________________________________________________________________
function [Case4] = f_computeCase4(kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, gamma_AE, ...
    kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE)

% pre-define vector to store steady states
SteadyStates = zeros(1, 3);

% pre-define vector to store eigenvalues
EigVal = zeros(1, 3);

% initial conditions when treatment is applied
% set both A* and E* set at their maximums with a low barrier integrity

init_t = [A_max, E_max, 0.01]; 

% simulate for 10 days 
tspan_init = [0 10];

[~, y_1] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, ...
    delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
    E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE), tspan_init, init_t);
 
% check whether A(t), E(t) and B(t) are at steady state:
A_5a = y_1(end, 1);
E_5a = y_1(end, 2);
B_5a = y_1(end, 3);

% Define switches: 
if E_5a >= E_th
    sw_E = 1;
else
    sw_E = 0;
end 

if A_5a >= A_th*(1+gamma_AE*sw_E*E_5a)
    sw_A = 1;
else
    sw_A = 0;
end    

% dAdt, dEdt, dBdt initially
dAdt = ((kappa_A/(1 + gamma_AB*B_5a))*(1 - ((A_5a/A_max))) - ...
        (delta_B + delta_AE*(sw_E*E_5a/(sw_E*E_5a + E_pth))))*A_5a;

dEdt = ((kappa_E/(1 + gamma_EB*B_5a))*(1 - (E_5a/E_max)) - (delta_B + ...
    delta_EA*(sw_A*A_5a/(sw_A*A_5a + A_pth))))*E_5a; 

dBdt = kappa_B*(1 - B_5a)-(delta_BA*sw_A*A_5a + delta_BE*sw_E*E_5a)*B_5a;

if dAdt <= 1e-6 && dAdt > -1e-6 && dEdt <= 1e-6 && dEdt > -1e-6 && ...
    dBdt <= 1e-6 && dBdt > -1e-6 && E_5a > E_th && E_5a <= E_max ...
    && A_5a > A_th && A_5a <= A_max

    SteadyStates(1) = A_5a; 
    SteadyStates(2) = E_5a;
    SteadyStates(3) = B_5a;

% also stop simulation if a steady state is reached where there is no
% coexistence
elseif A_5a <= 1e-6 || E_5a <= 1e-6
    SteadyStates(1) = 0; 
    SteadyStates(2) = 0;
    SteadyStates(3) = 0;
else 

    % if steady state has not been reached, continue simulation
    tspan_init = [10 1e5]; 
    [~, y_2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, ...
    delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
    E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE), tspan_init, [A_5a, E_5a, B_5a]);
    
    % check whether A(t), E(t) and B(t) are now at steady state
    A_5b = y_2(end, 1);
    E_5b = y_2(end, 2);
    B_5b = y_2(end, 3);

    % define switches
    if E_5b >= E_th
        sw_E = 1;
    else
        sw_E = 0;
    end 
    
    if A_5b >= A_th*(1+gamma_AE*sw_E*E_5b)
        sw_A = 1;
    else
        sw_A = 0;
    end 
           
    % dAdt, dEdt, dBdt 
    dAdt = ((kappa_A/(1 + gamma_AB*B_5b))*(1 - ((A_5b/A_max))) - ...
            (delta_B + delta_AE*(sw_E*E_5b/(sw_E*E_5b + E_pth))))*A_5b;
    
    dEdt = ((kappa_E/(1 + gamma_EB*B_5b))*(1 - (E_5b/E_max)) - (delta_B + ...
        delta_EA*(sw_A*A_5b/(sw_A*A_5b + A_pth))))*E_5b; 
    
    dBdt = kappa_B*(1 - B_5b)-(delta_BA*sw_A*A_5b + delta_BE*sw_E*E_5b)*B_5b;
    
    if dAdt <= 1e-6 && dAdt > -1e-6 && dEdt <= 1e-6 && dEdt > -1e-6 && ...
    dBdt <= 1e-6 && dBdt > -1e-6 && E_5b > E_th && E_5b <= E_max && ...
        A_5b > A_th && A_5b <= A_max

        SteadyStates(1) = A_5b; 
        SteadyStates(2) = E_5b;
        SteadyStates(3) = B_5b;
    end 
end 

% ________________________________________________________________________
% Check whether these steady states are stable by computing the 
% eigenvalues of their Jacobian matrix 
J_h = [- delta_B - (kappa_A*(SteadyStates(1)/A_max - 1))/(SteadyStates(3)*gamma_AB + 1) - ...
    (SteadyStates(2)*delta_AE)/(SteadyStates(2) + E_pth) - ...
    (SteadyStates(1)*kappa_A)/(A_max*(SteadyStates(3)*gamma_AB + 1)), ...
    -SteadyStates(1)*(delta_AE/(SteadyStates(2) + E_pth) - ...
    (SteadyStates(2)*delta_AE)/(SteadyStates(2) + E_pth)^2), ...
    (SteadyStates(1)*gamma_AB*kappa_A*(SteadyStates(1)/A_max - 1))/(SteadyStates(3)*gamma_AB + 1)^2;
     -SteadyStates(2)*(delta_EA/(SteadyStates(1) + A_pth) - ...
     (SteadyStates(1)*delta_EA)/(SteadyStates(1) + A_pth)^2), ...
     - delta_B - (kappa_E*(SteadyStates(2)/E_max - 1))/(SteadyStates(3)*gamma_EB + 1) - ...
     (SteadyStates(1)*delta_EA)/(SteadyStates(1) + A_pth) - ...
     (SteadyStates(2)*kappa_E)/(E_max*(SteadyStates(3)*gamma_EB + 1)), ...
     (SteadyStates(2)*gamma_EB*kappa_E*(SteadyStates(2)/E_max - 1))/(SteadyStates(3)*gamma_EB + 1)^2;
     -SteadyStates(3)*delta_BA, -SteadyStates(3)*delta_BE,  - kappa_B - ...
     SteadyStates(1)*delta_BA - SteadyStates(2)*delta_BE];

% compute eigenvalues
stab = eig(J_h);

if SteadyStates(:) == 0
    EigVal(1:3) = 0;
else
    EigVal(1) = stab(1);
    EigVal(2) = stab(2);
    EigVal(3) = stab(3);
end 

%% Combine steady states and corresponding eigenvalues
Case4 = [SteadyStates, EigVal];