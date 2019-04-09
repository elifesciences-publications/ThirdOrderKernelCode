function STC_Utils_DeconvSecondKernel_DifferentNSR_Plot(cov_mat_this)
nMultiBars = 20;
bar_plot = [8:13];
maxTau = 64;

kernel_small = cell(nMultiBars,nMultiBars);
kernel_small_deconv = cell(nMultiBars,nMultiBars);

% over estimate the noise? or underestimate the signal?
nsr = STC_Utils_DeconvSecondKernel_EstimateNSR(cov_mat_this);
[ca_psf,t_plot] = Deconvolution_Calcium_Utils_Generate_Calcium_Dynamics('psf');

%%
for ii = 1:1:nMultiBars
    for jj = 1:1:nMultiBars
        indi = (ii - 1) * maxTau + 1: ii * maxTau;
        indj = (jj - 1) * maxTau + 1: jj * maxTau;
        kernel2o = squeeze(cov_mat_this(indi,indj));
        kernel_small{ii, jj} = kernel2o(1:maxTau_half,1:maxTau_half);
    end
end
MakeFigure;
figNum = 1;
subplot(2,2,1)
quickViewCovMat(cell2mat(kernel_small(bar_plot,bar_plot)),'nMultiBars',length(bar_plot));
title(['covariance matrix, nsr_{est} =  ',num2str(nsr)]);
set(gca, 'XTick',[])
set(gca, 'YTick',[])
ConfAxis
%%
nsr_ratio_bank = [0.1,0.2,0.5,1,2,5,10];
subplotNum = [2,3,4,1,2,3,4];
for kk = 1:1:length(nsr_ratio_bank)
    for ii = 1:1:nMultiBars
        for jj = 1:1:nMultiBars
            indi = (ii - 1) * maxTau + 1: ii * maxTau;
            indj = (jj - 1) * maxTau + 1: jj * maxTau;
            kernel2o = squeeze(cov_mat_this(indi,indj));
            kernel_deconv = STC_Utils_DeconvSecondKernel(kernel2o, ca_psf, nsr * nsr_ratio_bank (kk));
            kernel_small_deconv{ii, jj} = kernel_deconv(1:maxTau_half,1:maxTau_half);
        end
    end
    if kk == 4
        % save the first figure;
%         set(gcf,'NumberTitle','off');
%         set(gcf,'Name',['firstKernel_Deconv',typeStr{tt}]);        
        MakeFigure;
        figNum = 2;
    end
    subplot(2,2,subplotNum(kk));
    quickViewCovMat(cell2mat(kernel_small_deconv(bar_plot,bar_plot)),'nMultiBars',length(bar_plot));
    % get rid of the x y Tick
    set(gca, 'XTick',[])
    set(gca, 'YTick',[])
    title(sprintf('nsr = %.1f * nsr_{est} ', nsr_ratio_bank(kk)));
    ConfAxis
end
end
% save the second figure
% set(gcf,'NumberTitle','off');
% set(gcf,'Name',['firstKernel_Deconv',typeStr{tt}]);
% MySaveFig_Juyue(gcf,'secondKernel_Deconv',[typeStr{tt},'_',num2str(figNum)],'nFigSave',2,'fileType',{'fig','png'});

