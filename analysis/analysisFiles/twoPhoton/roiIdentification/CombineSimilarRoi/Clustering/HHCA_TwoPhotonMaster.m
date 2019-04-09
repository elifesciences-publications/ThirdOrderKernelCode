function ROI = HHCA_TwoPhotonMaster(Z)
% Attempt to segment regions of the image by edge selectivity. This assumes
% that all the edge types have been presented (variable edgeTypes). Note
% that this script requires imgFrame!
roiMinPixNumber = 1;
loadFlexibleInputs(Z);
edgeTypes = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge'};
nEdges = length(edgeTypes); % the edgeTypes will be hard coded??
imgSize = size(Z.grab.imgFrames);

%% househould.
% infer the window mask from the roiMask.
roiMaskfile = [filename,'/','savedAnalysis/'];
dataInfo = dir([roiMaskfile,'HHCARoiExtraction*.mat']);
dataNameAll = {dataInfo.name};
[~, newestInd] = max(cellfun(@(fname) datenum(fname(regexp(fname, '\d+_\d+_\d+', 'start'):regexp(fname, '\d+_\d+_\d+', 'end')), 'dd_mm_yy'),dataNameAll));
dataName = [roiMaskfile,dataInfo(newestInd).name];
% if there are two of them, chose the lastest one
load(dataName);
roiMask_ICA_InWindow = lastRoi.roiMaskInitial;
%% infer what is the windmask used...
imageSize = imgSize(1:2);
Z.grab.windowMask = ICA_DFOVERF_Untils_InferWindowMask(roiMask_ICA_InWindow ,imageSize);
% convert the smaller roiMask backinto large one.
windMask = Z.grab.windowMask;
roiMask_ICA = ICA_DFOVERF_Untils_RoiMaskCordChange(windMask,roiMask_ICA_InWindow,imageSize);

% convert runAnalysis format into twoPhotonMaster format.
nRoi = max(max(roiMask_ICA));
roiMask_ICA_BW = zeros([size(roiMask_ICA), nRoi]);
for rr = 1:1:nRoi
    roiMask_ICA_BW(:,:,rr) = roiMask_ICA == rr;
end
roiMask_ICA = roiMask_ICA_BW;

% MakeFigure;
% quickViewRois(roiMask_ICA_BW);
% roiMask_ICA = roiMask_ICA_BW;
% put the roiMask_ICA into the format I like...
% make sure the roi is in the window.

% Holly's code to remove very small rois. But, only eliminate very small rois
% It is dangerous to hard code this 3 here....but it is okay....
nRoiOrig = size(roiMask_ICA,3);
remove = zeros(nRoiOrig,1);
for q = 1:nRoiOrig
    if sum(sum(roiMask_ICA(:,:,q))) < roiMinPixNumber
        remove(q) = 1;
    end
end
remove = ( remove ~= 0 );
roiMask_ICA(:,:,remove) = []; % get rid of the roi which is empty

if isfield(Z.params,'tinyBckgIsTheLastRoiFlag') && (Z.params.tinyBckgIsTheLastRoiFlag)
    bkgdMaskTiny = roiUtils_TinyConnectedBg( Z );
    roiMask_ICA = cat(3,roiMask_ICA,bkgdMaskTiny); % put the background.
end

bkgdMask = roiUtils_dimConnectedBg( Z );
roiMask_ICA = cat(3,roiMask_ICA,bkgdMask); % put the background.

ROI.roiMasks = roiMask_ICA;

%
% MakeFigure;
% imagesc(roiMask_ICA_F);
% MakeFigure;
% imagesc(roiMask_ICA_DFOverF);
% MakeFigure;
% imagesc(double(roiMask_ICA_DFOverF > 0) - double(roiMask_ICA_F > 0) );


end