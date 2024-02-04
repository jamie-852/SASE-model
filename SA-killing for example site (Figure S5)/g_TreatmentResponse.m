% This script generates the heatmap in Figure S5 for one example reversible infection
% site demonstrating that SA-killing is successful only for a very narrow range
% of treatment regimes. 

clc 
clear all

options = odeset('NonNegative', 1, 'RelTol', 1e-3, 'AbsTol', 1e-3);

%delta_AS = therapy strength
delta_AS_start  = 0;
delta_AS_step   = 0.05;
delta_AS_end    = 5; 

% t_end = treatment length
t_end_start  = 1;
t_end_step   = 0.1;
t_end_end    = 10;

treatment = zeros(1, 2);
c = 1;
for i = delta_AS_start:delta_AS_step:delta_AS_end
    for j = t_end_start:t_end_step:t_end_end
        treatment(c, 1) = i;
        treatment(c, 2) = j;
        c = c + 1;
    end 
end

ExamplePatients = readmatrix('Example_SAkilling.xlsx');

treatment_output = [];

ii = 2; 

S = 1;

for jj = 1:length(treatment)
    % input parameters
    % input parameters
    kappa_A         = ExamplePatients(ii, 3);
    A_max           = ExamplePatients(ii, 4); 
    
    gamma_AB        = ExamplePatients(ii, 5);
    delta_AE        = ExamplePatients(ii, 6);
    A_th            = ExamplePatients(ii, 7); 
    E_pth           = ExamplePatients(ii, 8); 
    gamma_AE        = ExamplePatients(ii, 9); 
    
    kappa_E         = ExamplePatients(ii, 10);
    E_max           = ExamplePatients(ii, 11); 
    gamma_EB        = ExamplePatients(ii, 12);
    delta_EA        = ExamplePatients(ii, 13);
    E_th            = ExamplePatients(ii, 14); 
    A_pth           = ExamplePatients(ii, 15); 
    
    kappa_B         = ExamplePatients(ii, 16);
    delta_B         = ExamplePatients(ii, 17); 
    delta_BA        = ExamplePatients(ii, 18); 
    delta_BE        = ExamplePatients(ii, 19);
    
    A_0             = ExamplePatients(ii, 20);
    E_0             = ExamplePatients(ii, 21);
    B_0             = ExamplePatients(ii, 22);

    if A_0 <= 1 
        A_0 = 0; 
    end 

    if E_0 <= 1 
        E_0 = 0; 
    end
    
    % SA-killing application
    [t1, y1] = ode15s(@(t, y) f_defineODEs_SAkilling(y, kappa_A, A_max, gamma_AB, delta_AE, ...
    A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
    kappa_B, delta_B, delta_BA, delta_BE, treatment(jj, 1), S), [0, treatment(jj, 2)], [A_0 E_0 B_0], options);

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

    tplot = t1;
    yplot = y1;

    init_nt = [(y1(end, 1)) (y1(end, 2)) y1(end, 3)];

    options2 = odeset('NonNegative', 1, 'Events', @(t, y)f_EventHealthy(t, y), 'RelTol', 1e-3, 'AbsTol', 1e-3);

    [t2, y2] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
    A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
    kappa_B, delta_B, delta_BA, delta_BE), [t1(end), t1(end) + 1e6], init_nt, options2);
   
    if t2(end) < (t1(end) + 1e6)
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

        tplot = [tplot; t2];
        yplot = [yplot; y2];
    
        init_nt_2 = [y2(end, 1) y2(end, 2) y2(end, 3)];
        
        [t3, y3] = ode15s(@(t, y) f_defineODEs(y, kappa_A, A_max, gamma_AB, delta_AE, ...
        A_th, E_pth, gamma_AE, kappa_E, E_max, gamma_EB, delta_EA, E_th, A_pth, ...
        kappa_B, delta_B, delta_BA, delta_BE), [t2(end), t1(end) + 1e6], init_nt_2, options);
        
        tplot = [tplot; t3];
        yplot = [yplot; y3];
    
    else
        tplot = [tplot; t2];
        yplot = [yplot; y2];
    end

    output_temp = [treatment(jj, 1), treatment(jj, 2), yplot(end, 1), ...
        yplot(end, 2), yplot(end, 3)];

    treatment_output      = [treatment_output; output_temp];
end 
%}

% Plot heatmaps of treatment duration against strength
X_1 = treatment_output(length(treatment)*0+1:length(treatment)*1,2);
Y_1 = treatment_output(length(treatment)*0+1:length(treatment)*1,1);
Z_1 = treatment_output(length(treatment)*0+1:length(treatment)*1,5);

N = 95;
x_1 = linspace(min(X_1),max(X_1), N);
y_1 = linspace(min(Y_1),max(Y_1), N);

[Xi_1,Yi_1] = meshgrid(x_1,y_1) ;
Zi_1 = griddata(X_1,Y_1,Z_1,Xi_1,Yi_1) ;
surf(Xi_1,Yi_1,Zi_1, 'edgecolor', 'none')

colormap("autumn");
caxis([0 1.5]);

alpha(1)
colorbar;

view(2);
grid off

hold on
plot3(4, 4.1, 10, 'x', 'MarkerSize', 15,'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', [1 1 1], 'LineWidth', 1)
plot3(4, 5, 10, 'x', 'MarkerSize', 15,'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 1)

xlabel('\fontsize{16}Duration [day]')
ylabel('\fontsize{16}Strength [day^{-1}]')
set(gca, 'FontSize', 16)
axis([1 10 0 5])
