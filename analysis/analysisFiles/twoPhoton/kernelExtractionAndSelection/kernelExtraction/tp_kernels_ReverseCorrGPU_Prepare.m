function [respDataGPU,stimDataGPU,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare(respData,stimIndexes,stimData,maxTau)

sampling_r_largerthan_s = sum(diff(stimIndexes{1}) == 0) > 10;
nRoi = length(respData);
nMultiBars = size(stimData,2);

if sampling_r_largerthan_s == 0
    %% if sampling rate of response is slower than stimulus
    
    nT = size(stimData,1);
    respDataGPUMat = zeros(nT,nRoi);
    numElementsSummed = zeros(nRoi,1);
    startingPoint = zeros(nRoi,1);
    endingPoint = zeros(nRoi,1);
    for rr = 1:1:nRoi
        respDataMeanSub = respData{rr} - mean(respData{rr});
        respDataGPUMat(stimIndexes{rr},rr) = single(respDataMeanSub);
        startingPoint(rr) = stimIndexes{rr}(1);
        endingPoint(rr) = stimIndexes{rr}(end);
    end
    
    startingPointAll = max(startingPoint) + 2 * maxTau;
    endingPointAll = min(endingPoint);
    
    for rr = 1:1:nRoi
        numElementsSummed(rr) = sum(stimIndexes{rr} < endingPointAll & stimIndexes{rr} > startingPointAll);
    end
    
    
    respDataGPUMat = respDataGPUMat(startingPointAll:endingPointAll,:);

    respDataGPU{1} = single(respDataGPUMat);
    % stim
    stimDataGPU = cell(1,nMultiBars);
    stimDataGPUMat = stimData;
    
    stimDataGPUMat = stimDataGPUMat(startingPointAll:endingPointAll,:);
    stimDataGPUMat = stimDataGPUMat - repmat(mean(stimDataGPUMat),[size(stimDataGPUMat,1),1]);
    stimDataVar = var(stimDataGPUMat);
    for qq = 1:1:nMultiBars
        stimDataGPU{qq} = single(repmat(stimDataGPUMat(:,qq),[1,nRoi]));
    end
    
    %% if sampling rate of response is larger than stimulus
else
    if length(respData) == 1  % one roi by one roi.
       
        % response does not have to change too much. 
        startingPoint = 1 + 2 * maxTau;
        endingPoint = length(respData{1}) - maxTau;
        respDataGPU = cell(1,1);  
        respDataGPU{1} = single(respData{1}(startingPoint:endingPoint));
        respDataGPU{1} = respDataGPU{1} - mean(respDataGPU{1});
        
        stimDataGPU = single(stimData(stimIndexes{1}(startingPoint:endingPoint),:));
        numElementsSummed = length(respDataGPU{1});
        stimDataVar = var(stimDataGPU);
        stimDataGPU = mat2cell(stimDataGPU , length(respDataGPU{1}), ones(1,nMultiBars));
        
        
        
    end
end

