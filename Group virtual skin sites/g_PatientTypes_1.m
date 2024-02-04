clc
clear all
%% Script to plot patient types with one stable state
% Separate patients types depending on (1) number of stable states and (2)
% location of stable states
% _______________________________________________________________________
% identify patients with one stable state
%{
PatientsOne = [];

parfor i = 1:length(AllVirtualPatientTypes)
    if AllVirtualPatientTypes(i, 2) == 1
        PatientsOne = [PatientsOne; AllVirtualPatientTypes(i, :)];
    end 
end

writematrix(PatientsOne, 'One_StableState.csv');
%}

PatientsOne = readmatrix('One_StableState.csv');

% duplicate to plot
logPatientsOne = PatientsOne;
for i = 1:length(PatientsOne)
    if PatientsOne(i, 20) == 0 && PatientsOne(i, 21) == 0
        logPatientsOne(i, 20) = 1;
        logPatientsOne(i, 21) = 1;  
    elseif PatientsOne(i, 20) == 0 && PatientsOne(i, 21) > 0
        logPatientsOne(i, 20) = 1;
    elseif PatientsOne(i, 21) == 0 && PatientsOne(i, 20) > 0
        logPatientsOne(i, 21) = 1;  
    end
end
%}
%% create a scatter plot for each case
% ________________________________________________________________________
% combine 8. and 9. based on Supplementary Note 3

% 1. A* = 0, E* = 0 and B* = 1                (sw_A = sw_E = 0)
% 2. 0 < A* < A_th, E* = 0 and B* = 1         (sw_A = sw_E = 0)
% 3. A* = 0, 0 < E* < E_th and B* = 1         (sw_A = sw_E = 0)
% 4. 0 < A* < A_th, 0 < E* < E_th and B* = 1  (sw_A = sw_E = 0)
% 5. A* = 0, E_th <= E* <= E_max and B* = 1   (sw_A = 0 and sw_E = 1)
% 6. 0 < A* < A_th, E_th <= E* <= E_max and B* = 1   (sw_A = 0 and sw_E = 1)
% 7. A_th <= A* <= A_max, E* = 0              (sw_A = 1 and sw_E = 0)
% 8. A_th <= A* <= A_max, 0 < E* <= E_th      (sw_A = 1 and sw_E = 0)
% 9. A_th <= A* <= A_max, A_th <= E* <= E_max (sw_A = 1 and sw_E = 1)

case_1 = [];
case_2 = [];
case_3 = [];
case_4 = [];
case_5 = [];
case_6 = [];
case_7 = [];
case_9 = [];

parfor j = 1:length(logPatientsOne)
    if logPatientsOne(j, 26) == 1
        case_1 = [case_1; logPatientsOne(j, :)];

    elseif logPatientsOne(j, 26) == 2
        case_2 = [case_2; logPatientsOne(j, :)]; 
    
    % combine ones where SE agr switch is on but not damaging
    elseif logPatientsOne(j, 26) == 3 || (logPatientsOne(j, 26) == 5 && logPatientsOne(j, 22) == 1)
        case_3 = [case_3; logPatientsOne(j, :)]; 
    
    elseif logPatientsOne(j, 26) == 4 
        case_4 = [case_4; logPatientsOne(j, :)]; 
    
    % keep only ones where SE agr switch is on and damaging
    elseif (logPatientsOne(j, 26) == 5 && logPatientsOne(j, 22) < 1)
        case_5 = [case_5; logPatientsOne(j, :)]; 
    
    elseif logPatientsOne(j, 26) == 6 
        case_6 = [case_6; logPatientsOne(j, :)]; 
    
    elseif logPatientsOne(j, 26) == 7
        case_7 = [case_7; logPatientsOne(j, :)]; 
    
    elseif logPatientsOne(j, 26) == 8 || logPatientsOne(j, 26) == 9
        case_9 = [case_9; logPatientsOne(j, :)]; 
    end 
end 
%}

limits = zeros(1, 26); 
limits(22) = 1.2;
case_1 = [case_1; limits];
case_2 = [case_2; limits];
case_3 = [case_3; limits];
case_4 = [case_4; limits];
case_5 = [case_5; limits];
case_6 = [case_6; limits];
case_7 = [case_7; limits];
case_9 = [case_9; limits];

subplot(2,4,1)
scatter(log10(case_1(:,20)), log10(case_1(:,21)), ...
    300, case_1(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1092e+09), '--', 'LineWidth', 1); 
%xline(log10(1.1092e+09), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,2)
scatter(log10(case_2(:,20)), log10(case_2(:,21)), ...
    300, case_2(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1040e+09), '--', 'LineWidth', 1); 
%xline(log10(1.1091e+09), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,3)
scatter(log10(case_3(:,20)), log10(case_3(:,21)), ...
    300, case_3(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1091e+09), '--', 'LineWidth', 1); 
%xline(log10(1.1074e+09), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,4)
scatter(log10(case_4(:,20)), log10(case_4(:,21)), ...
    300, case_4(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1090e+09), '--', 'LineWidth', 1); 
%xline(log10(1.1076e+09), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,5)
scatter(log10(case_5(:,20)), log10(case_5(:,21)), ...
    300, 0.1*ones(length(case_5), 1), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1298e+07), '--', 'LineWidth', 1); 
%xline(log10(1.1299e+07), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,6)
scatter(log10(case_6(:,20)), log10(case_6(:,21)), ...
    300, case_6(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1624e+07), '--', 'LineWidth', 1); 
%xline(log10(1.1088e+09), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,7)
scatter(log10(case_7(:,20)), log10(case_7(:,21)), ...
    300, 0.1*ones(length(case_7), 1), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1299e+07), '--', 'LineWidth', 1); 
%xline(log10(1.1298e+07), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)

subplot(2,4,8)
scatter(log10(case_9(:,20)), log10(case_9(:,21)), ...
    300, case_9(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
hold on
%yline(log10(1.1833e+07), '--', 'LineWidth', 1); 
%xline(log10(1.1540e+07), '--', 'LineWidth', 1); 

xticks([0 5 10])
xticklabels({0, '10^5', '10^{10}'})
yticks([0 5 10])
yticklabels({0, '10^5', '10^{10}'})

ax = gca;
ax.TickLength = [0.05, 0.05];
ax.LineWidth = 0.75;

axis([0 11 0 11])
xlabel('\fontsize{14}SA')
ylabel('\fontsize{14}SE')
set(gca, 'FontSize', 14)
