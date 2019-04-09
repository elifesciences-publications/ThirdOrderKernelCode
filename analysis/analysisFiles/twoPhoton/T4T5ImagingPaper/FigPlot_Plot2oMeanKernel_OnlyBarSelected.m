function FigPlot_Plot2oMeanKernel_OnlyBarSelected(roiData,varargin)
% use the p value to determinw
pThresh = 0.01;
smoothFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nRoi = length(roiData)
for rr = 1:1:nRoi
    roiData{rr} = roiAnalysis_OneRoi_SecondDt(roiData{rr},'normKernelFlag',false,'normRoiFlag',false,'whichSecondKernel','Adjusted');
end

for rr = 1:1:nRoi
    roiData{rr}.filterInfo.secondKernel.dx1.barSelected =  roiData{rr}.filterInfo.secondKernel.dx1.ZTest.p < pThresh;
    roiData{rr}.filterInfo.secondKernel.dx2.barSelected =  roiData{rr}.filterInfo.secondKernel.dx2.ZTest.p < pThresh;
end
nType = 4;
typeBank = {'T4Pro','T4Reg','T5Pro','T5Reg'};
MakeFigure;
dt = roiData{1}.simu.sK.glider.dt;
for dx = 1:1:2
    [meanKernel,norm] = roiAnalysis_AverageFunction_OverFly(roiData,'whichValue','secondKernel','dx',dx,'kernelTypeUse',[1,2,3],...
        'normRoiFlag',false,'normKernelFlag',false);
    [meanGlider,norm] = roiAnalysis_AverageFunction_OverFly(roiData,'whichValue','glider','dx',dx,'kernelTypeUse',[1,2,3],...
        'normRoiFlag',false,'normKernelFlag',false);
    for tt = 1:1:nType
        subplot(4,5,dx + (tt - 1)*5);
        % averaged kernel over several bars, but not
        meanKernelThisType = mean(meanKernel{tt},2); % all 20 of the
        try
            if smoothFlag
                quickViewOneKernel_Smooth(meanKernelThisType, 2);
            else
                quickViewOneKernel(meanKernelThisType, 2);
            end
            title([typeBank{tt},' Mean 2o Kernel']);
            
            subplot(4,5,dx + 2 + (tt - 1)*5);
            % averaged kernel over several bars, but not
            meanGliderRespThisType = mean(meanGlider{tt},2); % all 20 of them
            stdGliderResp  = std(meanGlider{tt},1,2);
            semGliderResp = stdGliderResp./sqrt(norm(tt));
            maxValue = 0;
            PlotXY_Juyue(dt,meanGliderRespThisType,'errorBarFlag',true,'sem',semGliderResp ,'limPreSetFlag',false,'maxValue',maxValue * 1.5,...
                'colorMean',[1,0,0],'colorError',[1,0,0]);
           
        catch
        end
    end
end


end