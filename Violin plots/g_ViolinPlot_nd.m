% ------------------------------------------------------------------------
% Example code for making Violin plots from matrices
% ------------------------------------------------------------------------
% Asymptomatic
asymp    = readmatrix('asymp.csv');
asymp    = asymp(:, 1:19);
% keep samples with damage
asymptomatic = asymp(asymp(:, 19) == 0,:);

% Reversible
rev     = readmatrix('rev_SAkilling.csv');
rev     = rev(:, 1:19);
% keep samples with damage
reversible = rev(rev(:, 19) == 0,:);

% Irreversible
irrev     = readmatrix('irrev_SAkilling.csv');
irrev     = irrev(:, 1:19);
% keep samples with damage
irreversible = irrev(irrev(:, 19) == 0,:);

% data matrix - columns = parameters, rows = patients:
input_kappa_A   = NaN(2*10^6, 3);
input_gamma_AB  = NaN(2*10^6, 3);
input_delta_AE  = NaN(2*10^6, 3);
input_A_th      = NaN(2*10^6, 3);
input_E_pth     = NaN(2*10^6, 3);
input_gamma_AE  = NaN(2*10^6, 3);

input_kappa_E   = NaN(2*10^6, 3);
input_gamma_EB  = NaN(2*10^6, 3);
input_delta_EA  = NaN(2*10^6, 3);
input_E_th      = NaN(2*10^6, 3);
input_A_pth     = NaN(2*10^6, 3);

input_kappa_B   = NaN(2*10^6, 3);
input_delta_B   = NaN(2*10^6, 3);
input_delta_BA  = NaN(2*10^6, 3);
input_delta_BE  = NaN(2*10^6, 3);

% kappa_A
nc_kappa_A = reversible(:, 3);
c_kappa_A   = irreversible(:, 3);
a_kappa_A   = asymp(:, 3);

nc_kappa_A  = log10(nc_kappa_A);
c_kappa_A   = log10(c_kappa_A);
a_kappa_A   = log10(a_kappa_A);

input_kappa_A(1:(length(nc_kappa_A)), 2)   = nc_kappa_A;
input_kappa_A(1:(length(c_kappa_A)), 3)    = c_kappa_A;
input_kappa_A(1:(length(a_kappa_A)), 1)    = a_kappa_A;

% gamma_AB 
nc_gamma_AB = reversible(:, 5);
c_gamma_AB   = irreversible(:, 5);
a_gamma_AB   = asymp(:, 5);

nc_gamma_AB = log10(nc_gamma_AB);
c_gamma_AB = log10(c_gamma_AB);
a_gamma_AB = log10(a_gamma_AB);

input_gamma_AB(1:(length(nc_gamma_AB)), 2)   = nc_gamma_AB;
input_gamma_AB(1:(length(c_gamma_AB)), 3)  = c_gamma_AB;
input_gamma_AB(1:(length(a_gamma_AB)), 1)  = a_gamma_AB;

% delta_AE
nc_delta_AE = reversible(:, 6);
c_delta_AE   = irreversible(:, 6);
a_delta_AE   = asymp(:, 6);

nc_delta_AE = log10(nc_delta_AE);
c_delta_AE = log10(c_delta_AE);
a_delta_AE = log10(a_delta_AE);

input_delta_AE(1:(length(nc_delta_AE)), 2)   = nc_delta_AE;
input_delta_AE(1:(length(c_delta_AE)), 3)  = c_delta_AE;
input_delta_AE(1:(length(a_delta_AE)), 1)  = a_delta_AE;


% A_th
nc_A_th = reversible(:, 7);
c_A_th   = irreversible(:, 7);
a_A_th   = asymp(:, 7);

nc_A_th = log10(nc_A_th);
c_A_th = log10(c_A_th);
a_A_th = log10(a_A_th);

input_A_th(1:(length(nc_A_th)), 2)   = nc_A_th;
input_A_th(1:(length(c_A_th)), 3)  = c_A_th;
input_A_th(1:(length(a_A_th)), 1)  = a_A_th;

% E_pth
nc_E_pth = reversible(:, 8);
c_E_pth   = irreversible(:, 8);
a_E_pth   = asymp(:, 8);

nc_E_pth = log10(nc_E_pth);
c_E_pth = log10(c_E_pth);
a_E_pth = log10(a_E_pth);

input_E_pth(1:(length(nc_E_pth)), 2)   = nc_E_pth;
input_E_pth(1:(length(c_E_pth)), 3)  = c_E_pth;
input_E_pth(1:(length(a_E_pth)), 1)  = a_E_pth;

% gamma_AE
nc_gamma_AE = reversible(:, 9);
c_gamma_AE   = irreversible(:, 9);
a_gamma_AE   = asymp(:, 9);

nc_gamma_AE = log10(nc_gamma_AE);
c_gamma_AE   = log10(c_gamma_AE);
a_gamma_AE   = log10(a_gamma_AE);

input_gamma_AE(1:(length(nc_gamma_AE)), 2)   = nc_gamma_AE;
input_gamma_AE(1:(length(c_gamma_AE)), 3)  = c_gamma_AE;
input_gamma_AE(1:(length(a_gamma_AE)), 1)  = a_gamma_AE;

% kappa_E
nc_kappa_E = reversible(:, 10);
c_kappa_E   = irreversible(:, 10);
a_kappa_E   = asymp(:, 10);

nc_kappa_E = log10(nc_kappa_E);
c_kappa_E   = log10(c_kappa_E);
a_kappa_E   = log10(a_kappa_E);

input_kappa_E(1:(length(nc_kappa_E)), 2)   = nc_kappa_E;
input_kappa_E(1:(length(c_kappa_E)), 3)  = c_kappa_E;
input_kappa_E(1:(length(a_kappa_E)), 1)  = a_kappa_E;

% gamma_EB 
nc_gamma_EB = reversible(:, 12);
c_gamma_EB   = irreversible(:, 12);
a_gamma_EB   = asymp(:, 12);

nc_gamma_EB = log10(nc_gamma_EB);
c_gamma_EB   = log10(c_gamma_EB);
a_gamma_EB   = log10(a_gamma_EB);

input_gamma_EB(1:(length(nc_gamma_EB)), 2)   = nc_gamma_EB;
input_gamma_EB(1:(length(c_gamma_EB)), 3)  = c_gamma_EB;
input_gamma_EB(1:(length(a_gamma_EB)), 1)  = a_gamma_EB;

% delta_EA
nc_delta_EA = reversible(:, 13);
c_delta_EA  = irreversible(:, 13);
a_delta_EA  = asymp(:, 13);

nc_delta_EA = log10(nc_delta_EA);
c_delta_EA  = log10(c_delta_EA);
a_delta_EA  = log10(a_delta_EA);

input_delta_EA(1:(length(nc_delta_EA)), 2)   = nc_delta_EA;
input_delta_EA(1:(length(c_delta_EA)), 3)  = c_delta_EA;
input_delta_EA(1:(length(a_delta_EA)), 1)  = a_delta_EA;

% E_th
nc_E_th = reversible(:, 14);
c_E_th   = irreversible(:, 14);
a_E_th   = asymp(:, 14);

nc_E_th = log10(nc_E_th);
c_E_th   = log10(c_E_th);
a_E_th   = log10(a_E_th);

input_E_th(1:(length(nc_E_th)), 2)   = nc_E_th;
input_E_th(1:(length(c_E_th)), 3)  = c_E_th;
input_E_th(1:(length(a_E_th)), 1)  = a_E_th;

% A_pth
nc_A_pth = reversible(:, 15);
c_A_pth   = irreversible(:, 15);
a_A_pth   = asymp(:, 15);

nc_A_pth = log10(nc_A_pth);
c_A_pth   = log10(c_A_pth);
a_A_pth   = log10(a_A_pth);

input_A_pth(1:(length(nc_A_pth)), 2)   = nc_A_pth;
input_A_pth(1:(length(c_A_pth)), 3)  = c_A_pth;
input_A_pth(1:(length(a_A_pth)), 1)  = a_A_pth;

% kappa_B
nc_kappa_B = reversible(:, 16);
c_kappa_B   = irreversible(:, 16);
a_kappa_B   = asymp(:, 16);

nc_kappa_B = log10(nc_kappa_B);
c_kappa_B   = log10(c_kappa_B);
a_kappa_B   = log10(a_kappa_B);

input_kappa_B(1:(length(nc_kappa_B)), 2)   = nc_kappa_B;
input_kappa_B(1:(length(c_kappa_B)), 3)  = c_kappa_B;
input_kappa_B(1:(length(a_kappa_B)), 1)  = a_kappa_B;

% delta_B 
nc_delta_B = reversible(:, 17);
c_delta_B   = irreversible(:, 17);
a_delta_B   = asymp(:, 17);

nc_delta_B = log10(nc_delta_B);
c_delta_B   = log10(c_delta_B);
a_delta_B   = log10(a_delta_B);

input_delta_B(1:(length(nc_delta_B)), 2)   = nc_delta_B;
input_delta_B(1:(length(c_delta_B)), 3)  = c_delta_B;
input_delta_B(1:(length(a_delta_B)), 1)  = a_delta_B;

% delta_BA
nc_delta_BA = reversible(:, 18);
c_delta_BA   = irreversible(:, 18);
a_delta_BA   = asymp(:, 18);

nc_delta_BA = log10(nc_delta_BA);
c_delta_BA   = log10(c_delta_BA);
a_delta_BA   = log10(a_delta_BA);

input_delta_BA(1:(length(nc_delta_BA)), 2)   = nc_delta_BA;
input_delta_BA(1:(length(c_delta_BA)), 3)  = c_delta_BA;
input_delta_BA(1:(length(a_delta_BA)), 1)  = a_delta_BA;

% delta_BE
nc_delta_BE = reversible(:, 19);
c_delta_BE   = irreversible(:, 19);
a_delta_BE   = asymp(:, 19);

% remove virtual sites with no damage 
a_delta_BE = a_delta_BE(all(a_delta_BE,2),:);
c_delta_BE = c_delta_BE(all(c_delta_BE,2),:);
nc_delta_BE = nc_delta_BE(all(nc_delta_BE,2),:);

% plot those with damage 
nc_delta_BE = log10(nc_delta_BE);
c_delta_BE   = log10(c_delta_BE);
a_delta_BE   = log10(a_delta_BE);

input_delta_BE(1:(length(nc_delta_BE)), 2)   = nc_delta_BE;
input_delta_BE(1:(length(c_delta_BE)), 3)  = c_delta_BE;
input_delta_BE(1:(length(a_delta_BE)), 1)  = a_delta_BE;
%}

PatientTypes = {'A', 'R', 'I'};
% make violin plots:
figure(1); clf
subplot(3, 5, 1)
violinplot(input_kappa_A,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on

yticks([log10(9) log10(27)])
yticklabels({'9', '27'})

ax = gca;
properties(ax)
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SA growth','FontSize',12)

camroll(-90)

subplot(3, 5, 2)
violinplot(input_gamma_AB,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);

yticks([log10(58.7) log10(5870)])
yticklabels({'58.7', '5870'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('Skin inhibition of SA growth','FontSize',12)
camroll(-90)

subplot(3, 5, 3)
violinplot(input_delta_AE,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(4.78) log10(478)])
yticklabels({'4.78', '478'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SA killing by SE','FontSize',12)
camroll(-90)

subplot(3, 5, 4)
violinplot(input_A_th,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(1.13*1e7) log10(1.13*1e9)])
yticklabels({'1.13\times10^{7}', '1.13\times10^{9}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SA QS threshold','FontSize',12)
camroll(-90)

subplot(3, 5, 5)
violinplot(input_E_pth,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on

yticks([log10(1.13*1e7) log10(1.13*1e9)])
yticklabels({'1.13\times10^{7}', '1.13\times10^{9}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SE required to kill SA at half-strength','FontSize',12)
camroll(-90)

subplot(3, 5, 6)
violinplot(input_kappa_E,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(9) log10(27)])
yticklabels({'9', '27'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SE growth','FontSize',12)
camroll(-90)

subplot(3, 5, 7)
violinplot(input_gamma_EB,PatientTypes,'Width',0.25,'ViolinColor',[255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(55.8) log10(5580)])
yticklabels({'55.8', '5580'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('Skin inhibition of SE growth','FontSize',12)
camroll(-90)

subplot(3, 5, 8)
violinplot(input_delta_EA,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(4.78) log10(478)])
yticklabels({'4.78', '478'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SE killing by SA','FontSize',12)
camroll(-90)

subplot(3, 5, 9)
violinplot(input_E_th,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(1.13*1e7) log10(1.13*1e9)])
yticklabels({'1.13\times10^{7}', '1.13\times10^{9}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SE QS threshold','FontSize',12)
camroll(-90)

subplot(3, 5, 10)
violinplot(input_A_pth,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(1.13*1e7) log10(1.13*1e9)])
yticklabels({'1.13\times10^{7}', '1.13\times10^{9}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('SA required to kill SE at half-strength','FontSize',12)
camroll(-90)

subplot(3, 5, 11)
violinplot(input_gamma_AE,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(1.30*1e-9) log10(1.30*1e-7)])
yticklabels({'1.30\times10^{-9}', '1.30\times10^{-7}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('Strength of SA QS inhibition by SE','FontSize',12)
camroll(-90)

subplot(3, 5, 12)
violinplot(input_kappa_B,PatientTypes,'Width',0.25,'ViolinColor',[255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on
yticks([log10(0.0711*10^-1) log10(0.0711*10)])
yticklabels({'0.711\times10^{-2}', '0.711'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('Skin recovery','FontSize',12)
camroll(-90)

subplot(3, 5, 13)
violinplot(input_delta_B,PatientTypes,'Width',0.25,'ViolinColor',[255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on

yticks([log10(0.00289) log10(0.289)])
yticklabels({'0.289\times10^{-2}', '0.289'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('Skin desquamation','FontSize',12)
camroll(-90)

subplot(3, 5, 14)
violinplot(input_delta_BA,PatientTypes,'Width',0.25,'ViolinColor',[255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on

yticks([log10(1e-10) log10(1e-8)])
yticklabels({'1\times10^{-10}', '1\times10^{-8}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;
ylabel('Skin damage by SA','FontSize',12)
camroll(-90)

%{
subplot(3, 5, 15)
violinplot(input_delta_BE,PatientTypes,'Width',0.25,'ViolinColor', [255/255, 165/255, 3/255; 0.75, 0.75, 0.75; 249/255, 7/255, 0/255],'EdgeColor',[1,1,1],'ShowData',false,'ShowBox',false,'ShowWhiskers',false,'MedianColor',[0, 0, 0]);
hold on

yticks([log10(1e-10) log10(1e-8)])
yticklabels({'1\times10^{-10}', '1\times10^{-8}'})

ax = gca;
ax.TickLength = [0.03, 0.03]; % Make tick marks longer.
ax.LineWidth = 0.75; % Make tick marks thicker.
ax.XAxis.FontSize = 12;

ylabel('Skin damage by SE','FontSize',12)
ax = gca; ax.XAxis.FontSize = 12;
camroll(-90)
%}