function [predResp, resp] = STC_Utils_PredResp_ARMA_SuperLong_Resp(respData,stimData,stimIndexes, kernel, varargin)
% if respData is extremely long, then cut it shorter to do prediction
maxTau = 32;
nMultiBars = 20;
barUse = 1:20;
dx = 1;
nOneBin = 30;
nBin = [10,10];
align_stimulus_flag = false;
roi = [];
plotFlag = true;
plot_which = 'resp';
edge_distribution = 'histeq';
plot_flag = false;
n_resp_max = 10000;
order = 1;
yLabelStr = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

n_kernel = size(kernel,3);
predResp = cell(n_kernel,1);
resp = [];
n_batch = ceil(length(respData)/n_resp_max);
tic
for nn = 1:1:n_batch
    ind_this_batch = (nn-1) * n_resp_max + 1: min( nn * n_resp_max, length(respData));
    respData_this_batch    = respData(ind_this_batch);
    stimData_this_batch    = stimData(ind_this_batch, :);
    stimIndexes_this_batch = stimIndexes(ind_this_batch) - (nn - 1) * n_resp_max;
    [OLSMat] = tp_Compute_OLSMat({respData_this_batch}, stimData_this_batch, {stimIndexes_this_batch} ,'maxTau',maxTau,'order',1,'nMultiBars', nMultiBars,'barUse', barUse,'setBarUseFlag', true);
    
    pred_resp_this_batch = cell(n_kernel,1);
    for ii = 1:1:n_kernel
        pred_resp_this_batch{ii} = zeros(length(OLSMat.resp{1}),1);
        kernel_this = kernel(:,:,ii); % this is first order kernel.
        for qq = 1:1:nMultiBars
            pred_resp_this_batch{ii} = pred_resp_this_batch{ii} + OLSMat.stim{qq} * kernel_this(:,qq);
        end

    end
    for ii = 1:1:n_kernel
        predResp{ii} = cat(1,predResp{ii}, pred_resp_this_batch{ii}); %
    end
    resp = cat(1, resp, double(OLSMat.resp{1}));
end
% response should be used? no
% resp = OLSMat.resp{1};
toc
%%
if plot_flag
    resp_plot = resp;
    clean_extreme_value_flag = false;
    % This plotting function is wiered. not sure what is happening... is
    % that right>
    switch order
        case 2
            STC_Utils_PredRespAndResp_Plot(predResp,resp_plot, 'nBin', nBin,...
                'edge_distribution', edge_distribution ,'clean_extreme_value_flag', clean_extreme_value_flag,varargin{:},'yLabelStr', yLabelStr);
        case 1
            ScatterXYBinned(predResp{1},resp_plot,50,100);
            title('first order kernel');
            ylabel(yLabelStr);
            xlabel('predicted response');
            % calculate the correlation 
            co = corr(resp_plot,predResp{1});
            legend(sprintf('r = %f', co));
            
    end
end