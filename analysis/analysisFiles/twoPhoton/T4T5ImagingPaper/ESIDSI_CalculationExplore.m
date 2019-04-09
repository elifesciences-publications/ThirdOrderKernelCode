function [cfRoi] = ESIDSI_CalculationExplore(Z,flyEye)

% only on the eye, not the other....
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

%%
% given the traces, what are you going to do with them?
% first, calculat the moving average of each fi
%% instead of using noisy response. try something easy first...
classMetric.peak = zeros(nRoi,nProb); 
thresholdP = 0.99;
meanTrace = cell(nRoi,nProb);
for rr = 1:1:nRoi
    for qq = 1:1:nProb
        meanTrace{rr,qq} = (filteredTrace(inds{qq,1},rr) + filteredTrace(inds{qq,2},rr))/2;
        classMetric.peak(rr,qq) = percentileThresh((filteredTrace(inds{qq,1},rr) + filteredTrace(inds{qq,2},rr))/2,thresholdP);
        classMetric.mean(rr,qq) = mean(filteredTrace(inds{qq,1},rr) + filteredTrace(inds{qq,2},rr)); % should be only one value...
    end
end
% combine the response from two edges together....
% for left and right. you only have two values for left/right. another two
% values for dark and light.
% light, dark, left, right .
edgeRespContrast = zeros(nRoi,2); % combine the response first, and do max/mean from them later...
edgeRespDirection = zeros(nRoi,2);
edgeTypesStrStim = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge','Square Left','Square Right','Square Up','Square Down'};
for rr = 1:1:nRoi 
    % for light / dark. add the trace together.
    lightTrace = (meanTrace{rr,1} + meanTrace{rr,2})/2;
    darkTrace = (meanTrace{rr,3} +  meanTrace{rr,4})/2;
    LeftTrace = (meanTrace{rr,1} + meanTrace{rr,3})/2;
    RightTrace = (meanTrace{rr,2} + meanTrace{rr,4})/2;
    % do you do the maximun? or percentile...the noise can be huge...
    edgeRespContrast(rr,1) = percentileThresh(lightTrace,thresholdP);
    edgeRespContrast(rr,2) = percentileThresh(darkTrace,thresholdP);
    edgeRespDirection(rr,1) = percentileThresh(LeftTrace,thresholdP);
    edgeRespDirection(rr,2) = percentileThresh(RightTrace,thresholdP);
end
edgeRespContrast(edgeRespContrast < 0) = 0;
edgeRespDirection(edgeRespDirection < 0) = 0;

ESI = (edgeRespContrast(:,1) - edgeRespContrast(:,2))./(edgeRespContrast(:,1) + edgeRespContrast(:,2));
DSI = (edgeRespDirection(:,1) - edgeRespDirection(:,2))./(edgeRespDirection(:,1) + edgeRespDirection(:,2));

if strcmp(flyEye,'left')
    PEye = ESIDSI_CalculationExplore_Value2Type(classMetric.peak, classMetric.mean, dirTypeStrEye,edgeTypesStrEye,contrastTypeStr);
    PEye.ESI_V3 = ESI;
    PEye.DSI_V3 = DSI;
else
    PEye = ESIDSI_CalculationExplore_Value2Type(classMetric.peak(:,edgeValueLookUp),classMetric.mean(:,edgeValueLookUp), dirTypeStrEye,edgeTypesStrEye,contrastTypeStr);
    PEye.ESI_V3 = ESI;
    PEye.DSI_V3 = -DSI;
end

cfRoi.PEye = PEye;

%%
repeatability.wholeProb = zeros(nRoi,1);
for rr = 1:1:nRoi
    % whole probing trace
    trace1 = filteredTrace(inds12{1},rr);
    trace2 = filteredTrace(inds12{2},rr);
    repeatability.wholeProb(rr) = corr(trace1,trace2);
end

cfRoi.repeatability = repeatability;
%% do a small meta analysis about the statistics of those cells...
% first of all...Do we have four layers?
%% calculate the trace here and store them in a variable called tracesend