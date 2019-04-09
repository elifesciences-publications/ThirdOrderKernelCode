function FigPlot_Fig3_Supp_2oSVD(roiData,folderStr,saveFigFlag,varargin)
smoothFlag = false;
figFileType = {'fig'};
nFigSave = 1;
nType = 4;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
currFolder = pwd;

try
    cd(folderStr)
catch
    mkdir(folderStr);
    cd(folderStr)
end

%% first order kernel
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
[meanKernelFourType,meanKernelComb] = Kernel2o_SVD_Utils_GetMeanKernel(roiData);
Kernel2o_SVD(meanKernelComb,'mean');
if saveFigFlag
    MySaveFig_Juyue(gcf,'2o_KernelMean_SVD','' ,'nFigSave',nFigSave,'fileType',figFileType);
end

for tt = 1:1:nType
    Kernel2o_SVD(meanKernelFourType(:,tt),typeStr{tt});
    if saveFigFlag
        MySaveFig_Juyue(gcf,'2o_Kernel_SVD',typeStr{tt} ,'nFigSave',nFigSave,'fileType',figFileType);
    end
end
cd(currFolder)

end
