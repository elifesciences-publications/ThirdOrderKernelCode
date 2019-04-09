clear
clc
roiData = getData_Juyue();
roiData = roiSelection_AllRoi(roiData);
roiData = roiAnalysis_ChangeFilterDirection(roiData,'method','corChangeAndCentered');
roiData = roiAnalysis_CorrectionWrongTrace(roiData);
% get all the left responsive signal. 
nRoi = length(roiData);
edgeType = zeros(nRoi,1);

for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
end

edgeTypeStim = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeTypeStim(rr) = roi.prob.PStim.edgeType;
end

leftRoi = edgeTypeStim == 1 | edgeTypeStim == 3;
rightRoi = edgeTypeStim == 2| edgeTypeStim == 4;

% first, consider left one...
roiSelectedLeft = leftRoi ;
roiSelectedRight = rightRoi;

roiDataUse = roiData;
roiDataUse(~roiSelectedLeft) = [];
roiData = roiDataUse;
% roiDataUse contains all the left guy.

% collect all the trace?
nRoi = length(roiData);
roiUse = [19,25,7,9,21,8,12];
for ii = 1:1:length(roiUse)
    rr = roiUse(ii);
%      PlotOneRoi_Trace(roiData{rr},false,'cord','stim');
     PlotOneRoi_KernelAndTrace(roiData{rr},false);
end
% these trace looks pretty reasonable.
% how do you plot the edge response and the square wave response together.
% write a function which would draw the edge trace and square trace at the
% same time.
% for each roi, according to it stimulus, get th 
probTrace = cell(nRoi,1); % I will cantenate.. presumably, it is all left selective guy...
edgeTypeStim = zeros(nRoi,1);
dirType = zeros(nRoi,1);
dirType(:) = 1; % all of them are left.
% the trace could be lengthen...
% the square response would also be considered...

for rr= 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.prob.PStim.edgeType;
    probTrace{rr} = roi.prob.PStim.trace;
    % from edgeType, decide which square type to use...
end

traceEdge = cell(nRoi,1);
for rr = 1:1:nRoi
    traceEdge{rr} = [probTrace{rr}{1,edgeType(rr)};probTrace{rr}{2,edgeType(rr)}];
end
relativeTimeMat_Edge = roiAnalysis_AverageFirstKernel_alignTrace_relativeTimeMat(traceEdge);


% MakeFigure;
% % maxValue = max(max(abs([relativeTimeMat_Edge(:),relativeTimeMat_EdgeAndSquare(:),relativeTimeMat_MeanEdgeAndSqaure(:)])));
% subplot(2,2,1);
% imagesc(relativeTimeMat_Edge);
% colorbar
% subplot(2,2,2);
% imagesc(relativeTimeMat_EdgeAndSquare);
% colorbar
% subplot(2,2,3);
% imagesc(relativeTimeMat_MeanEdgeAndSqaure);
% colorbar

subplot(2,2,4)
% from the probTrace, you can decide 
relativeTimeMat = relativeTimeMat_Edge;
relativeTime = roiAnalysis_AverageFirstKernel_fbestRelativeTime(relativeTimeMat);
% for left stimulus,
barWidth = roi.stimInfo.barWidth;
relativeBarPos = relativeTime * 1/13 *30 / barWidth; % 1 timepoint is 1/13*30 around 2.6 degree. and 5 degree bar.
barCenterProb = round(relativeBarPos - 4.52); % for the left .... cool....
barCenterProb = barCenterProb + 60;
barCenterProb = mod(barCenterProb - 1,20) + 1;

% before you continue. just plot the filter and look at the result.

firstKernelAll = zeros(60,20,nRoi);
for rr = 1:1:nRoi
    roi = roiData{rr};
    firstKernelAll(:,:,rr) = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfoNew.firstKernelOriginal,barCenterProb(rr));
end

for rr = 1:1:nRoi
    MakeFigure;
    quickViewOneKernel_Smooth(firstKernelAll(:,:,rr),1);
end
% you get one roi in. and you fit your roi with all these different guy and
% try to get a new one out. that is damn cool......
% for rr = 1:1:nRoi
%     roiData{rr}.barCenterProb = barCenterProb(r)
% end

% You need a absolute value...for those bars...
% before doing that. just plot the estimated one 
barCenterBarQuality = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
barCenterBarQuality(rr) = roiAnalysis_FindFirstKernelCenter(roi,'method','barQuality');
end
barCenterBarQuality(barCenterBarQuality > 8) = barCenterBarQuality(barCenterBarQuality > 8) - 20;
MakeFigure;
scatter(barCenterBarQuality,relativeBarPos);
% you want to fit an equation to this data set yourself.
% you should get rid of those bad points. and get a more accurate
% estimation.

x = barCenterBarQuality;
y = relativeBarPos';
a = 1;
% b is the number to want to fit...
b = mean(a * x - y)
hold on

scatter(x, a * x + b,'r+');

find((x == 1) & y < -4)
find( x == 6)
find(x == 3 & y < -4)
find(x == -10 & y > -5)
find(x == -8 & y > 15)

% ajustment of x and y
x(12) = x(12) + 20;
roiUse = [19,25,7,9,21,8];
x(roiUse) = [];
y(roiUse) = [];

MakeFigure;
scatter(y,x);
hold on
scatter(y,round(y - 4.52),'g+')


% all of them are good...
left.trace = traceEdge;
left.relativeTime = relativeTime';
save('AlignmentGoldTrace','left','-v7.3');








