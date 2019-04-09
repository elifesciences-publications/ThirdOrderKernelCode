function [meanKernelFourType,meanKernelFourTypeComb] = Kernel2o_SVD_Utils_GetMeanKernel(roiData)
dx = 1;
[meanKernel,~] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','secondKernel','dx',dx,'kernelTypeUse',[1,2,3],...
    'normRoiFlag',false);
barUseBank = {[10,11,12],[8,9,10],[10,11,12],[8,9,10]};
nType = 4;
meanKernelFourType = cell(nType,1);
meanKernelFourTypeComb = cell(nType,1);
for tt = 1:1:nType
    % averaged kernel over several bars
    meanKernelThisType = mean(meanKernel{tt},3);
    meanKernelOverBars = mean(meanKernelThisType(:,barUseBank{tt}),2);
    meanKernelFourType{tt} = meanKernelOverBars;
    if tt == 1 || tt == 3
        meanKernelFourTypeComb{tt} = meanKernelOverBars;
    else
        meanKernelFourTypeComb{tt} =  fliplrKernel(meanKernelOverBars,2);
    end
    
end
meanKernelFourType = cell2mat(meanKernelFourType');
meanKernelFourTypeComb = cell2mat(meanKernelFourTypeComb');
meanKernelFourTypeComb = mean(meanKernelFourTypeComb,2);
end