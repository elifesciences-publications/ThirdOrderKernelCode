function maxConnectedArea  = kernelSelection_Second_CalculateMaximunConnectedRegion(kernel,varargin)
plotFlag = false;
threshZ = 3;
dtMax = 15;
tMax = 25;
direction = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
maxTauSquare = size(kernel,1);
maxTau = round(sqrt(maxTauSquare));
kernel = reshape(kernel,[maxTau,maxTau]);

kernelMap = false(size(kernel));
kernelMap(abs(kernel) > threshZ) = 1;

se = strel('disk',1);
kernelMapClose = imclose(kernelMap,se);

% build a kernelWindow.
% change the window...
% A = true(size(kernelMap));
% range = 15;
% maxTauUse = 25;
% A = triu(A,-range) & tril(A,range);
% kernelWindow = false(size(kernelMap));
% kernelWindow(1:maxTauUse,1:maxTauUse) = A(1:maxTauUse, 1:maxTauUse);

kernelWindow = GenKernelWindowMask_2o(maxTau,dtMax,tMax,direction);
kernelMap = kernelMap & kernelWindow;
kernelMapClose = kernelMapClose & kernelWindow;
% only concentrate on part of it... to reduce unneccessary noise? because
% it does not work vert well for second order kernel...
connArea = bwconncomp(kernelMapClose,4); % for the second order kernel, use 4? because it
nCon = connArea.NumObjects;
if nCon == 0
    maxConnectedArea = 0;
else
    numPixelPerRegion = zeros(nCon,1);
    for nn = 1:1:nCon
        numPixelPerRegion(nn) = length(connArea.PixelIdxList{nn});
    end
    
    [numPixelPerRegionLargest,whichArea] = sort(numPixelPerRegion,'descend');
    maxConnectedArea = numPixelPerRegionLargest(1);
end
if plotFlag
    disp(['the largest area is ' , num2str(maxConnectedArea)]);
    MakeFigure;
    subplot(3,3,1);
    quickViewOneKernel(kernel(:),2);
    subplot(3,3,4);
    quickViewOneKernel(kernelMap(:),2);
    subplot(3,3,5);
    quickViewOneKernel(kernelMapClose(:),2);
end
end
% it is not a good idea to do the subtraction and select kernel on that...
% just do whole kernel...




