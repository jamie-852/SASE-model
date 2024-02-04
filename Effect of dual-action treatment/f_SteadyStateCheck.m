%% Check that all computed steady states are really at steady state
%% ________________________________________________________________________
function [deriv_ss] = f_SteadyStateCheck(A_ss, E_ss, B_ss, kappa_A, A_max, gamma_AB, ...
    delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
    E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE)

% check whether agr switches are on or off
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

% compute derivative
dAdt = ((kappa_A/(1 + gamma_AB*B_ss))*(1 - ((A_ss/A_max))) - ...
        (delta_B + delta_AE*(sw_E*E_ss/(sw_E*E_ss + E_pth))))*A_ss;

dEdt = ((kappa_E/(1 + gamma_EB*B_ss))*(1 - (E_ss/E_max)) - (delta_B + ...
    delta_EA*(sw_A*A_ss/(sw_A*A_ss + A_pth))))*E_ss; 

dBdt = kappa_B*(1 - B_ss)-(delta_BA*sw_A*A_ss + delta_BE*sw_E*E_ss)*B_ss;

deriv = [dAdt dEdt dBdt];

% are the derivative values v. small?
if abs(deriv) <= 10e-5
    ss = 1; 
else 
    ss = 0; 
end

deriv_ss = [deriv, ss]; 