% load AllVirtualPatients.csv file 
ds = tabularTextDatastore('AllVirtualPatients.csv');

n_ss = []; 

while hasdata(ds)
    T = read(ds);
    ParamSet = table2array(T); 

    parfor i = 1:size(ParamSet, 1)
        kappa_A         = ParamSet(i, 3);
        A_max           = ParamSet(i, 4);
        gamma_AB        = ParamSet(i, 5);
        delta_AE        = ParamSet(i, 6);
        A_th            = ParamSet(i, 7);
        E_pth           = ParamSet(i, 8);
        gamma_AE        = ParamSet(i, 9); 
    
        kappa_E         = ParamSet(i, 10);
        E_max           = ParamSet(i, 11); 
        gamma_EB        = ParamSet(i, 12);
        delta_EA        = ParamSet(i, 13);
        E_th            = ParamSet(i, 14); 
        A_pth           = ParamSet(i, 15); 
   
        kappa_B         = ParamSet(i, 16);
        delta_B         = ParamSet(i, 17); 
        delta_BA        = ParamSet(i, 18);
        delta_BE        = ParamSet(i, 19);

        A_ss            = ParamSet(i, 20);
        E_ss            = ParamSet(i, 21);
        B_ss            = ParamSet(i, 22);

        [output] = f_SteadyStateCheck(A_ss, E_ss, B_ss, kappa_A, A_max, gamma_AB, ...
    delta_AE, A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, ...
    E_th, A_pth, kappa_B, delta_B, delta_BA, delta_BE);

        n_ss = [n_ss; output]; 
    end 
end 