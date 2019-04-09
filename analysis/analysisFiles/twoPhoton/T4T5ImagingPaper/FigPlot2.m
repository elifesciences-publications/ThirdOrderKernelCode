function roiData = FigPlot2(roiData,varargin)
% FigPlot2(roiData,'roiSelectionMethod','kernelQuality','kernelExtractionMethod','OLS');
% Plot Selection Method.
% method could be ESI, DSI, KernelQuality;
roiSelectionMethod = 'kernelQuality';
kernelExtractionMethod = 'OLS';
bestRoi = [5,17,18,21;14,18,38,43;15,16,21,27;1,3,27,30];
saveFigFlag = false;
MainName = 'Fig2';
nFigSave = 3;
figFileType = {'fig','eps','png'}

titleStr ={'Progressive T4','Regressive T4','Progressive T5','Regressive T5'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


% roiData_Aligned  = roiAnalysis_AlignedKernelCenter_Main(roiData);
nRoi = length(roiData);
if ~isfield(roiData{1},'LN')
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_OneRoi_LN_OLS(roiData{rr});
    end
    
end
%% choose four filters .
nRoi = length(roiData);
edgeType = zeros(nRoi,1);
ESI = zeros(nRoi,1);
DSI_Diff = zeros(nRoi,1);
DSI_Edge = zeros(nRoi,1);
firstKernelQuality = zeros(nRoi,1);
% firstKernelMag = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
    % there are 20 bars. you select the barSele
    %     firstKernelQuality(rr) =  sum(roi.filterInfo.firstKernelQuality(roi.filterInfo.firstBarSelected));
    firstKernelQuality(rr) = roi.filterInfo.firstKernelQuality;
    %     firstKernelQuality(rr) = -max(roi.filterInfo.firstKernelQuality);
    ESI(rr) = roi.typeInfo.ESI;
    DSI_Diff(rr) = roi.typeInfo.DSI_Diff;
    DSI_Edge(rr) = roi.typeInfo.DSI_Edge;
    %     firstKernelMag(rr) = roi.filterInfo.firstKernelMagnitude; % this might be the best way to get good kernel.
end

switch roiSelectionMethod
    case 'kernelQuality'
        value =  firstKernelQuality;
    case 'DSI_Diff'
        value = DSI_Diff;
    case 'ESI'
        value = ESI;
    case 'DSI_Edge'
        value = DSI_Edge;
    case 'firstKernelMag'
        value = firstKernelMag;
end
%% there are four types, each four types, you need at least four rois.
% plot the best filter you have.
barWidth = roiData{1}.stimInfo.barWidth;
subplotNum = [1,2,5,6;3,4,7,8;9,10,13,14;11,12,15,16];
if strcmp(roiSelectionMethod,'manual')
    nRoiPlot = 4;
    
    for tt = 1:4
        roiUse = find(edgeType == tt);
        
        for ii = 1:1:nRoiPlot
            bestRoi(tt,ii) = roiUse(bestRoi(tt,ii));
            rr =   bestRoi(tt,ii);
            subplot(4,4,subplotNum(tt,ii));
            % you have to label what is the name of those roi...
            name = roiData{rr}.typeInfo.edgeName;
            %             quickViewOneKernel_Smooth(roiData_Aligned{rr}.filterInfoNew.firstKernelCenteredAdjusted,1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60);
            %             quickViewOneKernel_Smooth(roiData{rr}.filterInfoNew.firstKernelAdjusted,1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60);
            title(name);
        end
    end
else
    % first, find the best roi.
    bestRoi = zeros(4,4);
    for tt = 1:1:4
        roiUse = find(edgeType == tt);
        [~,indSort] = sort(value(roiUse),'descend');
        bestRoi(tt,1:min(4,length(roiUse))) = roiUse(indSort(1:min(4,length(roiUse))));
    end
    % second, find the maxvalue in those filters.
    MakeFigure;
    for tt = 1:1:4
        roiPlot = bestRoi(tt,1:4);
        % count non zeros numbers.
        nRoiPlot = length(find(roiPlot> 0));
        if nRoiPlot == 0
            disp('bad luck, no filter is good for this roi');
        else
            maxFilterValueAll = 0;
            for ii = 1:1:nRoiPlot
                rr = bestRoi(tt,ii);
                filterThis = roiData{rr}.filterInfo.firstKernelAdjusted;
                maxFilterThis = max(abs(filterThis(:)));
                if maxFilterValueAll <  maxFilterThis
                    maxFilterValueAll = maxFilterThis;
                end
            end
            for ii = 1:1:nRoiPlot
                rr = bestRoi(tt,ii);
                subplot(4,4,subplotNum(tt,ii));
                name = roiData{rr}.typeInfo.edgeName;
                quickViewOneKernel_Smooth(roiData{rr}.filterInfo.firstKernelAdjusted,1,'labelFlag',true,...
                    'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag','true','barRange',[5:15],'timeRange',1:45,...
                    'limPreSetFlag',true,'maxValue',maxFilterValueAll);
                %             quickViewOneKernel(roiData_Aligned{rr}..firstKernelAdjusted,1,'labelFlag',false,'posUnit',barWidth,'timeUnit',1/60);
                title(name);
            end
        end
    end
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,'_a_IndividualRoiKernel','nFigSave',nFigSave,'fileType',figFileType);
    end
    % plot traces for each for of them....
    MakeFigure;
    for tt = 1:1:4
        roiPlot = bestRoi(tt,1:4);
        % count non zeros numbers.
        nRoiPlot = length(find(roiPlot> 0));
        if nRoiPlot == 0
            disp('bad luck, no filter is good for this roi');
        else
            roiDataUse = cell(nRoiPlot,1);
            for ii = 1:1:nRoiPlot
                rr = bestRoi(tt,ii);
                roiDataUse{ii} = roiData{rr};
            end
            subplot(2,2,tt);
            % how do you make sure that they are on the same scale?
            FigPlot2_PlotTraceFor4Roi(roiDataUse);
        end
        
    end
    
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,'_a_IndividualRoiTrace','nFigSave',nFigSave,'fileType',figFileType);
    end
end



% plot the averaged filter...
% calculate mean filter four each type..
% roiData_Aligned  = roiAnalysis_AlignedKernelCenter_Main(roiData);
meanKernel = roiAnalysis_AverageFirstKernel(roiData,'typeSelected',[1,2,3,4]);
maxFilterValue = max(abs(meanKernel(:)));
MakeFigure;

for tt = 1:1:4
    subplot(2,2,tt);
    quickViewOneKernel_Smooth(meanKernel(:,:,tt),1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag','true','barRange',[5:15],'timeRange',1:45,...
        'limPreSetFlag',false,'maxValue',maxFilterValue);
    title(titleStr{tt})
    %     quickViewOneKernel_Smooth(meanKernel(:,:,tt),1,'labelFlag',false,'posUnit',barWidth,'timeUnit',1/60);
end

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_b_kernel','nFigSave',nFigSave,'fileType',figFileType);
end

% Plot the Non-linearity
MakeFigure;
[~,edgeTypeColorRGB,~] = FigPlot1ColorCode();
subplotNum = [1,2,3,4];
nBins = 30;
nOneBin = 50;
predRespAll = cell(4,1);
respAll = cell(4,1);
predMean = cell(4,1);
respMean = cell(4,1);
for tt = 1:1:4
    roiUse = find(edgeType == tt);
    nRoiPlot = length(roiUse);
    if nRoiPlot == 0
        disp('bad luck, no filter is good for this roi');
    else
        predRespAll{tt} = zeros(nBins + 2,nRoiPlot);
        respAll{tt} = zeros(nBins + 2,nRoiPlot);
        % plot the LN for this guy, all of them...only for the one that are
        % showed... four of them. not all of them.
        for ii = 1:1:nRoiPlot
            rr = roiUse(ii);
            subplot(2,2,subplotNum(tt));
            % you have to label what is the name of those roi...
            name = roiData{rr}.typeInfo.edgeName;
            predResp = roiData{rr}.LN.predResp;
            resp = roiData{rr}.LN.resp;
            [x_,y_,n] = BinXY_FixedBinValue(predResp,resp,'x',nBins);
            x_Plot = x_(n > nOneBin);
            y_Plot = y_(n > nOneBin);
            FigPlot2_OneLN(x_Plot,y_Plot,'color',[0.5,0.5,0.5],'lineWidth',1);
            %             ConfAxis;
            %             PlotLNModel(predResp,resp,'color',[0.5,0.5,0.5],'lineWidth',1,'markerType','.','titleFlag',false,'plotMethod','line','setAxisLimFlag',0,'plotDashLineFlag',0);
            hold on
            x_(n <= nOneBin) = NaN;
            y_(n <= nOneBin) = NaN;
            
            predRespAll{tt}(:,ii) = x_;
            respAll{tt}(:,ii) = y_;
            % for the average response. you have to plot the nonlinearity
            % in a different way.....
        end
        % how do you calcualte mean?
        [predMean{tt},respMean{tt}] = FigPlot2_MyNanMean(predRespAll{tt},respAll{tt});
        % how do plot that error bar?
        FigPlot2_OneLN(predMean{tt},respMean{tt},'color',edgeTypeColorRGB(tt,:),'lineWidth',1);
        %         ConfAxis;
        title(name);
    end
end

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_b_LN','nFigSave',nFigSave,'fileType',figFileType);
end

end