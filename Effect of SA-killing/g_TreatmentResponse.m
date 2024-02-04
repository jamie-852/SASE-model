clc 
clear all

options = odeset('NonNegative', 1, 'RelTol', 1e-4, 'AbsTol', 1e-4);

%% GENERATE TREATMENT COMBINATIONS
%delta_AS = therapy strength
delta_AS_start  = 0;
delta_AS_step   = 1;
delta_AS_end    = 5;

% t_end = treatment length
t_end_start  = 1;
t_end_step   = 0.5;
t_end_end    = 4;

treatment = zeros(1, 2);
c = 1;
for i = delta_AS_start:delta_AS_step:delta_AS_end
    for j = t_end_start:t_end_step:t_end_end
        treatment(c, 1) = i;
        treatment(c, 2) = j;
        c = c + 1;
    end 
end

% as a sanity check for whether the code is doing what we'd expect 
error = [];

% input example patients (irrev_SAkilling.csv or rev_SAkilling.csv)
% irrev_SAkilling.csv includes all irreversible infection sites in Figure S1
% rev_SAkilling.csv includes all reversible infection sites in Figure S1
sites = readmatrix('rev_SAkilling.csv');

frac_success = [];

% therapy is applied when S = 1;
S = 1;

for i = 1:length(treatment)
    % success
    h = 0;

    parfor ii = 1:length(sites)
        % input parameters
        kappa_A         = sites(ii, 3);
        A_max           = sites(ii, 4); 
        
        gamma_AB        = sites(ii, 5);
        delta_AE        = sites(ii, 6);
        A_th            = sites(ii, 7); 
        E_pth           = sites(ii, 8); 
        gamma_AE        = sites(ii, 9); 
        
        kappa_E         = sites(ii, 10);
        E_max           = sites(ii, 11); 
        gamma_EB        = sites(ii, 12);
        delta_EA        = sites(ii, 13);
        E_th            = sites(ii, 14); 
        A_pth           = sites(ii, 15); 
        
        kappa_B         = sites(ii, 16);
        delta_B         = sites(ii, 17); 
        delta_BA        = sites(ii, 18); 
        delta_BE        = sites(ii, 19);
        
        A_0             = sites(ii, 20);
        E_0             = sites(ii, 21);
        B_0             = sites(ii, 22);

        if A_0 <= 1 
            A_0 = 0;
        end 

        if E_0 <= 1 
            E_0 = 0; 
        end
        
        % parameter set defining one site 
        skinsite = [kappa_A, A_max, gamma_AB, delta_AE, A_th, E_pth, gamma_AE, ...
        kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, kappa_B, delta_B, ...
        delta_BA, delta_BE, A_0, E_0, B_0];
       
        % SA-killing application
        [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE, treatment(i, 1), S), [0, treatment(i, 2)], [A_0 E_0 B_0], options);

        % extract values for A, E, and B at the end of treatment period
        % add perturbation and simulate until healthy skin is reached (B = 1)
        if y1(end, 1) < 1
            y1(end, 1) = 1;
        else
            y1(end, 1) = y1(end, 1) - 1;
        end 

        if y1(end, 2) < 1
            y1(end, 2) = 1;
        else
            y1(end, 2) = y1(end, 2) - 1;
        end 
        
        init_nt = [(y1(end, 1)) (y1(end, 2)) y1(end, 3)];

        options2 = odeset('NonNegative', 1, 'Events', @(t, y)f_EventHealthy(t, y), 'RelTol', 1e-4, 'AbsTol', 1e-4);

        [t2, y2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), [t1(end), t1(end) + 1e6], init_nt, options2);
        
        % if no event has occured, a healthy skin state is not reached.
        % check to see whether code works as expected
        if y2(end, 3) == 1 && t2(end) == (t1(end) + 1e6)
                h = h + 1;
                % this should always be zero as a healthy skin state is not
                % reached. 
                skinsite = [skinsite, y1(end, :), y2(end, :)];
                error = [error; skinsite];
        end

        % if an event occurs, meaning that a healthy barrier integrity (B = 1) reached,
        % check whether it is stable or not by adding a perturbation
        if t2(end) < (t1(end) + 1e6)
            % add pertrubation
            if y2(end, 1) < 1
                y2(end, 1) = 1;
            else
                y2(end, 1) = y2(end, 1) - 1;
            end 

            if y2(end, 2) < 1
                y2(end, 2) = 1;
            else
                y2(end, 2) = y2(end, 2) - 1;
            end 
        
            init_nt_2 = [y2(end, 1) y2(end, 2) y2(end, 3)];
            
            [t3, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
            A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
            kappa_B, delta_B, delta_BA, delta_BE), [t2(end), t1(end) + 1e6], init_nt_2, options)

            if y3(end, 3) == 1
                h = h + 1;
            end
        end
    end

    percent = h/(length(sites));
    frac_success = [frac_success; percent];
end

treat_plot = [treatment, frac_success];

writematrix(treat_plot, 'reversible_SAkilling_18May.csv');
writematrix(error, 'error.csv');

% Plot heatmap of fraction of treatment success
x = [1 4];
y = [0 5];

M = [treat_plot(1:7, 3)'; treat_plot(8:14, 3)'; treat_plot(15:21, 3)'; ...
    treat_plot(22:28, 3)'; treat_plot(29:35, 3)'; treat_plot(36:42, 3)'];

M_round = round(M*100, -1); 

clims = [0 0.95];
colormap('gray');
imagesc(x, y, M, clims)
colorbar;

hold on
[C, h] = contour(M_round, 'w-', 'ShowText', 'on');
hold off
clabel(C, h, 'FontSize', 15, 'color', 'w');
h.LineWidth = 1;

xlabel('\fontsize{16}Duration [day]')
ylabel('\fontsize{16}Strength [day^{-1}]')

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

set(gca, 'FontSize', 16)
set(gca,'YDir','normal')