function [trace] = GetTheStillTraces(Z)

% the two presentations for still data.
filteredTrace = Z.filtered.roi_avg_intensity_filtered_normalized;
nProb = 4;
nRoi = size(filteredTrace,2);
stimStrStim = {'Still'};

%% compute the inds of those epoches.
inds = cell(nProb,2);
controlEpochInds = getEpochInds(Z, stimStrStim );
% only use the first 2.
controlEpochInds = controlEpochInds(:,1:2); %  only use the first part.
for qq = 1:nProb
    % Grabbing the frames in which the edge types occurred
    
    inds{qq,1} = [];
    inds{qq,2} = [];
    for rr = 1:size(controlEpochInds,2)
        inds{qq,rr} = controlEpochInds{qq,rr};
    end
    if length(inds{qq,1}) > length(inds{qq,2})
        inds{qq,1} = inds{qq,1}(1:length(inds{qq,2}));
    else
        inds{qq,2} = inds{qq,2}(1:length(inds{qq,1}));
    end
end
inds = cell2mat(inds);
nT = size(inds,1);
trace = zeros(nT,2,nRoi);
for rr = 1:1:nRoi
    trace(:,1,rr) = filteredTrace(inds(:,1),rr);
    trace(:,2,rr) = filteredTrace(inds(:,2),rr);
end
end