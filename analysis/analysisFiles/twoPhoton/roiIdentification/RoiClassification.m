function [cfRoi,roiTrace] = RoiClassification(Z,flyEye)

%% this function becomes extremly messy, organize that a little bit...
% input, Z, which contains all the information you need; eyes of the fly.
% transfer left/right into progressive and regressive.
%
% output: cfRoi.CC, cfRoi.PStimP


filteredTrace = Z.filtered.roi_avg_intensity_filtered_normalized;
nProb = 8;
nRoi = size(filteredTrace,2);


% edgeType based on the absolute values of the edges.
% % you have to make it more flexible...
% edgeTypesStrStim = {'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge','Square Left','Square Right','Square Up','Square Down'};
edgeTypesStrStim = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge','Square Left','Square Right','Square Up','Square Down'};
dirTypeStrStim = {'Left','Right','Up','Down'};
% % progressive are always 1 and 2, regressive are always 3 and 4...
% edgeTypesStrEye = {'Progressive Dark','Progressive Light','Regressive Dark','Regressive Light','Progressive','Regressive','Up','Down'};
edgeTypesStrEye = {'Progressive Light','Regressive Light','Progressive Dark','Regressive Dark','Progressive','Regressive','Up','Down'};
dirTypeStrEye = {'Progressive','Regressive','Up','Down'};
contrastTypeStr = {'Light','Dark'};
edgeValueLookUp = [2,1,4,3,6,5,7,8];

%% compute the inds of those epoches.
controlEpochInds = cell(nProb,1);
inds = cell(nProb,2);
indsCat = cell(nProb,1);
indsAll = [];
inds12 = cell(2,1);
for qq = 1:nProb
    % Grabbing the frames in which the edge types occurred
    controlEpochInds{qq} = getEpochInds(Z, edgeTypesStrStim{qq});
    inds{qq,1} = [];
    inds{qq,2} = [];
    indsCat{qq} = [];
    for rr = 1:length(controlEpochInds{qq})
        % indscat contains all the indexes for those frames in linear
        % form, as opposed to separated into presentations as in
        % controlEpochInds
        inds{qq,rr} = controlEpochInds{qq}{rr};
    end
    if length(inds{qq,1}) > length(inds{qq,2})
        inds{qq,1} = inds{qq,1}(1:length(inds{qq,2}));
    else
        inds{qq,2} = inds{qq,2}(1:length(inds{qq,1}));
    end
    indsCat{qq} = cat(1,inds{qq,1},inds{qq,2});
    indsAll = cat(1,indsAll, indsCat{qq});
end
for ii = 1:1:2
    inds12{ii} = [];
    for qq = 1:1:nProb
        inds12{ii} = cat(1,inds12{ii},inds{qq,ii});
    end
end



%% compute the cross correlation of the roi on each of these 8 edges.
%% compute the peak response for each epoch, compare in the future.
% compute the repeatability of all the response to the probing stimulus...
classMetric.cc = zeros(nRoi,nProb);
classMetric.peak = zeros(nRoi,nProb);
thresholdP = 0.99;
for rr = 1:1:nRoi
    for qq = 1:1:nProb
        classMetric.cc(rr,qq) = corr(filteredTrace(inds{qq,1},rr),filteredTrace(inds{qq,2},rr));
        % do not use the whole traces, use the mean value of the two traces
%         classMetric.peak(rr,qq) = percentileThresh(filteredTrace(indsCat{qq},rr),thresholdP);
        classMetric.peak(rr,qq) = percentileThresh((filteredTrace(inds{qq,1},rr) + filteredTrace(inds{qq,2},rr))/2,thresholdP);
        
        % all of the peak response is larger than zero...
        classMetric.mean(rr,qq) = mean(filteredTrace(inds{qq,1},rr) + filteredTrace(inds{qq,2},rr)); % should be only one value...
        % there are a lot of value for the mean to be less than zero.
    end
end


%% try to decide whether the cell is left/right....use the peak response for the square left and square right.... just
% 5,6...

% calculate ESI and DSI using peak response on the stimulus coordinates.
PStim = RoiClassification_Value2Type(classMetric.peak,classMetric.mean, dirTypeStrStim,edgeTypesStrStim,contrastTypeStr);
% calculate ESI and DSI using correlation on the stimulus coordinates.
CCStim = RoiClassification_Value2Type(classMetric.cc,classMetric.mean, dirTypeStrStim,edgeTypesStrStim,contrastTypeStr);
if strcmp(flyEye,'left')
    PEye = RoiClassification_Value2Type(classMetric.peak, classMetric.mean, dirTypeStrEye,edgeTypesStrEye,contrastTypeStr);
    CCEye = RoiClassification_Value2Type(classMetric.cc,classMetric.mean, dirTypeStrEye,edgeTypesStrEye,contrastTypeStr);
else
    %     edgeValueLookUp = [3,4,1,2,6,5,7,8];
    PEye = RoiClassification_Value2Type(classMetric.peak(:,edgeValueLookUp),classMetric.mean(:,edgeValueLookUp), dirTypeStrEye,edgeTypesStrEye,contrastTypeStr);
    CCEye = RoiClassification_Value2Type(classMetric.cc(:,edgeValueLookUp),classMetric.mean(:,edgeValueLookUp), dirTypeStrEye,edgeTypesStrEye,contrastTypeStr);
end

cfRoi.PStim = PStim;
cfRoi.CCStim = CCStim;
cfRoi.PEye = PEye;
cfRoi.CCEye = CCEye;

%%
repeatability.wholeProb = zeros(nRoi,1);
repeatability.bestEdge = zeros(nRoi,1);
repeatability.bestSquare  = zeros(nRoi,1);
for rr = 1:1:nRoi
    % whole probing trace
    trace1 = filteredTrace(inds12{1},rr);
    trace2 = filteredTrace(inds12{2},rr);
    repeatability.wholeProb(rr) = corr(trace1,trace2);
    
    % for the best edges.
    edgeType =  cfRoi.PStim.edgeType(rr);
    repeatability.bestEdge(rr) = cfRoi.CCStim.value(rr, edgeType);
    dirType = cfRoi.PStim.dirType(rr);
    repeatability.bestSquare(rr) = cfRoi.CCStim.value(rr,dirType + 4);
end

cfRoi.repeatability = repeatability;
%% do a small meta analysis about the statistics of those cells...
% first of all...Do we have four layers?
%% calculate the trace here and store them in a variable called traces..
roiTraceStim.indiVidualTrace= cell(nRoi,1);
roiTraceStim.meanTrace = cell(nRoi,1);
for rr = 1:1:nRoi
    roiTraceStim.indiVidualTrace{rr} = cell(2,8);
    roiTraceStim.meanTrace{rr} = cell(8,1);
    for qq = 1:1:nProb
        roiTraceStim.indiVidualTrace{rr}{1,qq} = filteredTrace(inds{qq,1},rr);
        roiTraceStim.indiVidualTrace{rr}{2,qq} = filteredTrace(inds{qq,2},rr);
        roiTraceStim.meanTrace{rr}{qq} = (filteredTrace(inds{qq,1},rr)+filteredTrace(inds{qq,2},rr));
    end
end

if strcmp(flyEye,'left')
    roiTraceEye = roiTraceStim;
else
    for rr = 1:1:nRoi
        roiTraceEye.indiVidualTrace{rr} = cell(2,8);
        roiTraceEye.meanTrace{rr} = cell(8,1);
        for qq = 1:1:nProb
            roiTraceEye.indiVidualTrace{rr}{1,qq} = filteredTrace(inds{edgeValueLookUp(qq),1},rr);
            roiTraceEye.indiVidualTrace{rr}{2,qq} = filteredTrace(inds{edgeValueLookUp(qq),2},rr);
            roiTraceEye.meanTrace{rr}{qq} = (filteredTrace(inds{edgeValueLookUp(qq),1},rr) + filteredTrace(inds{edgeValueLookUp(qq),2},rr));
        end
    end
end
roiTrace.stim = roiTraceStim;
roiTrace.eye =  roiTraceEye;
% MakeFigure;
% subplot(2,2,1);
% plot(PStim.value(:,5:6));
% subplot(2,2,3);
% plot(PStim.DSI);
% subplot(2,2,2);
% plot(PStim.dirType);
% subplot(2,2,4);
% plot(PStim.DSI(:,1)+PStim.DSI(:,2));
%
%
% MakeFigure;
% subplot(2,2,1);
% plot(PStim.value(:,1:4));
% subplot(2,2,3);
% plot(PStim.ESI);
% subplot(2,2,2);
% plot(PStim.edgeType);
% subplot(2,2,4);
% plot(sum(PStim.ESI,2));
%


% MakeFigure;
% subplot(2,2,1);
% plot(CCStim.value(:,5:6));
% subplot(2,2,3);
% plot(CCStim.DSI);
% subplot(2,2,2);
% plot(CCStim.dirType);
% subplot(2,2,4);
% plot(CCStim.DSI(:,1)+CCStim.DSI(:,2));
%
%
% MakeFigure;
% subplot(2,2,1);
% plot(CCStim.value(:,1:4));
% subplot(2,2,3);
% plot(CCStim.ESI);
% subplot(2,2,2);
% plot(CCStim.edgeType);
% subplot(2,2,4);
% plot(sum(CCStim.ESI,2));
%
% for r = 1:1:nRoi
%     MakeFigure;
%     alltrace = roiTrace.indiVidualTraceStim{r};
% PlotTrace_ProbingStimulus(alltrace,PStim.value(r,:),PStim.edgeName{r},0)
% end

% test whether the edgeType and the dirType gives out similar response...
% not really, some times, for Up/Down Square waves. write a function to
% % selecte roi based on this...
% MakeFigure;
% % distribution of the left selective neuron, and the right selective
% % neuron.
% edgeTypeDist = zeros(2,4);
% for ii = 1:1:2
%     a = PStim.edgeType(PStim.dirType == ii);
%     for tt = 1:1:4
%     edgeTypeDist(ii,tt) = sum(a == tt);
%     end
% end
% bar(edgeTypeDist);
% set(gca,'XTickLabel',{'Square Left','Square Right'});
% legend(edgeTypesStrStim{1:4} );
%
% MakeFigure;
% % distribution of the left selective neuron, and the right selective
% % neuron.
% edgeTypeDist = zeros(2,4);
% for ii = 1:1:2
%     a = CCStim.edgeType(CCStim.dirType == ii);
%     for tt = 1:1:4
%     edgeTypeDist(ii,tt) = sum(a == tt);
%     end
% end
% bar(edgeTypeDist);
% set(gca,'XTickLabel',{'Square Left','Square Right'});
% legend(edgeTypesStrStim{1:4})
% %% it would be very interesting to see those overlapping rois.
end