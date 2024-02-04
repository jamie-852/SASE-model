% This script plots the characteristic SA and SE population sizes for the
% example virtual skin site in Figure S5
site = readmatrix('Example_SAkilling.xlsx');

scatter(log10(site(:,20)), log10(site(:,21)), ...
    300, site(:, 22), 'filled', 'o', 'MarkerFaceAlpha', '0.8');
caxis([0 1.5]);
colormap autumn

hold on
yline(log10(site(1,7)));
xline(log10(site(1,14)));

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