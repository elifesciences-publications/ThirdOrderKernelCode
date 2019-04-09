function roiDataSelected = roiSelection_AllRoi(roiData,varargin)

method = 'prob';
threshToThrowAway = -110;
threshBarSigNum = 5;
targetedfilepath = [];
threshDSI = 0.4;
threshESI = 0.4;
threshLargeRoiSize = 25;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{ ',num2str(ii + 1) ,'};']);
end


nMultiBars = 20;
nRoi = length(roiData);
edgeType = zeros(nRoi,1);
filepath = cell(nRoi,1);
kernelType = zeros(nRoi,1);
ccWholeTrace  = zeros(nRoi,1);
roiSize = zeros(nRoi,1);
% plot a bunch of rois statistics, roi type indivdually..
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
    filepath{rr} = roi.stimInfo.filepath;
    kernelType(rr) = roi.filterInfo.kernelType;
    roiSize(rr) = sum(roi.stimInfo.roiMasks(:));
end

% recalculate DSI and ESI...
value = zeros(nRoi,8);
DSI = zeros(nRoi,1);
ESI = zeros(nRoi,1);
for rr = 1:1:nRoi;
    roi = roiData{rr};
    value(rr,:) = roi.typeInfo.value;
    edgeProLeft = max(value(rr,[1,3]));
    edgeRegRight = max(value(rr,[2,4]));
    DSI(rr) = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
    % do you want to compute another metrics
    
    % first, for the combined signal. % only possible for dirType = 1 or 2.
    lightValue = max(value(rr,1:2));
    darkValue = max(value(rr,3:4));
    ESI(rr) = (lightValue - darkValue)/(lightValue + darkValue);
    
end

% calculate zscore....


% MakeFigure
% subplot(2,2,1);
% h = histogram(firstKernelQuality(:));
% h.BinLimits = [-300,0];
% subplot(2,2,2);
% h = histogram(secondKernelQuality(:));

% barSelectedFirst = firstKernelQuality < -140;
% roiSelectedFirstKernel = sum(barSelectedFirst)' > 2;
%
% barSelectedSecond = secondKernelQuality < -300; % -300
% roiSelectedSecondKernel = sum(barSelectedSecond)' > 0;
%
% roiSelectedKernel = roiSelectedFirstKernel | roiSelectedSecondKernel ;
% roiSelected = roiSelectedSecondKernel;
%
%%
switch method
    case 'prob'
        roiSelectedByDSI = abs(DSI) > threshDSI;
        roiSelectedByESI = abs(ESI) > threshESI;
        roiSelected =  roiSelectedByDSI & roiSelectedByESI;% & roiSelectedByCC;
    case 'probOnlyDSI'
        roiSelected = abs(DSI) > threshDSI;
    case 'repeatability'
        roiSelected = ccWholeTrace > 0.1;
    case 'roiSize_TooLarge'
        roiSelected = roiSize <= threshLargeRoiSize;
    case 'wideRF'
        barSelected = firstKernelQuality < threshToThrowAway;
        barSigNum = sum(barSelected);
        roiSelected = barSigNum <= threshBarSigNum;
    case 'fly'
        nTargetedFile = length(targetedfilepath);
        killFlag = false(nRoi,1);
        for rr = 1:1:nRoi
            killFlagThis = false;
            for ii = 1:1:nTargetedFile
                % anyone of this happened. the flag will be one....
                if strcmp(filepath{rr},targetedfilepath{ii})
                    killFlagThis = true;
                end
            end
            killFlag(rr) = killFlagThis;
        end
        roiSelected = ~killFlag;
    case 'firstKernelMagnitude'
        % select only the largest 10 filters. good is good.
        roiSelected = false(nRoi,1);
        for tt = 1:1:4
            roiSelectedByType = edgeType == tt;
            firstKernelMagThisType = firstKernelMag(roiSelectedByType);
            firstKernelMagThisType = sort(firstKernelMagThisType,'descend');
            magThresh = firstKernelMagThisType(min([10,length(firstKernelMagThisType)]));
            roiSelectedByMag = firstKernelMag >= magThresh & roiSelectedByType;
            roiSelected = roiSelected | roiSelectedByMag;
            
        end
    case 'kernelType'
        roiSelected = kernelType >= 1;
    case 'firstKernelQuality'
    case 'kernelZMagnitude'
        roiSelected = firstKernelZMag > 1;
end

roiDataSelected = roiData;
roiDataSelected(~roiSelected) = [];
% FigPlot_DSI_ESI(roiDataSelected);
%
% ViewFirstOrderKernelsByType(roiDataSelected,'kernelExtractionMethod','OLS','typeSelected',[1,2,3,4]);
% ViewSecondOrderKernelsByType(roiDataSelected,'kernelExtractionMethod','reverse','typeSelected',[1,2,3,4]);
%
%
% roiDataSelected(~roiSelected) = [];
end