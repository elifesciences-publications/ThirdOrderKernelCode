function FigPlot_Fig3_Supp_SVD(roiData,folderStr,saveFigFlag,varargin)
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

barWidth = roiData{1}.stimInfo.barWidth;
%% first order kernel
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
nType = length(typeStr);
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,'whichValue','firstKernel','kernelTypeUse',[1,2,3],...
    'normRoiFlag',false,'normKernelFlag',false);

% typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
% MakeFigure;
% for tt = 1:1:nType
%     kernel = mean(meanKernel{tt},3);
%     [U,S,V] = svd(kernel);
%     diagS = diag(S);
%     subplot(3,4,tt)
%     quickViewOneKernel_Smooth(kernel,1); % kernel.
%     title(typeStr{tt})
%     subplot(3,4,4 + tt)
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     subplot(3,4,8 + tt)
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     kernelWithout1Com = kernel - U(:,1)*diagS(1)*V(:,1)';
%     quickViewOneKernel_Smooth(kernelWithout1Com,1);
%     title('kenrel - first component');
% end
% if saveFigFlag
%     MySaveFig_Juyue(gcf,'1o_Kernel_SVDT4ProRegT5ProReg','','nFigSave',nFigSave,'fileType',figFileType);
% end


% flipMeanKernel = cell(2,1);
% for ii = 1:1:2
%     kernelPro = mean(meanKernel{1 + 2 *(ii - 1)},3);
%     kernelReg = mean(meanKernel{2 + 2 *(ii - 1)},3);
%     flipMeanKernel{ii} = kernelPro +  fliplrKernel(kernelReg,1);
% end
% % this format is a bad presention.
% 
% titleStr = {'T4','T5'};
% MakeFigure;
% for ii = 1:1:2
%     kernel = flipMeanKernel{ii};
%     [U,S,V] = svd(kernel);
%     diagS = diag(S);
%     subplot(3,2,1 + (ii - 1));
%     quickViewOneKernel_Smooth(kernel,1);
%     title(titleStr{ii})
%     subplot(3,2,3 + (ii - 1));
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     subplot(3,2,5 + (ii - 1));
%     kernelWithout1Com = kernel - U(:,1)*diagS(1)*V(:,1)';
%     quickViewOneKernel_Smooth(kernelWithout1Com,1);
%     title('kenrel - first component');
% end
% if saveFigFlag
%     MySaveFig_Juyue(gcf,'1o_Kernel_SVDT4T5','' ,'nFigSave',nFigSave,'fileType',figFileType);
% end
flipMeanKernel = cell(2,1);
for ii = 1:1:2
    kernelPro = mean(meanKernel{1 + 2 *(ii - 1)},3);
    kernelReg = mean(meanKernel{2 + 2 *(ii - 1)},3);
    flipMeanKernel{ii} = kernelPro +  fliplrKernel(kernelReg,1);
end
% this format is a bad presention.

titleStr = {'T4','T5'};
MakeFigure;
for ii = 1:1:2
    % now second order kernel. only first order...
    kernel = flipMeanKernel{ii};
    [U,S,V] = svd(kernel);
    diagS = diag(S);
    subplot(2,5,5 * (ii - 1) + 1)
    quickViewOneKernel_Smooth(kernel,1);
    title(titleStr{ii})
    
    subplot(2,5,5 * (ii - 1) + 2)
    scatter(1:5,diagS(1:5).^2/sum(diagS.^2),'filled');
    title('Singular Values');
    
    subplot(2,5,5 * (ii - 1) + 3)
    quickViewOneKernel_Smooth(U(:,1)*diagS(1)*V(:,1)',1,'colorbarFlag',false,'labelFlag',false);
    title('singular vectors 1th');
 
    subplot(2,5,5 * (ii - 1) + 4)    
    kernelWithout1Com = kernel - U(:,1)*diagS(1)*V(:,1)';
    quickViewOneKernel_Smooth(kernelWithout1Com,1);
    title('kenrel - first component');
    
    subplot(4,5,10 * (ii - 1) + 5);
    plot(U(:,1));
    title('1th component - time');
    subplot(4,5,10 * (ii - 1) + 10);
    plot(V(:,1));
    title('1th component - space');
   
end
if saveFigFlag
    MySaveFig_Juyue(gcf,'1o_Kernel_SVDT4T5','' ,'nFigSave',nFigSave,'fileType',figFileType);
end


%
% flipMeanKernel = cell(2,1);
% for ii = 1:1:2
%     kernelPro = mean(meanKernel{1 + 2 *(ii - 1)},3);
%     kernelReg = mean(meanKernel{2 + 2 *(ii - 1)},3);
%     flipMeanKernel{ii} = kernelPro +  fliplrKernel(kernelReg,1);
% end
% % this format is a bad presention.
% 
% titleStr = {'T4','T5'};
% MakeFigure;
% for ii = 1:1:2
%     kernel = flipMeanKernel{ii};
%     [U,S,V] = svd(kernel);
%     diagS = diag(S);
%     subplot(4,4,8 * (ii - 1) + 1)
%     quickViewOneKernel_Smooth(kernel,1);
%     title(titleStr{ii})
%     subplot(4,4,8 * (ii - 1) + 2)
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     subplot(4,4,8 * (ii - 1) + 3)
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     kernelWithout1Com = kernel - U(:,1)*diagS(1)*V(:,1)';
%     quickViewOneKernel_Smooth(kernelWithout1Com,1);
%     title('kenrel - first component');
%     subplot(4,4,8 * (ii - 1) + 4)
%     kernelWithout12Com = kernelWithout1Com - U(:,2)*diagS(2)*V(:,2)';
%     quickViewOneKernel_Smooth(kernelWithout12Com,1);
%     title('kernel - second component');
% 
%     subplot(8,4,16 * (ii - 1) + 9);
%     plot(U(:,1));
%     title('1th component - time');
%     subplot(8,4,16 * (ii - 1) + 13);
%     plot(V(:,1));
%     title('1th component - space');
%     subplot(4,4,8 * (ii - 1) + 6)
%     quickViewOneKernel_Smooth(U(:,1)*diagS(1)*V(:,1)',1,'colorbarFlag',false,'labelFlag',false);
%     title('singular vectors 1th');
% 
%     subplot(8,4,16 * (ii - 1) + 11);
%     plot(U(:,2));
%     title('2nd component - time');
%     subplot(8,4,16 * (ii - 1) + 15);
%     plot(V(:,2));
%     title('2nd component - space');
%     subplot(4,4,8 * (ii - 1) + 8)
%     quickViewOneKernel_Smooth(U(:,2)*diagS(2)*V(:,2)',1,'colorbarFlag',false,'labelFlag',false);
%     title('singular vectors 2nd');
% end
% if saveFigFlag
%     MySaveFig_Juyue(gcf,'1o_Kernel_SVDT4T5','' ,'nFigSave',nFigSave,'fileType',figFileType);
% end

% typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'}
% for tt = 1:1:4
%     MakeFigure;
%     kernel = mean(meanKernel{tt},3);
%     [U,S,V] = svd(kernel);
%     diagS = diag(S);
%     subplot(2,4, 1)
%     quickViewOneKernel_Smooth(kernel,1);
%     title(typeStr{tt})
%     subplot(2,4,2)
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     subplot(2,4,3)
%     scatter(1:5,diagS(1:5),'filled');
%     title('Singular Values');
%     kernelWithout1Com = kernel - U(:,1)*diagS(1)*V(:,1)';
%     quickViewOneKernel_Smooth(kernelWithout1Com,1);
%     title('kenrel - first component');
%     subplot(2,4, 4)
%     kernelWithout12Com = kernelWithout1Com - U(:,2)*diagS(2)*V(:,2)';
%     quickViewOneKernel_Smooth(kernelWithout12Com,1);
%     title('kernel - second component');
%
%     subplot(4,4, 9);
%     plot(U(:,1));
%     title('1th component - time');
%     subplot(4,4, 13);
%     plot(V(:,1));
%     title('1th component - space');
%     subplot(2,4,6)
%     quickViewOneKernel_Smooth(U(:,1)*diagS(1)*V(:,1)',1,'colorbarFlag',false,'labelFlag',false);
%     title('singular vectors 1th');
%
%     subplot(4,4,11);
%     plot(U(:,2));
%     title('2nd component - time');
%     subplot(4,4,15);
%     plot(V(:,2));
%     title('2nd component - space');
%     subplot(2,4,8)
%     quickViewOneKernel_Smooth(U(:,2)*diagS(2)*V(:,2)',1,'colorbarFlag',false,'labelFlag',false);
%     title('singular vectors 2nd');
%     if saveFigFlag
%     MySaveFig_Juyue(gcf,'1o_Kernel_SVDT4ProRegT5ProReg',typeStr{tt} ,'nFigSave',nFigSave,'fileType',figFileType);
% end
cd(currFolder)
end