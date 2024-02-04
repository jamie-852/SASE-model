function dydt = f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, delta_AE, ...
    A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
    kappa_B, delta_B, delta_BA, delta_BE, delta_AS, S)

A = y(1);
E = y(2);
B = y(3);

if E >= E_th
    sw_E = 1;
else
    sw_E = 0;
end 
    
if A >= A_th*(1+gamma_AE*sw_E*E)
    sw_A = 1;
else
    sw_A = 0;
end

dydt = [((kappa_A/(1 + gamma_AB*B))*(1 - ((A/A_max))) - ...
        (delta_B + delta_AE*(sw_E*E/(sw_E*E + E_pth)) + delta_AS*S))*A; 
    ((kappa_E/(1 + gamma_EB*B))*(1 - (E/E_max)) - (delta_B + ...
    delta_EA*(sw_A*A/(sw_A*A + A_pth))))*E; 
    kappa_B*(1 - B)-(delta_BA*sw_A*A + delta_BE*sw_E*E)*B];