function [RFCenter,xBest] =  AlignRoiByEdges(edgeResponsesMat, direction, dataRate, edgeVel, barWidth, numPhases)
% This code is adapted from Juyue's code to align linear RFs using the
% resopnses to edges compared to the response to a golden standard set of
% traces
% edgeResponsesMat is a time x ROIs matrix of edge responses (single edge
% type!)

% First check if the golden standard traces exist
edgeLength = size(edgeResponsesMat, 1);
try
    alignmentGoldTrace = load('AlignmentGoldTrace.mat');
catch err
    if strcmp(err.identifier, 'MATLAB:load:couldNotReadFile')
        error('Couldn''t find the gold traces for alignment as required for aligning by ROI traces--currently have no way to create the mat file either')
        % Once we figure out where the traces came from, the following code
        % is what you'd run(ish--still have to add stuff to load in the
        % traces, etc., might be a RunAnalysis call)
        relativeResponseTimesMat = computeOptimalDisplacement(edgeResponsesMat,edgeLength);
        relativeTime = computeOptimalRelativeResponseTimes(relativeResponseTimesMat);
    else
        rethrow(err)
    end
end


% save the trace edge and relativeTime to a place, load it everytime in the
% future.
[RFCenter,xBest] = AlignRois(edgeResponsesMat, direction, dataRate, edgeVel, barWidth, numPhases, edgeLength);
end

function responseTimesComparison = optimizeResponseTimes(testRelativeResponseTimes,dataRelativeResponseTimes)
    % We estimate a relative response times matrix,
    % dataRelativeResponseTimes, using a single relative response times
    % vector, testRelativeResopnseTimes, to minimize the two distances. The
    % benefit is that the single vector produces a matrix with equivalent
    % relative response times across all ROIs, whereas
    % dataRelativeResponseTimes might have slightly different relative
    % response times.
   
    [rowX,colX] = ndgrid(testRelativeResponseTimes,testRelativeResponseTimes);
    XTriu  = triu(colX - rowX);
    timeMatTriu = triu(dataRelativeResponseTimes);
    responseTimesComparison = sum(sum((XTriu - timeMatTriu).^2));

end

function optimalResponseTimeMat = computeOptimalRelativeResponseTimes(relativeResponseTimesMat)
    % you need a vector..
    testRelativeResponseTimes = relativeResponseTimesMat(1,:);
    responseTimesComparison = @(X)optimizeResponseTimes(X,relativeResponseTimesMat);
    tic
    optimalResponseTimeMat = fminsearch(responseTimesComparison,testRelativeResponseTimes);
    toc
    
end

% function relativeResponseTimesMat = roiAnalysis_AverageFirstKernel_alignTrace_relativeTimeMat(trace)
% % nRoi = length(trace);
% % relativeResponseTimesMat = zeros(nRoi,nRoi);
% % 
% % for ii = 1:1:nRoi
% %     for jj = ii+1:1:nRoi
% %         xab = MyXCorr_RelativePos(trace{ii},trace{jj});
% %         relativeResponseTimesMat(ii,jj) = xab;
% %         relativeResponseTimesMat(jj,ii) = - xab;
% %     end
% % end
% 
% relativeResponseTimesMat = computeOptimalDisplacement(edgeResponsesMat);
% 
% end

function optimalDisplacements = computeOptimalDisplacement(edgeResponseMatLinear,edgeLength, comparisonTrace)
    numROIs = size(edgeResponseMatLinear, 2); % Traces are down columns

    if nargin<3
        fullXCorr = true;
    else
        fullXCorr = false;
    end
    % We gotta take care of NaNs in the data. Online suggestion is to
    % nanmean subtract, nanstd normalize, and then set them to 0. This,
    % it's claimed, stops it from affecting xcorrs mu and sigma
    % calculation. Seems legit.
    edgeResponseMatLinear = bsxfun(@rdivide, bsxfun(@minus, edgeResponseMatLinear, nanmean(edgeResponseMatLinear)),nanstd(edgeResponseMatLinear));
    edgeResponseMatLinear(isnan(edgeResponseMatLinear)) = 0;
    
    % Find the optimal displacement by calculating the cross
    % correlation. xcorr does this between all columns, so the first
    % set of numROIs columns will provide us all alignment info to the
    % first ROI for the other ROIs
    if fullXCorr
        [edgeResponseXCorr, lags] = xcorr(edgeResponseMatLinear, 'coeff');
    else
        for edgeRespInd = 1:size(edgeResponseMatLinear, 2)
            [edgeResponseXCorr(:, edgeRespInd), lags] = xcorr(edgeResponseMatLinear(:, edgeRespInd), comparisonTrace, 'none');
        end
    end
    [~, optimalFrameDisplacementXCorr] = max(edgeResponseXCorr);
    optimalFrameDisplacement = lags(optimalFrameDisplacementXCorr);
    
    unwoundOptimalDisplacement = mod(optimalFrameDisplacement, edgeLength);
    negativeDisplacementCheck = unwoundOptimalDisplacement-edgeLength;
    unwoundOptimalDisplacement(abs(negativeDisplacementCheck)<unwoundOptimalDisplacement) = negativeDisplacementCheck(abs(negativeDisplacementCheck)<unwoundOptimalDisplacement);
    
    optimalDisplacements = reshape(unwoundOptimalDisplacement, numROIs, [])';
    


% a(isnan(a)) = 0;
% b(isnan(b)) = 0;
% 
% [corrValue,corrLag]= xcorr(a,b);
% [~,maxCorrInd] = max(corrValue);
% xab = corrLag(maxCorrInd); %if a is ahead of b, then xcorr (a,b) peak at -1.
% 
% 
% % first, makesure it is within one circle.
% 
% % 360 degree, 30 degree persecond, 13Hz(sampling rate);
% cycleN = (360/edgeVel) * dataRate ; % 
% halfCycleN = floor(cycleN/2);
% range = -(halfCycleN - 1):1:halfCycleN; % that is my idea range.... how do you put everything into that? % you could change that in the future if you like....
% % does it matter? just do it.
% if ~ismember(xab,range)
%     xab_temp = xab + 3 * cycleN; % get rid of negative values.
%     xab_temp = mod(xab_temp - 1,cycleN) + 1; % a is in 1 to cycleN now.
%     if xab_temp > halfCycleN
%         xab_temp = -(cycleN - xab_temp);
%     end
%     xab = xab_temp;
% end
end

function [RFCenter,xBest] = AlignRois(edgeResponsesMat, direction, dataRate, edgeVel, barWidth, numPhases, edgeLength)
% dirType = 1 align by left moving edge
% dirType = 2 align by right moving edge

% trace, edge response of the roi you want to align. 
% trace = [first presentation; second presentation];

% absolute_offset_left(right): depend where do you want to put the roi center.
% nMultiBars: how many bars in one period
% barWidth: width of a bar

% edgeVel: velocity of the moving edge
% recording_f: frequency of the recording.

absolute_offset_left = 0;
absolute_offset_right = 0;

alignmentGoldTrace = load('AlignmentGoldTrace');
switch direction
    case 'left' % left
        traceTemplate = alignmentGoldTrace.left.trace;
        relativeTimeTemplate = alignmentGoldTrace.left.relativeTime;
    case 'right' % right
        traceTemplate = alignmentGoldTrace.right.trace;
        relativeTimeTemplate = alignmentGoldTrace.right.relativeTime;
end
% judge it was left or right....
nTemplate = length(traceTemplate);
relativeTimeMat = zeros(size(edgeResponsesMat, 2), nTemplate);
for ii = 1:nTemplate
    relativeTimeMat(:, ii) = computeOptimalDisplacement(edgeResponsesMat,edgeLength,traceTemplate{ii});
end

% find the best alignment, which maintain the structure, but store the
% structure.
xBest = mean(relativeTimeMat' - repmat(relativeTimeTemplate, 1, size(relativeTimeMat, 1)));

xBest = -xBest; % because you want template VS trace, not trace VS template.


switch direction
    case 'left'
        RFCenter =  xBest * 1/dataRate * edgeVel  / barWidth;
        RFCenter = round(RFCenter - absolute_offset_left);
    case 'right'
        RFCenter =  -xBest * 1/dataRate * edgeVel / barWidth;
        RFCenter = round(RFCenter - absolute_offset_right);
end
RFCenter = RFCenter + numPhases * 4; % avoid negative numbers
RFCenter = mod(RFCenter - 1,numPhases) + 1;
end