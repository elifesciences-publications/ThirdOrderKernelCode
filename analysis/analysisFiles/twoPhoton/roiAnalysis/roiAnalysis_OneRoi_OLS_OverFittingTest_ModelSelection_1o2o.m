function [bestKernel,rTrainingSelected,rTestingSelected,maxTau_DtMax_Range] = roiAnalysis_OneRoi_OLS_OverFittingTest_ModelSelection_1o2o(trainingData,testingData, maxTauRange,barNumRange,barCenter,k,order,dtMaxRange,varargin);
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
        % arrange for the data.
        %         tic
        %         [kernelShowReExt,rTrainingSelectionReExt,rTestingSelectionReExt] = roiAnalysis_OneRoi_OLS_ReExtraAndIndex_Test(nMultiBars,windMask,barCenter,k,stim,resp,stimTesting,respTesting,'reExtra');
        %         toc
        %         tic % not as good as the OLS.  but because of the speed, use ex
        %         [kernelShowInd,rTrainingSelectionInd,rTestingSelectionInd] = roiAnalysis_OneRoi_OLS_ReExtraAndIndex_Test(nMultiBars,windMask,barCenter,k,stim,resp,stimTesting,respTesting,'indexed');
        %         toc
        nMultiBars =  barNumRange(bb);
        nPara(tt,bb) = sum(windMask) * nMultiBars;
        leftMostBar = barCenter - 7; % you might make mistakes in terms of finding barCenter. % for the second order kernel.
        %         rightMostBar = barCenter + 7; % make sure that you have enough. 5 fold?
        %         nBarUsedSelection = ceil((rightMostBar -  leftMostBar + 1)/nMultiBars);
        %
        nBarUsedSelection = ceil(30/nMultiBars); % always 5 of them? 20/15. 1. 2
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
            predRespTrainingSelection = zeros(length(resp),nMultiBars);
            predRespTestingSelection = zeros(length(respTesting),nMultiBars);
            for qq = 1:1:nMultiBars                                          % you should use the original kernel, or extract kernel yourself. interesting!
                barNum = barUsedThis(qq);
                % use the window...the second order kernel should have
                % similar structure.
                SS = stim{barNum}(:,windMask); % only get those used predictors.
                RR = resp;
                % could set a switch here. calculation for the second order
                % kernel is too slow.
                %                                 kernelSelection {ii}(:,qq) = SS\RR; %
                %                                 reextract kernel
                % just use the value in the old kernel, much faster, no difference in
                % result?
                kernelSelection {ii}(:,qq)  = k(windMask,barNum); % interesting! % 300 predictors 0.3 seconds, 4000 predictors 30 seconds. pretty linear.
                predRespTrainingSelection(:,qq) = SS * kernelSelection {ii}(:,qq);
                
                SS = stimTesting{barNum}(:,windMask);
                predRespTestingSelection(:,qq) = SS * kernelSelection {ii}(:,qq); % you had better rextracted....it is different view points.
            end
            predRespTrainingSelection = sum(predRespTrainingSelection,2);
            predRespTestingSelection = sum(predRespTestingSelection,2);
            
            rTrainingSelection(ii) = corr(predRespTrainingSelection, resp); % with a large number of bar, it becomes even smaller, for the testing data.... why it that?
            rTestingSelection(ii) = corr(predRespTestingSelection,respTesting ); % extremely samll....
            
            kernelShow{ii}(windMask,barUsedThis) = kernelSelection{ii};
            
        end
        
        % do not use Testing, use Training to choose.
%         [~,bestKernelInd] = max(rTestingSelection);
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




