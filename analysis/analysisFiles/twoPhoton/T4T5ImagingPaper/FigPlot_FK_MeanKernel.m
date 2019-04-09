function meanKernel = FigPlot_FK_MeanKernel(roiData,varargin)
saveFigFlag = false;
MainName = 'Fig2';
nFigSave = 3;
figFileType = {'fig','eps','png'};
kernelOrZ = 'kernel';
typeStr ={'Progressive T4','Regressive T4','Progressive T5','Regressive T5'};
cutFilterFlag = false;
normRoiFlag = true;
smoothFlag = false;
aveBy = 'fly';
kernelTypeUse = [1,2,3];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

barWidth = roiData{1}.stimInfo.barWidth;
% plot the averaged filter...
% calculate mean filter four each type..
% roiData_Aligned  = roiAnalysis_AlignedKernelCenter_Main(roiData);
switch aveBy
    case 'fly'
        
        [meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','firstKernel','kernelTypeUse',kernelTypeUse,...
            'normRoiFlag',normRoiFlag);
    case 'roi'
        [meanKernel,norm] = roiAnalysis_AverageFunction_OverRoi_IndividualBars(roiData,'whichValue','firstKernel','kernelTypeUse',kernelTypeUse,...
            'normRoiFlag',normRoiFlag);
end
% you also wants to know, howmany rois is there...
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
numStat = roiAnalysis_FlyRoiKernelStat(roiData);

MakeFigure;
for tt = 1:1:4
    subplot(2,2,tt);
    meanKernelThisType = mean(meanKernel{tt},3);
    try
        if smoothFlag
            quickViewOneKernel_Smooth(meanKernelThisType,1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag',cutFilterFlag,'barRange',[5:15],'timeRange',1:45,...
                'limPreSetFlag',false,'maxValue',0);
        else
            quickViewOneKernel(meanKernelThisType,1,'labelFlag',true,'posUnit',barWidth,'timeUnit',1/60,'cutFilterFlag',cutFilterFlag,'barRange',[5:15],'timeRange',1:45,...
                'limPreSetFlag',false,'maxValue',0);
        end
        %     text([1],20,{'bar #'});
        %     text([8:12],ones(5,1) * 20,{'8','9','10','11','12'},'HorizontalAlignment','center');
        
        switch aveBy
            case 'fly'
                titleStrThisType = {[typeStr{tt},' nfly:', num2str(norm(tt)),' nRoi:', num2str(numStat.nFirstKernelPerType(tt))]};
            case 'roi'
                titleStrThisType = {[typeStr{tt},' nRoi:', num2str(numStat.nFirstKernelPerType(tt))]};
                
        end
        title(titleStrThisType);
    catch
    end
end
if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_mean','nFigSave',nFigSave,'fileType',figFileType);
end
end