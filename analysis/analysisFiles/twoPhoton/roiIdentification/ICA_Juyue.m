function ROI = ICA_Juyue(Z)
% Attempt to segment regions of the image by edge selectivity. This assumes
% that all the edge types have been presented (variable edgeTypes). Note
% that this script requires imgFrame!
roiMinPixNumber = 1;
loadFlexibleInputs(Z);
edgeTypes = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge'};
nEdges = length(edgeTypes); % the edgeTypes will be hard coded??
imgSize = size(Z.grab.imgFrames);

%% househould.
bkgdMask = roiUtils_dimConnectedBg( Z );
Z.grab.windowMask = Z.grab.windowMask .* ~bkgdMask;

%% get the image for ICA subtraction
imgFrames = Z.grab.imgFrames;
meanImg = mean(imgFrames,3);
[~,roiMask_ICA_F,~] = IcaRoiExtraction(meanImg,imgFrames);
roiMask_ICA = roiMask_ICA_F;
% change the format of roimaks;
nRoi = max(max(roiMask_ICA));
roiMask_ICA_BW = zeros([size(roiMask_ICA), nRoi]);
for rr = 1:1:nRoi
    roiMask_ICA_BW(:,:,rr) = roiMask_ICA == rr;
end
roiMask_ICA = roiMask_ICA_BW;
%% window
for rr = 1:1:nRoi
    roiMask_ICA(:,:,rr) = roiMask_ICA(:,:,rr) & Z.grab.windowMask;    
end

% MakeFigure;
% quickViewRois(roiMask_ICA_BW);
% roiMask_ICA = roiMask_ICA_BW;
% put the roiMask_ICA into the format I like...
% make sure the roi is in the window.

roiMask_ICA_InWindow = roiMask_ICA;

% Holly's code to remove very small rois. But, only eliminate very small rois
% It is dangerous to hard code this 3 here....but it is okay....
nRoiOrig = size(roiMask_ICA_InWindow,3);
remove = zeros(nRoiOrig,1);
for q = 1:nRoiOrig
    if sum(sum(roiMask_ICA_InWindow(:,:,q))) < roiMinPixNumber
        remove(q) = 1;
    end
end
remove = ( remove ~= 0 );
roiMask_ICA_InWindow(:,:,remove) = []; % get rid of the roi which is empty
roiMask_ICA_InWindow = cat(3,roiMask_ICA_InWindow,bkgdMask); % put the background.

ROI.roiMasks = roiMask_ICA_InWindow;

% 
% MakeFigure;
% imagesc(roiMask_ICA_F);
% MakeFigure;
% imagesc(roiMask_ICA_DFOverF);
% MakeFigure;
% imagesc(double(roiMask_ICA_DFOverF > 0) - double(roiMask_ICA_F > 0) );


end