function FigPlot2_Center(roiData,varargin)

threshArea = 10;
[~,~,DarkLightColor] = FigPlot1ColorCode();
saveFigFlag = false;
MainName = 'Fig2_KernelCenter';
nFigSave = 3;
figFileType = {'fig','eps','png'};
barWidth = roiData{1}.stimInfo.barWidth;
titleStr ={'Progressive T4','Regressive T4','Progressive T5','Regressive T5'};

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% a lot of complex things...

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
% get all the things out ? and do the judgement. in the end, plot them?


center.neg.flag = zeros(nRoi,1);
center.pos.flag = zeros(nRoi,1);
center.neg.center = zeros(nRoi,2);
center.pos.center = zeros(nRoi,2);

for rr = 1:1:nRoi
    centerInfo = roiData{rr}.filterInfo.centerInfo;
    
    if centerInfo.neg.maxArea > threshArea
        center.neg.flag(rr) = true;
        center.neg.center(rr,:) = centerInfo.neg.center;
    end
    
    if centerInfo.pos.maxArea > threshArea
        center.pos.flag(rr) = true;
        center.pos.center(rr,:) = centerInfo.pos.center;
    end
end

for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) =roiData{rr}.filterInfo.kernelType;
end
%%
% subplot(2,2,2);
% quickViewOneKernel(zeros(size(roi.filterInfo.firstKernelAdjusted)),1);
% hold on
% plot(negCenter(2),negCenter(1),'b+');
% plot(posCenter(2),posCenter(1),'r+');
% plot(negContour(:,1),negContour(:,2),'b');
% plot(posContour(:,1),posContour(:,2),'r');
%%
MakeFigure;
for tt = 1:1:4
    roiUse = find(edgeType == tt & (kernelType == 1 | kernelType == 3));
    nRoiPlot = length(roiUse);
    subplot(2,2,tt);
    quickViewOneKernel_Smooth(zeros(size(roiData{1}.filterInfo.firstKernel.Adjusted)),1);
    if nRoiPlot == 0
        disp(['no good rois for type ',num2str(tt)]);
    else
        
        negCenterThisType = center.neg.center(roiUse,:);
        posCenterThisType = center.pos.center(roiUse,:);
        
        negFlagThisType = center.neg.flag(roiUse);
        posFlagThisType = center.pos.flag(roiUse);
        
        for ii = 1:1:nRoiPlot
            if negFlagThisType(ii)
                hold on
                plot(negCenterThisType(ii,2),negCenterThisType(ii,1),'+','color',DarkLightColor(2,:));
                hold off
            end
            if posFlagThisType(ii)
                hold on
                plot(posCenterThisType(ii,2),posCenterThisType(ii,1),'+','color',DarkLightColor(1,:));
                hold off
            end
            
            if posFlagThisType(ii) && negFlagThisType(ii)
                hold on
                plot([posCenterThisType(ii,2),negCenterThisType(ii,2)],[posCenterThisType(ii,1),negCenterThisType(ii,1)],'--','color',[0.5,0.5,0.5]);
                hold off
            end
        end
        title(titleStr{tt});
        
    end
end

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'','nFigSave',nFigSave,'fileType',figFileType);
end