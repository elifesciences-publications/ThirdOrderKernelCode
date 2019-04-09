function [bestKernel,rTrainingSelected,rTestingSelected,maxTau_DtMax_Range] ...
    = roiAnalysis_OneRoi_RevCorr_OverFittingTest_ModelSelection_1o2o(trainingData,testingData, maxTauRange,barNumRange,barCenter,k,order,dx,dtMaxRange,varargin);
% whether plot those things.
plotFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

stim = trainingData.stim; % huge matrix; 60Hz.
resp = trainingData.resp;

stimTesting = testingData.stim;
respTesting = testingData.resp;
% first, extract kernels, from the training data.
% in the kernel extraction, you would make 3D data into 2D data. so that
% you match the format for the first order kernel
nMaxTau = length(maxTauRange);
nDtMax = length(dtMaxRange); % for the first order kernel, this is not that important.
switch order
    case 1
        nDtMax = 1;
    case 2
        nDtMax = length(dtMaxRange); % for the first order kernel, this is not that important.
end
[maxTauValue,dtMaxValue] = meshgrid(maxTauRange,dtMaxRange);
maxTau_DtMax_Range = struct('maxTau',maxTauValue(:),'dtMax',dtMaxValue(:));
nBarRange = length(barNumRange);

% to makeSure that you have the same set of data for the first and second
% set of data.  you need a better structure to describe it.
nCaseForOneBar = nMaxTau * nDtMax;
nCase = nCaseForOneBar * nBarRange;
nPara = zeros(nCaseForOneBar,nBarRange);

% howmany parameters in each case?

rTraining = cell(size(nPara));
rTesting = cell(size(nPara));
rTrainingSelected = zeros(size(nPara));
rTestingSelected  = zeros(size(nPara));
kernelSelected = cell(size(nPara));
barUsedSelected= false([20,size(nPara)]);
selectedKernelInd = zeros(size(nPara)); % what is this ?

% these will a lot of different kernels.

for tt = 1:1:nCaseForOneBar
    % first order and second order will be different here? yes. for
    % firstOrder the dxMax would be useless.
    switch order
        case 1
            maxTau = maxTauRange(tt);
            % should be the same as maxTau = maxTau_DtMax_Range.maxTau(tt);
            windMask = false(size(k,1),1);
            windMask(1:maxTau) = true;
        case 2
            maxTau = maxTau_DtMax_Range.maxTau(tt);
            dtMax = maxTau_DtMax_Range.dtMax(tt);
            % get the window mask.
            % the size of second order kernel
            kernelFullMaxTau = round(sqrt(size(k,1)));
            windMask = GenKernelWindowMask_2o(kernelFullMaxTau,dtMax,maxTau,0); % bidirectional.
            windMask = windMask(:); % used for later use? when you are extracting second kernel?
    end
    
    for bb = 1:1:nBarRange
        nMultiBars =  barNumRange(bb);
        nPara(tt,bb) = sum(windMask) * nMultiBars;
        leftMostBar = barCenter - 5; % you might make mistakes in terms of finding barCenter. % for the second order kernel.
        nBarUsedSelection = min(ceil(30/nMultiBars),10); % always 5 of them? 20/15. 1. 2 % for second order kernel, this can be extremely slow...
        % reconstruct everything inside
        kernelSelection = cell(nBarUsedSelection,1); % recover the kernel might be hard.
        kernelShow = cell(nBarUsedSelection,1);
        barUsedSelection = cell(nBarUsedSelection,1);
        rTrainingSelection = zeros(nBarUsedSelection,1);
        rTestingSelection = zeros(nBarUsedSelection,1);
        for ii = 1:1:nBarUsedSelection
            % you would start from the leftMostBar;
            barUsedThis = MyMode(leftMostBar+ ii:1:leftMostBar + ii + nMultiBars - 1 ,20);
            barUsedSelection{ii} = barUsedThis;
            kernelSelection{ii} = zeros(sum(windMask),nMultiBars); % it is not correct.
            kernelShow{ii} = zeros(size(k));
             
            [rTestingSelection(ii),kernelSelection{ii}] = RevCorr_ModelSelection_1o2o_Utils_PredResp_AllTrials(respTesting,stimTesting,k,barUsedThis,windMask,order,dx);
            [rTrainingSelection(ii)]= RevCorr_ModelSelection_1o2o_Utils_PredResp_AllTrials(resp,stim,k,barUsedThis,windMask,order,dx);
     
            kernelShow{ii}(windMask,barUsedThis) = kernelSelection{ii};
            
        end
        
        [~,bestKernelInd] = max(rTrainingSelection);
        rTraining{tt,bb} = rTrainingSelection; % plot the mean value. and the error.
        rTesting{tt,bb} = rTestingSelection;
        selectedKernelInd(tt,bb)  = bestKernelInd;
        kernelSelected{tt,bb} = kernelShow{bestKernelInd};
        %         kernel{tt,bb} = roiAnalysis_OneRoi_OLN_OverFittingTest_ShiftKernel( kernelSelection{bestKernelInd},barUsedSelection{bestKernelInd});
        barUsedSelected(barUsedSelection{bestKernelInd},tt,bb) = true;
        rTrainingSelected(tt,bb) = rTrainingSelection(bestKernelInd); % value
        rTestingSelected(tt,bb) = rTestingSelection(bestKernelInd);
        
    end
end

[~,I] = max(rTestingSelected(:));
[maxTau_dtMax_Ind,barRangeInd] =  ind2sub([nCaseForOneBar,nBarRange],I);
bestKernel = kernelSelected{maxTau_dtMax_Ind,barRangeInd};

% you will give out the best kernel,

% your data stucture.


% take a little bit longer to design plotting. it should not be that hard.
% try it.
% how are going to plot it? a little bit tired. but good job this morning!
% do not plot the testing and training data in the same scale...
if plotFlag
    [nParaSort,I] = sort(nPara(:),'ascend');
    rTestingSort = rTesting(I);
    rTrainingSort = rTraining(I);
    rTrainingSelectedSort = rTrainingSelected(I);
    rTestingSelectedSort = rTestingSelected(I);
    % you should compute mean value? nooo....
    MakeFigure;
    subplot(4,2,1);
    scatter(nParaSort ,rTestingSelectedSort,'r');
    title('best bar position - testing');
    subplot(4,2,3);
    scatter(nParaSort ,rTrainingSelectedSort,'b')
    %     legend('testing','training');
    title('best bar position -  training');
    xlabel('params #s');
    ylabel('r');
    
    subplot(4,2,2);
    for ii = 1:1:nCase
        nTrial = length(rTestingSort{ii});
        scatter(nParaSort(ii) * ones(nTrial,1),rTestingSort{ii},'r');
        hold on
    end
    title('individual selections - testing');
    subplot(4,2,4);
    for ii = 1:1:nCase
        nTrial = length(rTestingSort{ii});
        scatter(nParaSort(ii) * ones(nTrial,1),rTrainingSort{ii},'b');
        hold on
    end
    title('individual selections - training');
    xlabel('params #s');
    ylabel('r');
    
    subplot(2,2,3) % two dimensions.
    imagesc(rTrainingSelected); % label your maxTau here,
    title('r for training data');
    ax = gca;
    ax.XTick = 1:nBarRange;
    nBarTickLabel = strsplit(num2str(barNumRange));
    ax.XTickLabel = nBarTickLabel;
    xlabel('bar #s');
    
    ax.YTick = 1:nCaseForOneBar;
    switch order
        case 1
            maxTauTickLabel = strsplit(num2str(maxTauRange/60,2));
        case 2
            maxTauTickLabel = strsplit(num2str(maxTau_DtMax_Range.maxTau'/60,2));
            dtMaxtTickLabel = strsplit(num2str(maxTau_DtMax_Range.dtMax'/60,2));
            ax.YTickLabel = strcat({'maxTau:'},maxTauTickLabel,{', dtMax:'},dtMaxtTickLabel);
    end
    %     ylabel('time [ms]')
    
    colorbar
    subplot(2,2,4)
    imagesc(rTestingSelected);
    title('r for testing data');
    colorbar
    
    ax = gca;
    ax.XTick = 1:nBarRange;
    nBarTickLabel = strsplit(num2str(barNumRange));
    ax.XTickLabel = nBarTickLabel;
    xlabel('bar #s');
    
    ax.YTick = 1:nCaseForOneBar;
    switch order
        case 1
            maxTauTickLabel = strsplit(num2str(maxTauRange/60,2));
            ax.YTickLabel = strcat({'maxTau:'},maxTauTickLabel);
            
        case 2
            maxTauTickLabel = strsplit(num2str(maxTau_DtMax_Range.maxTau'/60,2));
            dtMaxtTickLabel = strsplit(num2str(maxTau_DtMax_Range.dtMax'/60,2));
            ax.YTickLabel = strcat({'maxTau:'},maxTauTickLabel,{', dtMax:'},dtMaxtTickLabel);
    end
    %     ax = gca;
    %     ax.XTick = 1:nBarRange;
    %     ax.YTick = 1:nMaxTau;
    %     nBarTickLabel = strsplit(num2str(barNumRange));
    %     maxTauTickLabel = strsplit(num2str(maxTauRange/60,2));
    %     ax.XTickLabel = nBarTickLabel;
    %     ax.YTickLabel = maxTauTickLabel ;
    %     xlabel('bar #s');
    %     ylabel('time [ms]')
end

% if plotFlag
%     % for the first order order, show three of them
%
%     % for the
%     % find the top three kernels
%     MakeFigure;
%     subplot(2,2,4)
%     quickViewOneKernel_Smooth(k,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
%     title('Full Kernel');
%     % choose the best three.
%     [rTestingSelectedSortByR,I] = sort(rTestingSelected(:),'descend');
%     % fint the indexes for the top three.
%     nKernelShow = 3;
%     [maxTau_dtMax_Ind,barRangeInd] =  ind2sub([nMaxTau,nBarRange],I(1:nKernelShow ));
%     % plot the thing. how are you goind to plot it? fancy way?
%     for kk = 1:1:nKernelShow
%         subplot(2,2,kk);
%         % return it back to 60 * 20. how are you going to do this?
%         maxTauIndThis = maxTau_dtMax_Ind(kk);
%         barNumIndThis = barRangeInd(kk);
%         maxTau = maxTauRange(maxTauIndThis);
%         barUsedThis = barUsedSelected(:,maxTau_dtMax_Ind(kk),barRangeInd(kk));
%
%         % restore the kernel
%         kernelShow = zeros(size(k));
%         kernelShow(1:maxTau,barUsedThis) = kernel{maxTauIndThis,barNumIndThis};
%         quickViewOneKernel_Smooth(kernelShow,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
%         title(['r Test : ',num2str(rTestingSelectedSortByR(kk))]);
%     end
%
% end
% given the best kernel, do you want to draw the




