%clc 
%clear all
%% Script to plot patient types with two stable states
% Separate patients types depending on (1) number of stable states and (2)
% location of stable states
% _______________________________________________________________________

% identify patients with two stable states
%{
PatientsTwo = [];

parfor i = 1:length(AllVirtualPatientTypes)
    if AllVirtualPatientTypes(i, 2) == 2
        PatientsTwo = [PatientsTwo; AllVirtualPatientTypes(i, :)];
    end 
end

writematrix(PatientsTwo, 'Two_StableState.csv');
%}

%{
PatientsTwo = readmatrix('Two_StableState.csv'); 

% duplicate to plot
logPatientsTwo = PatientsTwo;
for i = 1:length(PatientsTwo)
    if PatientsTwo(i, 20) == 0 && PatientsTwo(i, 21) == 0
        logPatientsTwo(i, 20) = 1;
        logPatientsTwo(i, 21) = 1;  
    elseif PatientsTwo(i, 20) == 0 && PatientsTwo(i, 21) > 0
        logPatientsTwo(i, 20) = 1;
    elseif PatientsTwo(i, 21) == 0 && PatientsTwo(i, 20) > 0
        logPatientsTwo(i, 21) = 1;  
    end
    
    % we define a healthy state by B = 1 and a damaged state by B < 1
    if PatientsTwo(i, 22) < 1
        logPatientsTwo(i, 22) = 0.1; 
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

% consider all possible combinations (8 choose 2 = 28)
comb_1 = [];
comb_2 = [];
comb_3 = [];
comb_4 = [];
comb_5 = [];
comb_6 = [];
comb_7 = [];
comb_8 = [];
comb_9 = [];
comb_10 = [];
comb_11 = [];
comb_12 = [];
comb_13 = [];
comb_14 = [];
comb_15 = [];
comb_16 = [];
comb_17 = [];
comb_18 = [];
comb_19 = [];
comb_20 = [];
comb_21 = [];
comb_22 = [];
comb_23 = [];
comb_24 = [];
comb_25 = [];
comb_26 = [];
comb_27 = [];
comb_28 = [];
comb_29 = [];

parfor j = 1 : (length(logPatientsTwo) - 1)
    if logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            (logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2))

        combine_1 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_1 = [comb_1; combine_1];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            (logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3))
        
        combine_2 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_2 = [comb_2; combine_2];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            (logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4))
        
        combine_3 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_3 = [comb_3; combine_3];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            (logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5))
        
        combine_4 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_4 = [comb_4; combine_4];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            (logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6))
        
        combine_5 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_5 = [comb_5; combine_5];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            (logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7))

        combine_6 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_6 = [comb_6; combine_6];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 1 || logPatientsTwo(j + 1, 26) == 1) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))

        combine_7 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_7 = [comb_7; combine_7];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2) && ...
            (logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3))
        
        combine_8 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_8 = [comb_8; combine_8];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2) && ...
            (logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4))
        
        combine_9 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_9 = [comb_9; combine_9];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2) && ...
            (logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5))
        
        combine_10 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_10 = [comb_10; combine_10];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2) && ...
            (logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6))
        
        combine_11 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_11 = [comb_11; combine_11];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2) && ...
            (logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7))
        
        combine_12 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_12 = [comb_12; combine_12];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 2 || logPatientsTwo(j + 1, 26) == 2) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))
        
        combine_13 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_13 = [comb_13; combine_13];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3) && ...
            (logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4))
        
        combine_14 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_14 = [comb_14; combine_14];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3) && ...
            (logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5))
        
        combine_15 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_15 = [comb_15; combine_15];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3) && ...
            (logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6))
        
        combine_16 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_16 = [comb_16; combine_16];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3) && ...
            (logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7))
        
        combine_17 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_17 = [comb_17; combine_17];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 3 || logPatientsTwo(j + 1, 26) == 3) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))
        
        combine_18 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_18 = [comb_18; combine_18];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4) && ...
            (logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5))
        
        combine_19 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_19 = [comb_19; combine_19];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4) && ...
            (logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6))
        
        combine_20 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_20 = [comb_20; combine_20];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4) && ...
            (logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7))
        
        combine_21 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_21 = [comb_21; combine_21];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 4 || logPatientsTwo(j + 1, 26) == 4) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))
        
        combine_22 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_22 = [comb_22; combine_22];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5) && ...
            (logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6))

        combine_23 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_23 = [comb_23; combine_23];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5) && ...
            (logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7))

        combine_24 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_24 = [comb_24; combine_24];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 5 || logPatientsTwo(j + 1, 26) == 5) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))
        
        combine_25 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_25 = [comb_25; combine_25];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6) && ...
            (logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7))
        
        combine_26 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_26 = [comb_26; combine_26];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 6 || logPatientsTwo(j + 1, 26) == 6) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))
        
        combine_27 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_27 = [comb_27; combine_27];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 7 || logPatientsTwo(j + 1, 26) == 7) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j, 26) == 9) || ...
            (logPatientsTwo(j+1, 26) == 8 || logPatientsTwo(j+1, 26) == 9)))
        
        combine_28 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_28 = [comb_28; combine_28];

    elseif logPatientsTwo(j, 1) == logPatientsTwo(j + 1, 1) && ...
            ((logPatientsTwo(j, 26) == 8 || logPatientsTwo(j + 1, 26) == 8) && ...
            (logPatientsTwo(j, 26) == 9 || logPatientsTwo(j + 1, 26) == 9))
        combine_29 = [logPatientsTwo(j, :); logPatientsTwo(j + 1, :)];
        comb_29 = [comb_29; combine_29];
    end 
end
%}


limits = zeros(1, 26); 
limits(22) = 1.2;

comb_4  = [comb_4; limits];
comb_5  = [comb_5; limits];
comb_6  = [comb_6; limits];
comb_7  = [comb_7; limits];
comb_10 = [comb_10; limits];
comb_11 = [comb_11; limits];
comb_12 = [comb_12; limits];
comb_13 = [comb_13; limits];
comb_15 = [comb_15; limits];
comb_16 = [comb_16; limits];
comb_17 = [comb_17; limits];
comb_18 = [comb_18; limits];
comb_19 = [comb_19; limits];
comb_20 = [comb_20; limits];
comb_21 = [comb_21; limits];
comb_22 = [comb_22; limits];
comb_24 = [comb_24; limits];
comb_25 = [comb_25; limits];
comb_26 = [comb_26; limits];
comb_27 = [comb_27; limits];
comb_28 = [comb_28; limits];
%}

% _________________________________________________________________________
subplot(4,6,1)
scatter(log10(comb_4(:,20)), log10(comb_4(:,21)), ...
    300, comb_4(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,2)
scatter(log10(comb_5(:,20)), log10(comb_5(:,21)), ...
    300, comb_5(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,3)
scatter(log10(comb_6(:,20)), log10(comb_6(:,21)), ...
    300, comb_6(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,4)
scatter(log10(comb_7(:,20)), log10(comb_7(:,21)), ...
    300, comb_7(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,5)
scatter(log10(comb_10(:,20)), log10(comb_10(:,21)), ...
    300, comb_10(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
%}
colormap autumn

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

subplot(4,6,6)
scatter(log10(comb_11(:,20)), log10(comb_11(:,21)), ...
    300, comb_11(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,7)
scatter(log10(comb_12(:,20)), log10(comb_12(:,21)), ...
    300, comb_12(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,8)
scatter(log10(comb_13(:,20)), log10(comb_13(:,21)), ...
    300, comb_13(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,9)
scatter(log10(comb_15(:,20)), log10(comb_15(:,21)), ...
    300, comb_15(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn
%}

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

subplot(4,6,10)
scatter(log10(comb_17(:,20)), log10(comb_17(:,21)), ...
    300, comb_17(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,11)
scatter(log10(comb_18(:,20)), log10(comb_18(:,21)), ...
    300, comb_18(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6, 12)
scatter(log10(comb_19(:,20)), log10(comb_19(:,21)), ...
    300, comb_19(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,13)
scatter(log10(comb_20(:,20)), log10(comb_20(:,21)), ...
    300, comb_20(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,14)
scatter(log10(comb_21(:,20)), log10(comb_21(:,21)), ...
    300, comb_21(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,15)
scatter(log10(comb_22(:,20)), log10(comb_22(:,21)), ...
    300, comb_22(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,16)
scatter(log10(comb_24(:,20)), log10(comb_24(:,21)), ...
    300, 0.1*ones(length(comb_24), 1), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}

subplot(4,6,17)
scatter(log10(comb_25(:,20)), log10(comb_25(:,21)), ...
    300, 0.1*ones(length(comb_25), 1), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,18)
scatter(log10(comb_26(:,20)), log10(comb_26(:,21)), ...
    300, comb_26(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,19)
scatter(log10(comb_27(:,20)), log10(comb_27(:,21)), ...
    300, comb_27(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6,20)
scatter(log10(comb_28(:,20)), log10(comb_28(:,21)), ...
    300, comb_28(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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

subplot(4,6, 21)
scatter(log10(comb_16(:,20)), log10(comb_16(:,21)), ...
    300, comb_16(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

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
%}
