function stc_analysis =  STC_Utils_PredResp_ARMA(respData,stimData,stimIndexes,cov_mat_eigenvector, varargin)
maxTau = 32; % small guy.. % shuffle?
nMultiBars = 20; % hard coded it. use all of it. % you also have baruse... because you have to do prediction.
barUse = 1:20;
dx = 1;
nOneBin = 30;
nBin = [10,10];
align_stimulus_flag = false;
roi = [];
plotFlag = true;
plot_which = 'resp';
edge_distribution = 'histeq';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

[OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'maxTau',maxTau,'order',1,'arma_flag',true,'maxTau_r',1,'dx',dx, 'nMultiBars', nMultiBars,'barUse', barUse,'setBarUseFlag', true);
% do not have to shift the response.
if align_stimulus_flag
    barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
    barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(1:nMultiBars,barCenter);
    OLSMat.stim = OLSMat.stim(barNumCentered);
    if strcmp(roi.flyInfo.flyEye,'right') || strcmp(roi.flyInfo.flyEye,'Right')
        OLSMat.stim = OLSMat.stim(end:-1:1);
    end
end

nEigen = size(cov_mat_eigenvector,3);
predResp = cell(nEigen,1);
for ii = 1:1:nEigen
    predResp{ii} = zeros(length(OLSMat.resp{1}),1);
    kernel_this = cov_mat_eigenvector(:,:,ii); % this is first order kernel.
    
    % without convolving with the calcium signal.
    for qq = 1:1:nMultiBars
        predResp{ii} = predResp{ii} + OLSMat.stim{qq} * kernel_this(:,qq);
    end
end

% response should be used? no
resp = OLSMat.resp{1};
resp_without_auto = OLSMat.resp{1} - OLSMat.resp_auto{1};

stc_analysis.eigenvector = cov_mat_eigenvector;
stc_analysis.resp = resp;
stc_analysis.resp_without_auto = resp_without_auto;
stc_analysis.predResp = predResp;
%%
if plotFlag
    switch plot_which
        case 'resp'
            resp_plot = resp;
        case 'resp_without_auto'
            resp_plot = resp_without_auto;
    end
    clean_extreme_value_flag = false;
    
    STC_Utils_PredRespAndResp_Plot(predResp,resp_plot,'edge_distribution', edge_distribution ,'clean_extreme_value_flag', clean_extreme_value_flag,varargin{:});
end