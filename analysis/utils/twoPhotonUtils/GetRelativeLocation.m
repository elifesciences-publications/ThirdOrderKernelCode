function roiLocationDegrees = GetRelativeLocation(snipMat,params,epochInd,dataRate)
    numEpochs = length(epochInd);
    numRois = size(snipMat,2);
    
    roiLocationFramesTrialAve = zeros(numEpochs,numRois);
    maxResponseTrialAve = zeros(numEpochs,numRois);
    
    roiLocation = zeros(1,numRois);
    
    percentile = 98;
    
    for ee = 1:numEpochs
        edgeVelocity = params(epochInd(ee)).velocityL;
        
        for rr = 1:numRois
            numTrials = size(snipMat{epochInd(ee),rr},2);
            
            maxResponseTrial = zeros(numTrials,1);
            roiLocationTrial = zeros(numTrials,1);
            
            for tt = 1:numTrials
                stdFilt = 2;
                numStd = 2;
                t = ((-numStd*stdFilt):(numStd*stdFilt))';
                temporalFilt = normpdf(t,0,stdFilt);
                filteredResp = imfilter(mean(snipMat{epochInd(ee),rr},2),temporalFilt,'symmetric');
                
                
                cutOff = prctile(filteredResp,percentile);
                topValues = filteredResp>=cutOff;
                maxResponseTrial(tt) = mean(snipMat{epochInd(ee),rr}(topValues,tt)); % find the peak location
                roiLocationTrial(tt) = mean(find(topValues));
            end
            
            maxResponseTrialAve(ee,rr) = mean(maxResponseTrial);
            roiLocationFramesTrialAve(ee,rr) = mean(roiLocationTrial); % find average location (sub frame if multiple trials)
        end
    end
    
    for rr = 1:numRois
        [~,biggestResponse] = max(maxResponseTrialAve(:,rr));
        roiLocation(rr) = roiLocationFramesTrialAve(biggestResponse,rr);
    end
    
    % convert locMap from frames to seconds
    locMapSeconds = roiLocation/dataRate;
    
    % convert locMap from seconds to degrees
    roiLocationDegrees = locMapSeconds*edgeVelocity;
end