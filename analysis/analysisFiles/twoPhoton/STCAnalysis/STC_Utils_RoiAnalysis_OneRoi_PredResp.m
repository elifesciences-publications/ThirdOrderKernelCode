function roi = STC_Utils_RoiAnalysis_OneRoi_PredResp(roi,cov_mat_eigenvector)
maxTau_half = 32;
nMultiBars = 20;
plotFlag = true;


edgeType = roi.typeInfo.edgeType;
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
roi.filterInfo.barCenter = barCenter;


roiNum = roi.stimInfo.roiNum;
S = GetSystemConfiguration;
load([S.kernelSavePath, roi.stimInfo.flickPath]);
stimIndexes = flickSave.stimIndexed(roiNum);
respData = flickSave.respData(roiNum);
stimData = flickSave.stimData;
[OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',1,'maxTau',maxTau_half);

% you have to shift the stimulus..
barNumCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(1:nMultiBars,roi.filterInfo.barCenter);
OLSMat.stim = OLSMat.stim(barNumCentered);
if strcmp(roi.flyInfo.flyEye,'right') || strcmp(roi.flyInfo.flyEye,'Right')
    OLSMat.stim = OLSMat.stim(end:-1:1);
end

nEigen = size(cov_mat_eigenvector,3);
predResp = cell(nEigen,1);
for ii = 1:1:nEigen
    predResp{ii} = zeros(length(OLSMat.resp{1}),1);
    kernel_this = cov_mat_eigenvector(:,:,ii);
    
    % without convolving with the calcium signal.
    for qq = 1:1:nMultiBars
        predResp{ii} = predResp{ii} + OLSMat.stim{qq} * kernel_this(:,qq);
    end
end
resp = OLSMat.resp{1};


stc_analysis.eigenvector = cov_mat_eigenvector;
stc_analysis.resp = resp;
stc_analysis.predResp = predResp;

roi.stc_analysis = stc_analysis;

%% check whether the mean stimulus has mean zero


% what is the stimulus and response.
% what is the variance of the 10000 binary stimulus adding together? how
% you are going to do this? estimation



%% plot function
if plotFlag
    %% first, plot the binned result and the corresponding standard deviation. 
%     nBin = [30,30];
%     [binedx,binedy,binedz,n_x, n_y, n_z,binedz_sem] = BinXYZ(predResp{1},predResp{2},resp,nBin);
%     masks = ~isnan(binedz);
%     % set the zeros part to be nan?
%     binedz(~masks)     = 0;
%     binedz_sem(~masks) = 0;
%     MakeFigure;
%     subplot(2,2,1)
%     ImagescXYZBinned(binedx,binedy,binedz,'binFlag',false,'titleStr',[' original F(e1,e2)'],'xLabelStr','E1','yLabelStr','E2');
%     subplot(2,2,2)
%     ImagescXYZBinned(binedx,binedy,binedz_sem,'binFlag',false,'titleStr',[' original F(e1,e2), sem'],'xLabelStr','E1','yLabelStr','E2');
    %% second, plot the contour.
    nOneBin = 50;
    nBin = [30,30];
 
    
    [binedx,binedy,binedz,n_x, n_y, n_z] = BinXYZ(predResp{1},predResp{2},resp,nBin);
    
    % if there are less than 100 points. you should not draw it.
    % only draw part of it. in terms of n_x, n_y. interms of z,100 .
    
    % by n_x and n_y would be easier.
    % use the connected?
    
    ind_z = n_z > nOneBin;
    masks = MyBWConncomp(ind_z,1);
    % set the zeros part to be nan?
    binedz(~masks) = 0;
    
    %%
    MakeFigure;
    subplot(5,5,[7,8,9,12,13,14,17,18,19,22,23,24])
    ImagescXYZBinned(binedx,binedy,binedz,'binFlag',false,'titleStr',[' original F(e1,e2)'],'xLabelStr','E1','yLabelStr','E2')
    
    % contour plot
    zmin = min(binedz(:));
    zmax = max(binedz(:));
    zinc = (zmax - zmin) / 10;
    zlevs = zmin:zinc:zmax;
    
    hold on
    contour(binedx,binedy,binedz,zlevs,'LineColor','k','LineWidth', 1);
    xlabel('E2 response');
    ylabel('E1 response');
    title([]);
    ConfAxis
    
    [binedx_only,binedxz_only] = BinXY(predResp{1},resp,'x',20);
    [binedy_only,binedyz_only] = BinXY(predResp{2},resp,'x',20);
    subplot(5,5,[2,3,4])
    % scatter(binedx_only,binedxz_only,'.');
    ScatterXYBinned(predResp{2},resp,nBin(2),nOneBin,'plotDashLineOtherSideFlag',true,'color','k')
    title('E2 Marginal');
    ylabel('firing rate');
    ConfAxis
    
    subplot(5,5,[6,11,16,21]);
    ScatterXYBinned(predResp{1},resp,nBin(1),nOneBin,'plotDashLineOtherSideFlag',true,'color','k')
    title('E1 Marginal');
    ylabel('firing rate');
    ConfAxis;
    view(90,90);
    
%     MakeFigure;
%     subplot(2,2,1);
%     histogram(predResp{1});
%     title('E1');
%     subplot(2,2,2);
%     histogram(predResp{2}); % it is really symmetric.
%     title('E2');
%     subplot(2,2,3);
%     histogram(resp)
%     title('resp'); % this is highly asymmetric.
%     
end
end