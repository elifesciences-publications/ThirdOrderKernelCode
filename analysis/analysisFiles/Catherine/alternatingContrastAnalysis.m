function Z = alternatingContrastAnalysis(Z)
% first run Z.stimData = stimData

    allEpoch3Data = Z.stimData(find(Z.stimData(:, 3) == 3), :);
    allEpoch4Data = Z.stimData(find(Z.stimData(:, 3) == 4), :);
    allEpoch3Epoch4Data = Z.stimData;
    allEpoch3Epoch4Data(find(allEpoch3Epoch4Data(:,3) == 0),:) = [];
    allEpoch3Epoch4Data(find(allEpoch3Epoch4Data(:,3) == 1),:) = [];
    allEpoch3Epoch4Data(find(allEpoch3Epoch4Data(:,3) == 2),:) = [];
    
    % keep columns: frame number, epoch number, stimulus value 
    epoch3StimData(:,1) = allEpoch3Data(:, 2);
    epoch3StimData(:,2) = allEpoch3Data(:,3);
    epoch3StimData(:,3) = allEpoch3Data(:, 15);
    
    % ignore the partial epoch at the end
    epoch3StimData(end-2:end, :) = [];
    
    epoch3epoch4StimData(:,1) = allEpoch3Epoch4Data(:,2);
    epoch3epoch4StimData(:,2) = allEpoch3Epoch4Data(:,3);
    epoch3epoch4StimData(:,3) = allEpoch3Epoch4Data(:,15);
    epoch3epoch4StimData(end-2:end,:) = [];

    
    epoch4StimData(:,1) = allEpoch4Data(:, 2);
    epoch4StimData(:,2) = allEpoch4Data(:,3);
    epoch4StimData(:,3) = allEpoch4Data(:, 15);
    
    Z.epoch3Data = epoch3StimData;
    Z.epoch4Data = epoch4StimData;
    Z.epoch3epoch4Data = epoch3epoch4StimData;
    
    a = Z.flick.responseData;
    c = Z.flick.alignedStimulusData{4};
    stimulus = c(:,1);
    stimulus(1:1920, :) = [];
    a(1:1920, :) = [];
    a(end, :) = [];
    stimulus(end, :) = [];
    Z.stim = stimulus;
    indices = find(Z.ROI.roiIndsOfInterest == 0);
    a(:, indices) = [];
    Z.meanResponses2 = mean(a,2);
    Z.meanResponses2(:, 2) = Z.epoch3epoch4Data(:,2);
    Z.stim(:, 2) = Z.epoch3epoch4Data(:,2);
    Z.stim(:, 3) = Z.epoch3epoch4Data(:,1);
    Z.meanResponses2(:, 3) = Z.epoch3epoch4Data(:,1);
    
    
    
    %% take two, using data from tp_flickerSelectAndAlign
    allEpoch3Data2 = Z.stim(find(Z.stim(:, 2) == 3), :);
    allEpoch4Data2 = Z.stim(find(Z.stim(:, 2) == 4), :); 
    allEpoch3Epoch4Data2 = Z.stim;
    
    % keep columns: frame number, epoch number, stimulus value 
    epoch3StimData2(:,1) = allEpoch3Data2(:, 3);
    epoch3StimData2(:,2) = allEpoch3Data2(:,2);
    epoch3StimData2(:,3) = allEpoch3Data2(:, 1);
    
    
    epoch3epoch4StimData2(:,1) = allEpoch3Epoch4Data2(:,3);
    epoch3epoch4StimData2(:,2) = allEpoch3Epoch4Data2(:,2);
    epoch3epoch4StimData2(:,3) = allEpoch3Epoch4Data2(:,1);
    

    epoch4StimData2(:,1) = allEpoch4Data2(:, 3);
    epoch4StimData2(:,2) = allEpoch4Data2(:,2);
    epoch4StimData2(:,3) = allEpoch4Data2(:, 1);
    

    epoch3StimData2(:, 4) = Z.meanResponses2(find(Z.meanResponses2(:, 2) == 3), 1);
    epoch4StimData2(:, 4) = Z.meanResponses2(find(Z.meanResponses2(:, 2) == 4), 1);
    epoch3epoch4StimData2(:, 4) = Z.meanResponses2(:, 1);
 
    % epoch 3 data, skipping the first epoch
    n = 1;
    for k = 541:600:(size(epoch3epoch4StimData2,1)-600)
        epoch3DataFirstSecond(n:n+119,1) = epoch3epoch4StimData2(k:k+119, 1);
        epoch3DataFirstSecond(n:n+119,2) = epoch3epoch4StimData2(k:k+119, 2);
        epoch3DataFirstSecond(n:n+119,3) = epoch3epoch4StimData2(k:k+119, 3);
        epoch3DataFirstSecond(n:n+119,4) = epoch3epoch4StimData2(k:k+119, 4);
        n = n+120;
    end
    
    % epoch 4 data, skipping the first epoch
    n = 1;
    for k = 841:600:(size(epoch3epoch4StimData2,1))
        epoch4DataFirstSecond(n:n+119,1) = epoch3epoch4StimData2(k:k+119, 1);
        epoch4DataFirstSecond(n:n+119,2) = epoch3epoch4StimData2(k:k+119, 2);
        epoch4DataFirstSecond(n:n+119,3) = epoch3epoch4StimData2(k:k+119, 3);
        epoch4DataFirstSecond(n:n+119,4) = epoch3epoch4StimData2(k:k+119, 4);
        n = n+120;
    end
    
    Z.epoch3DataFirstSecondIncluded = epoch3DataFirstSecond;
    Z.epoch4DataFirstSecondIncluded = epoch4DataFirstSecond;
    Z.epoch3Data2 = epoch3StimData2;
    Z.epoch4Data2 = epoch4StimData2;
    Z.epoch3epoch4Data2 = epoch3epoch4StimData2;
end

