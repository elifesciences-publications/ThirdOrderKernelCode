function roiCircled = FigPlot2_IndividualKernelAndTrace(roiData,varargin)
roiSelectionMethod = 'kernelQuality';
saveFigFlag = false;
MainName = 'Fig2';
nFigSave = 3;
figFileType = {'fig','eps','png'};
barWidth = roiData{1}.stimInfo.barWidth;
titleStr ={'Progressive T4','Regressive T4','Progressive T5','Regressive T5'};
limPreSetFlag = true;
kernelOrZ = 'kernel';
roiMethod = 'ICA_NNMF';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% choose four filters .
nRoi = length(roiData);
edgeType = zeros(nRoi,1);
firstKernelQuality = zeros(nRoi,1);
% firstKernelMag = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
    firstKernelQuality(rr) = roi.filterInfo.firstKernel.quality;
end
selectionValue =  firstKernelQuality;
subplotNum = [1,2,5,6;3,4,7,8;9,10,13,14;11,12,15,16];
if strcmp(roiSelectionMethod,'manual')
%     load('C:\Users\Clark Lab\Documents\Holly_log\10_22_2015\FigurePlotCode\Fig2\individualSecondKernel.mat');
%     roiData = roiFigPlot2Individual;
    bestRoi = [1,2,3,4;5,6,7,8;9,10,11,12;13,14,15,16];
else
    % first, find the best roi.
    %     bestRoi = zeros(4,4);
    %     for tt = 1:1:4
    %         roiUse = find(edgeType == tt);
    %         [~,indSort] = sort(selectionValue(roiUse),'descend');
    %         bestRoi(tt,1:min(4,length(roiUse))) = roiUse(indSort(1:min(4,length(roiUse))));
    %     end
    bestRoi = FigPlot2_Util_SelectIndividualKernel(roiData,4,1);
    % second, find the maxvalue in those filters.
end
MakeFigure;
% change the structure...
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
            switch kernelOrZ
                case 'kernel'
                    filterThis = roiData{rr}.filterInfo.firstKernel.Adjusted;
                case 'Z'
                    filterThis = roiData{rr}.filterInfo.firstKernel.ZAdjusted;
            end
            maxFilterThis = max(abs(filterThis(:)));
            if maxFilterValueAll <  maxFilterThis
                maxFilterValueAll = maxFilterThis;
            end
        end
        for ii = 1:1:nRoiPlot
            rr = bestRoi(tt,ii);
            subplot(4,4,subplotNum(tt,ii));
            name = roiData{rr}.typeInfo.edgeName;
            switch kernelOrZ
                case 'kernel'
                    kernel = roiData{rr}.filterInfo.firstKernel.Adjusted;
                case 'Z'
                    kernel = roiData{rr}.filterInfo.firstKernel.ZAdjusted;
            end
            quickViewOneKernel_Smooth(kernel,1,'labelFlag',true,...
                'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag',false,'barRange',[5:15],'timeRange',1:45,...
                'limPreSetFlag',limPreSetFlag,'maxValue',maxFilterValueAll);
            %             quickViewOneKernel(roiData_Aligned{rr}..firstKernelAdjusted,1,'labelFlag',false,'posUnit',barWidth,'timeUnit',1/60);
            title(name);
        end
    end
end
if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_a_IndividualRoiKernel','nFigSave',nFigSave,'fileType',figFileType);
end

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
%         FigPlot2_PlotTraceFor4Roi(roiDataUse);
        FigPlot2_PlotTraceFor4Roi_NonShifted(roiDataUse);
    end
    
end

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_a_IndividualRoiTrace','nFigSave',nFigSave,'fileType',figFileType);
end

roiCircled = bestRoi(:);
roiCircled(roiCircled== 0) = [];