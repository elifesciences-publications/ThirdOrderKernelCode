function [RFCenter,xBest] = AlignRFCenter_Utils_UseEdgeResponse(dirType, trace, varargin)
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
nMultiBars = 8;
barWidth = 5;
edgeVel = 30;
recording_f = 13;
dataForAlign = []; % my standard edge response. % could be updated.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{',num2str(ii + 1),'};']);
end
% S = GetSystemConfiguration;
% kernelFolder = S.kernelSavePath;
% % you have to provide
% dataForAlign = [kernelFolder,'\T4T5_Imaging_Paper\TimeTracesToFindRF\AlignmentGoldTrace.mat'];
load(dataForAlign);
switch dirType
    case 1 % left
        traceTemplate = left.trace;
        relativeTimeTemplate = left.relativeTime;
    case 2 % right
        traceTemplate = right.trace;
        relativeTimeTemplate = right.relativeTime;
end
% judge it was left or right....
nTemplate = length(traceTemplate);
relativeTimeMat = size(nTemplate,1);
for ii = 1:1:nTemplate
    relativeTimeMat(ii) = MyXCorr_RelativePos(trace,traceTemplate{ii});
end

% find the best alignment, which maintain the structure, but store the
% structure.
xInit = relativeTimeMat(1);
xBest = fminsearch(@(x)sum(((relativeTimeTemplate + x) - relativeTimeMat').^2)  ,xInit);
xBest = -xBest; % because you want template VS trace, not trace VS template.

switch dirType
    case 1
        RFCenter =  xBest * 1/recording_f * edgeVel  / barWidth;
        RFCenter = round(RFCenter - absolute_offset_left);
        
    case 2
        RFCenter =  -xBest * 1/recording_f * edgeVel / barWidth;
        RFCenter = round(RFCenter - absolute_offset_right);
end
RFCenter = RFCenter + nMultiBars * 4; % avoid negetive number.
RFCenter = mod(RFCenter - 1,nMultiBars) + 1;
end