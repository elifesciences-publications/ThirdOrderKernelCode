% set this up for all four types...

function SAC_Temp_1o_DownSampleAndBin(filename, fileID_name, saveFigureFlag)
maxTime = 500; % 500 ms.
% for each file, you have to prepare the stimulus....
load(filename);
load('D:\data_sac\stim_data.mat');

%% use frameis and stim_data to create stim.
% generate stim from stim data.
stim = zeros(length(r), 10);
for ii = 1:1:length(frameis) - 1
    idx = frameis(ii):frameis(ii + 1) - 1;
    stim(idx,:) = repmat(stim_data(ii,:), length(idx), 1);
end

size_each_bin = 2;
stim_binned = SAC_Temp_BinStimulus(stim, size_each_bin);
nMultiBars_binned = size(stim_binned, 2);

nMultiBars = size(stim, 2);
resp_375Hz = zeros(length(frameis), 1);
stim_375Hz = zeros(length(frameis), nMultiBars);
stim_binned_375Hz = zeros(length(frameis), nMultiBars_binned);
for ii = 1:1:length(frameis) - 1
    resp_375Hz(ii) = sum(r(frameis(ii): frameis(ii + 1) - 1));
    stim_375Hz(ii,:) = stim(frameis(ii),:);
    stim_binned_375Hz(ii,:) = stim_binned(frameis(ii),:);
end
%%

% do a cross-correlation. prepare for the
maxTau_375Hz = ceil(500/(1000/37.5));
maxTau = 500;
kernels = Main_KernelExtraction_ReverseCorr({r}, stim, {1:length(r)}, 'maxTau', maxTau);
kernels_375Hz = Main_KernelExtraction_ReverseCorr({resp_375Hz}, stim_375Hz, {1:length(resp_375Hz)}, 'maxTau', maxTau_375Hz);
kernels_binned = Main_KernelExtraction_ReverseCorr({r}, stim_binned, {1:length(r)}, 'maxTau', maxTau);
kernels_binned_375Hz = Main_KernelExtraction_ReverseCorr({resp_375Hz}, stim_binned_375Hz, {1:length(resp_375Hz)}, 'maxTau', maxTau_375Hz);
%% it is all over the place...
MakeFigure; 
subplot(2,2,1)
quickViewOneKernel(kernels,1, 'genotype', 'SAC', 'f', 1000, 'colorbarFlag', false);
title([strsplit(fileID_name,'_'), 'direct reverse correlation']);
ConfAxis

subplot(2,2,2)
quickViewOneKernel(kernels_375Hz,1, 'genotype', 'SAC', 'f', 37.5, 'colorbarFlag', false);
title('down sample response');
ConfAxis

subplot(2,2,3);
quickViewOneKernel(kernels_binned,1, 'genotype', 'SAC', 'f', 1000, 'colorbarFlag', false, 'bin_stim_flag', true);
title('bin stimulus');
ConfAxis

subplot(2,2,4);
quickViewOneKernel(kernels_binned_375Hz, 1,  'genotype', 'SAC', 'f',37.5, 'colorbarFlag', false, 'bin_stim_flag', true); 
title('down sample response and bin stimulus');
ConfAxis

%% OverArching Title.

if saveFigureFlag
    MySaveFig_Juyue(gcf, [fileID_name],'1o_Bin_DownSample', 'nFigSave',2,'fileType',{'png','fig'})
end
end
% what if you bin stimulus.
% look at other and do a comparison.
