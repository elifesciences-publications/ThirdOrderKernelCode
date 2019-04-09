function roiData = roiAnalysis_kernelSelectionPerFly(roiData,varargin)
selectionMethod_second = 'fullKernel'; %% 'onlyDirectionSelective'; %
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
tic
[firstKernelFlag, firstBarSelected,firstMaxConnectedAreaAll, firstMaxNoiseConnectedAreaAll, firstKernelZAll, firstKernelSmoothZAll]...
    = roiAnalysis_kernelSelection_First_BasedOnConnectedLargeZ(roiData);
toc
disp('first order kernel is classified');

tic
[secondKernelFlagDx1, secondBarSelectedDx1,secondMaxConnectedAreaAllDx1, secondMaxNoiseConnectedAreaAllDx1, secondKernelZAllDx1, secondKernelSmoothZAllDx1] ...
    = roiAnalysis_kernelSelection_Second_BasedOnConnectedLargeZ(roiData,'dx',1,'selectionMethod',selectionMethod_second);
toc
disp('dx = 1 second order kernel is classified');

tic
[secondKernelFlagDx2, secondBarSelectedDx2,secondMaxConnectedAreaAllDx2, secondMaxNoiseConnectedAreaAllDx2, secondKernelZAllDx2, secondKernelSmoothZAllDx2] ...
    = roiAnalysis_kernelSelection_Second_BasedOnConnectedLargeZ(roiData,'dx',2,'selectionMethod',selectionMethod_second);
toc
disp('dx = 2 second order kernel is classified');
secondKernelFlag = secondKernelFlagDx1 | secondKernelFlagDx2;

nRoi = length(roiData);
for rr = 1:1:nRoi
    if firstKernelFlag(rr) && ~secondKernelFlag(rr)
        kernelType = 1;
    elseif ~firstKernelFlag(rr) && secondKernelFlag(rr)
        kernelType = 2;
    elseif firstKernelFlag(rr) && secondKernelFlag(rr)
        kernelType = 3;
    else
        kernelType = 0;
    end
    
    % do not change them, only change the second one,
    roiData{rr}.filterInfo.kernelType = kernelType;
    
    
    roiData{rr}.filterInfo.firstKernel.quality = firstMaxConnectedAreaAll(rr);
    roiData{rr}.filterInfo.firstKernel.barSelected = firstBarSelected(:,rr);
    roiData{rr}.filterInfo.firstKernel.maxConnectedArea = firstMaxConnectedAreaAll(rr);
    roiData{rr}.filterInfo.firstKernel.maxNoiseConnectedArea = firstMaxNoiseConnectedAreaAll(:,rr);
    roiData{rr}.filterInfo.firstKernel.Z = firstKernelZAll(:,:,rr);
    roiData{rr}.filterInfo.firstKernel.smoothZ = firstKernelSmoothZAll(:,:,rr);
    
    roiData{rr}.filterInfo.secondKernel.dx1.quality = secondMaxConnectedAreaAllDx1(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx1.barSelected = secondBarSelectedDx1(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx1.maxConnectedArea = secondMaxConnectedAreaAllDx1(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx1.maxNoiseConnectedArea = secondMaxNoiseConnectedAreaAllDx1(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx1.Z = secondKernelZAllDx1(:,:,rr);
    roiData{rr}.filterInfo.secondKernel.dx1.smoothZ = secondKernelSmoothZAllDx1(:,:,rr);
    
    roiData{rr}.filterInfo.secondKernel.dx2.quality = secondMaxConnectedAreaAllDx2(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx2.barSelected = secondBarSelectedDx2(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx2.maxConnectedArea = secondMaxConnectedAreaAllDx2(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx2.maxNoiseConnectedArea = secondMaxNoiseConnectedAreaAllDx2(:,rr);
    roiData{rr}.filterInfo.secondKernel.dx2.Z = secondKernelZAllDx2(:,:,rr);
    roiData{rr}.filterInfo.secondKernel.dx2.smoothZ = secondKernelSmoothZAllDx2(:,:,rr);
end

% also check whether it is corresponding to real kernel...
quickViewKernelsFirst(firstKernelSmoothZAll(:,:,firstKernelFlag));
% firstKernelOriginal = zeros(size(firstKernelSmoothZAll));
% for rr = 1:1:nRoi
%     firstKernelOriginal(:,:,rr) = roiData{rr}.filterInfo.firstKernelOriginal;
% end
% quickViewKernelsFirst(firstKernelOriginal);
% quickViewKernelsFirst(firstKernelSmoothZAll);
%
%  to look at the second order being selected, use kernelShow
[nEle,nMultiBars,nRoi] = size(secondKernelSmoothZAllDx1);
kernelShow = reshape(secondKernelSmoothZAllDx1,[nEle,nMultiBars*nRoi]);
kernelShow = kernelShow(:,secondBarSelectedDx1(:));
quickViewKernelsSecond(kernelShow);

kernelShow = reshape(secondKernelSmoothZAllDx2,[nEle,nMultiBars*nRoi]);
kernelShow = kernelShow(:,secondBarSelectedDx2(:));
quickViewKernelsSecond(kernelShow);


end