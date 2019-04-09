function kernelsRaw = SAC_Temp_ReplicatePaperFigure(filename, fileID_name, color_to_plot, saveFigFlag)
% how much get used in the end? not sure.
load(filename)
maxTau = 250;
%%
filters_flip = fliplr(filters(1:250,2:end));
%% organize the data into our data format.  cell array for different cell.
nMultiBars = size(stim, 2);
%%
% get stimulus
respData = {single(r - mean(r))};
stimDataGPU1 = cell(nMultiBars,1);
for qq = 1:1: nMultiBars
    stimDataGPU1{qq} = single(stim(:,qq));
end
%% first order kernel
sumCPU = oned_cpu_gpu_format(maxTau,stimDataGPU1,respData);

kernelsRaw = zeros(maxTau,nMultiBars,1);
for qq = 1:1:nMultiBars
    kernelsRaw(:,qq) = permute(sumCPU{qq},[1,3,2]);
end
kernels = kernelsRaw/length(respData{1} - maxTau); % normalize the thing in the correct way....

% the strength are different, use the largest absolute value to scale it...
kernelRaw_scale = kernels/max(abs(kernels(:)));
filters_scale = filters_flip/max(abs(filters_flip(:)));

MakeFigure;
subplot(1,2,1)
quickViewOneKernel_SAC_sepratedLocation(filters_scale , color_to_plot);
title(['Bart Kernel ', strsplit(fileID_name,'_')]);
subplot(1,2,2)
quickViewOneKernel_SAC_sepratedLocation(kernelRaw_scale, color_to_plot)
title(['Damon Kernel ', strsplit(fileID_name,'_')]);

if saveFigFlag
    MySaveFig_Juyue(gcf, [fileID_name],'1o_Replication', 'nFigSave',2,'fileType',{'png','fig'})
end
end