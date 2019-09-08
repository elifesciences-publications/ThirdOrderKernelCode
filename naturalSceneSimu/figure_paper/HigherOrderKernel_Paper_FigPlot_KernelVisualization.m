function HigherOrderKernel_Paper_FigPlot_KernelVisualization()
maxTau = 64;
tMax = 46; % 0.75 second. Error for third order kernel... get this fixed.
% load kernel
kernel = load('D:\Natural_Scene_Simu\parameterdata\ori_reverse_correlation.mat');
% symmetrize individual k2...

k2_sym_individual = kernel.kernel.k2_ind;
k2_sym_mean = kernel.kernel.k2_sym; % show the original one first.

k3_sym_individual = (kernel.kernel.k3_xxy_ind - kernel.kernel.k3_yyx_ind)/2;
nfly = size(k3_sym_individual,2);
k3_sym_individual = reshape(k3_sym_individual, [maxTau, maxTau, maxTau, nfly]);
k3_sym_mean = kernel.kernel.k3_sym;
% shuffled kernel
kernel_noise = load('D:\Natural_Scene_Simu\parameterdata\ori_reverse_correlation_noise.mat');
k3_sym_noise = kernel_noise.kernel.k3_sym;
k2_sym_noise = kernel_noise.kernel.k2_sym;
% get the correct scale
dt = 1/60;
k3_sym_individual = k3_sym_individual/(dt^3);
k3_sym_mean = k3_sym_mean/(dt^3);
k3_sym_noise = k3_sym_noise/(dt^3);
k2_sym_mean = k2_sym_mean/(dt^2);
k2_sym_noise = k2_sym_noise/(dt^2);

%% plot second order kernel. impulse response, and glider... get old code
% you have to go back and forth between
hor_inches = 2;

% do not plot them one by one? 
MakeFigure; 
quickViewOneKernel_Smooth(k2_sym_mean(:), 2,'limPreSetFlag',false);
xlabel('time in past, bar 1(s)');
ylabel('time in past, bar 2(s)');

% decide the size of second order kernel/
ax = gca;
ax.Units = 'inches';
currPos = ax.Position;
ax.Position = [currPos(1), currPos(2), hor_inches, hor_inches];
High_Corr_PaperFig_Utils_SmallFontSize();

MySaveFig_Juyue(gcf,'Behavior_K2','v0','nFigSave',2,'fileType',{'eps','svg'});


MakeFigure;
K2_Visualization_ImpulseResponse_Glider(k2_sym_mean, k2_sym_individual, k2_sym_noise, 'tMax', 48,'dtxy_bank',[-5:5]);
MySaveFig_Juyue(gcf,'Behavior_K2_Impulse_','v0','nFigSave',2,'fileType',{'eps','svg'});

%% Three D plot.
MakeFigure;
dtxx_bank = 1;
dtxy_bank = [0,1];
K3_BehaviorKernel_Visualization_ThreeD(k3_sym_mean, dtxx_bank, dtxy_bank,'hor_inches', hor_inches);
MySaveFig_Juyue(gcf,'Behavior_K3_Visualiztion_3d','v0','nFigSave',1,'fileType',{'eps'});
%% plot the impulse response.
dtxx_bank = 1:2;
dtxy_bank = -4:4;
K3_visualization_impulse = K3_Visualization_ImpulseResponse_Glider(k3_sym_mean,k3_sym_individual,k3_sym_noise, 'tMax', 46,'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'plot_flag', true,...
    'hor_inches',hor_inches);
MySaveFig_Juyue(gcf,'Behavior_K3_Visualiztion_impulse','v0','nFigSave',2,'fileType',{'eps','svg'});
% EPS