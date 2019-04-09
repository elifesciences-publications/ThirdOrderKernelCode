function [edgeTraceFinal,roiMaskFinal,objNameFinal,objNameNextFinal,outArguments] ...
    = MyHHCA_Utils_ClusterInOneGrid(edgeTraceInit,roiMaskInit,objNameInit,objNameNextInit,varargin)

testing_mode = false;
plotFlag = false;
smoothEdgeFlag = true;
% lambda = 0.1;
%
% K = 2;
% corrThresh = 0;
% distThresh = +inf;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

N = length(objNameInit);
[nPixelVer,nPixelHor] = size(roiMaskInit);
% calculate the centerOfMassInit, everyTime...
% if roiMaskInit, every object has only 1 pixel
if (length(unique([0;roiMaskInit(:)])) - 1) == length(find(roiMaskInit(:) > 0));
    % there is only one pixel
    centerOfMassInit = zeros(2,N);[centerOfMassInit(1,:),centerOfMassInit(2,:)] = ind2sub([nPixelVer,nPixelHor],find(roiMaskInit > 0));
else
    centerOfMassInit = MyHHCA_Utils_CalculateCenterOfMassFromRoiMaskNum(roiMaskInit,objNameInit);
end
distVecInit = pdist(centerOfMassInit')'; % slower than corr, not clearer why. 4 minutes. without gpu.
if smoothEdgeFlag
    edgeTraceSmoothInit = smooth(edgeTraceInit(:),5); edgeTraceSmoothInit = reshape(edgeTraceSmoothInit ,size(edgeTraceInit));
    edgeTraceForCorrInit = edgeTraceSmoothInit;
else
    edgeTraceForCorrInit = edgeTraceInit;
end
corrMatInit = corr( edgeTraceForCorrInit); % only 7 seconds! cool!

% initiation for clustering method.
edgeTrace = edgeTraceInit;
edgeTraceForCorr = edgeTraceForCorrInit;
roiMask = roiMaskInit;
centerOfMass = centerOfMassInit;
corrVec = corrMatInit(tril(true(N,N),-1));
distVec = distVecInit;
objectName = objNameInit;
objectNameNext = objNameNextInit;

% you should be able to visualize what is happening here, for small
% scale...
clusteredObjectRecord = cell(N,1);
edgeClusterRecord = cell(N,1);
roiMaskClusterRecord = cell(N,1);
clusteredObjectRecord{1}.objectName = objectName;
edgeClusterRecord{1} = edgeTrace;
roiMaskClusterRecord{1} = roiMask;
% something wrong here. you have to debug your code, to figure out
stopFlag = false;
ii = 1;
if testing_mode
    testing_corrVec = cell(N,1);
end
while ~stopFlag
    % for ii = 1:1:nRound
    [edgeTrace, edgeTraceForCorr ,roiMask,centerOfMass,corrVec,distVec,objectName,objectNameNext,whichCombined,stopFlag] ...
        = MyHHCA_Untils_CombineTwoRoi...
        (edgeTrace, edgeTraceForCorr, roiMask, centerOfMass, corrVec, distVec, objectName,objectNameNext, ...
        varargin{:});
    % you will remember a lot of things.
    if testing_mode
        testing_corrVec{ii} = corrVec;
    end
    clusteredObjectRecord{ii + 1}.objectName = objectName;
    clusteredObjectRecord{ii}.which = whichCombined;
    edgeClusterRecord{ii + 1} = edgeTrace;
    roiMaskClusterRecord{ii + 1} = roiMask;
    ii = ii + 1;
    
    % from here, you can check your distribution. for different rounds.
    % how can you collect all of them?
    
    % extraVouts? how does that work?
end
nRoundUse = ii - 1 ;

edgeTraceFinal = edgeTrace;
% edgeTraceSmoothFinal = edgeTraceSmooth;
roiMaskFinal = roiMask;
objNameFinal = objectName;
% look at the last name in roiMask, or last name in the
objNameNextFinal = objectNameNext;
% corrVecFinal = corrVec;
% centerOfMassFinal = centerOfMass;
% distVecFinal = distVec;
if testing_mode
    outArguments.testing_corrVec = testing_corrVec(1:nRoundUse);
else
    outArguments = [];
end


if plotFlag
    if  ~isempty(clusteredObjectRecord{1}.which)
        MakeFigure;
        for ii = 1:1:nRoundUse
            whichCombine = clusteredObjectRecord{ii}.which;
            roiMask = roiMaskClusterRecord{ii};
            edgeTrace = edgeClusterRecord{ii};
            objName = clusteredObjectRecord{ii}.objectName;
            nGroup = length(whichCombine);
            for nn = 1:1:nGroup
                MyHHCA_Utils_Visulization_ShowCombinationAndTrace(roiMask,edgeTrace,whichCombine{nn},objName)
            end
        end
    end
end
