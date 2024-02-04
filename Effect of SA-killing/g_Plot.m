% This script reproduces the plots in Figure 3b - d and 3f - h
% Input relevant results matrix from g_TreatmentResponse e.g., 'irreversible_SAkilling.csv'
% The raw data files in Figure 3 can be found in Supplementary Data/Results/Figure3.xlsx

treat_plot = readmatrix('reversible_SAkilling_18May.csv');

% Plot heatmap of fraction of treatment success
x = [1 4];
y = [0 5];

M = [treat_plot(1:7, 4)'; treat_plot(8:14, 4)'; treat_plot(15:21, 4)'; ...
    treat_plot(22:28, 4)'; treat_plot(29:35, 4)'; treat_plot(36:42, 4)'];

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
