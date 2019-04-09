clear
clc
roiData = getData_Juyue();
roiDataT4T5 = roiData;
roiData = getData_Juyue_T4();
roiDataT4 = roiData;
roiData = [roiDataT4;roiDataT4T5];
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
roiDataUse(~roiSelectedRight) = [];
roiData = roiDataUse;
% roiDataUse contains all the left guy.

% collect all the trace?
nRoi = length(roiData);
% you can get rid of bad traces first.

% roiBadTrace = [1,28,3,5];
% roiData([roiBadTrace]) = [];
for rr = 1:1:nRoi;
%     rr = roiUse(ii);
    PlotOneRoi_Trace(roiData{rr},false,'cord','stim');
%      PlotOneRoi_KernelAndTrace(roiData{rr},false);
end
% roiBadTrace = [2,3,25,26,28,29];
% roiData([roiBadTrace]) = [];
% 
% roiBadTrace = [3,5,6,17,19,20,22];
% roiData([roiBadTrace]) = [];

% roiBadTrace = [12,14,15];
% roiData([roiBadTrace]) = [];
% 
% roiBadTrace = [1,23];
% roiData([roiBadTrace]) = [];

% roiBadTrace = [11];
nRoi = length(roiData);
probTrace = cell(nRoi,1); % I will cantenate.. presumably, it is all left selective guy...
edgeTypeStim = zeros(nRoi,1);
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

MakeFigure;
imagesc(relativeTimeMat_Edge);
colorbar

relativeTimeMat = relativeTimeMat_Edge;
relativeTime = roiAnalysis_AverageFirstKernel_fbestRelativeTime(relativeTimeMat);
barWidth = roi.stimInfo.barWidth;
relativeBarPos = -relativeTime * 1/13 *30 / barWidth; % 1 timepoint is 1/13*30 around 2.6 degree. and 5 degree bar.
barCenterProb = round(relativeBarPos + 5.4891); % for the left .... cool....
% because it is right eye. the default center would be set to 10;
barCenterProb = barCenterProb + 1; % not very understand ...
barCenterProb = barCenterProb + 60;
barCenterProb = mod(barCenterProb - 1,20) + 1;

% before you continue. just plot the filter and look at the result.

firstKernelAll = zeros(60,20,nRoi);
for rr = 1:1:nRoi
    roi = roiData{rr};
    firstKernelAll(:,:,rr) = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfoNew.firstKernelOriginal,barCenterProb(rr));
end

for rr = 1:1:5
    MakeFigure;
    quickViewOneKernel_Smooth(firstKernelAll(:,:,rr),1);
end

barCenterBarQuality = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
barCenterBarQuality(rr) = roiAnalysis_FindFirstKernelCenter(roi,'method','barQuality');
end
barCenterBarQuality(barCenterBarQuality >17) = barCenterBarQuality(barCenterBarQuality >17) - 20;
relativeBarPos(relativeBarPos > 15) = relativeBarPos(relativeBarPos > 15) - 20;
MakeFigure;
scatter(barCenterBarQuality,relativeBarPos);

% you want to fit an equation to this data set yourself.
% you should get rid of those bad points. and get a more accurate
% estimation.

x = barCenterBarQuality;
y = relativeBarPos';


find((x == 2) & y < -5)
find( x == 5 & y < -5)
find(x == 6 & y < 1)
find(x == 2 & y > 5)
find(x == 2 )
find(x == -2)
find

MakeFigure;
scatter(y,x);
hold on 
a = 1;
% b is the number to want to fit...
b = mean(a * x - y);
b = 5.4891;
scatter(y,y + b,'r+')
hold off
% just get rid of those kernel

hold on

scatter(x, a * x + b,'r+');

MakeFigure;
scatter(y,x);
hold on
scatter(y,round(y - 4.52),'g+')


% all of them are good...
right.trace = traceEdge;
right.relativeTime = relativeTime';
save('AlignmentGoldTrace','right','left','-v7.3');







