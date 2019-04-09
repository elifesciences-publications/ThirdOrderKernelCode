close all
clear all

%% Run tp_simplePrediction on extracted kernels and LN models
%% Get kernels - 4 bar ones
load C:\Users\labuser\Documents\kernels\twoPhoton\multiBarFlicker_4_60hz_shortepoch_-49.9down010\05_04_15\second_09_10.mat
maxTau = 40;
colormap_gen;
% which ones looked like something?
for q = 1:20
    figure;
    for r = 1:4
        getKernel = saveKernels.kernels(:,r,q);
        getKernel = reshape(getKernel,[maxTau maxTau]);
        maxVal = max(abs(getKernel(:)));
        subplot(2,2,r);
        imagesc(getKernel);
        set(gca,'Clim',[-maxVal maxVal]);
        colormap(mymap);
    end
end