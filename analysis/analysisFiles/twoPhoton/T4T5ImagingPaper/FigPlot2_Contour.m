function FigPlot2_Contour(roiData,varargin)


threshPerim = 15;
[~,~,DarkLightColor] = FigPlot1ColorCode();
saveFigFlag = false;
MainName = 'Fig2_KernelContour';
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


contour.neg.flag = zeros(nRoi,1);
contour.pos.flag = zeros(nRoi,1);
contour.neg.c = cell(nRoi,1);
contour.pos.c = cell(nRoi,1);

for rr = 1:1:nRoi
    contourInfo = roiData{rr}.filterInfo.contourInfo;
    
    if contourInfo.neg.maxPerim > threshPerim
        contour.neg.flag(rr) = true;
        contour.neg.c{rr} = contourInfo.neg.c;
    end
    
    if contourInfo.pos.maxPerim > threshPerim
        contour.pos.flag(rr) = true;
        contour.pos.c{rr} = contourInfo.pos.c;
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
% plot(negc(2),negc(1),'b+');
% plot(posc(2),posc(1),'r+');
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
        
        negcThisType = contour.neg.c(roiUse);
        poscThisType = contour.pos.c(roiUse);
        
        negFlagThisType = contour.neg.flag(roiUse);
        posFlagThisType = contour.pos.flag(roiUse);
        
        for ii = 1:1:nRoiPlot
            if negFlagThisType(ii)
                hold on
                plot(negcThisType{ii}(:,1),negcThisType{ii}(:,2),'color',DarkLightColor(2,:));
                hold off
            end
            if posFlagThisType(ii)
                hold on
                plot(poscThisType{ii}(:,1),poscThisType{ii}(:,2),'color',DarkLightColor(1,:));
                hold off
            end
        end
        
        title(titleStr{tt});
    end
end
if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'','nFigSave',nFigSave,'fileType',figFileType);
end