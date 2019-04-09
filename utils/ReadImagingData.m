function [flyResp,epochList,params,stim] = ReadImagingData(dataPath)
    
    Z = twoPhotonMaster('filename', dataPath,'force_new_ROIs',0);
    epochs = [36; 37];

    epochsForSelectivity = {'Square Left'; 'Square Right'};
    epochsForSelectivity = epochs;
    Z.params.epochsForSelectivity = epochsForSelectivity;
    Z.ROI.roiIndsOfInterest = extractROIsBySelectivity(Z);

    flyResp{1} = Z.filtered.roi_avg_intensity_filtered_normalized(:,Z.ROI.roiIndsOfInterest);

    epochsForSelectivity = {'Square Right'; 'Square Left'};
%     epochsForSelectivity = [31; 30];
    epochsForSelectivity = flipud(epochs);
    Z.params.epochsForSelectivity = epochsForSelectivity;
    Z.ROI.roiIndsOfInterest = extractROIsBySelectivity(Z);

    flyResp{2} = Z.filtered.roi_avg_intensity_filtered_normalized(:,Z.ROI.roiIndsOfInterest);

    trigEnds = Z.params.trigger_inds;

    
    params = Z.stimulus.params;

    epochList{1} = zeros(size(flyResp{1}));
    epochList{2} = zeros(size(flyResp{2}));

    for ee = 1:size(fieldnames(trigEnds),1)
        epochName = ['epoch_' num2str(ee)];
        duration = round(trigEnds.(epochName).stim_length);
        epochStart = round(trigEnds.(epochName).trigger_data);
        
        params(ee).duration = duration;

        for bb = 1:size(trigEnds.(epochName).bounds,2)
            epochList{1}(epochStart(bb):epochStart(bb)+duration-1,:) = ee;
            epochList{2}(epochStart(bb):epochStart(bb)+duration-1,:) = ee;
        end
    end

    flyResp{1} = cat(3,flyResp{1},flyResp{1});
    flyResp{2} = cat(3,flyResp{2},flyResp{2});
    epochList{1} = epochList{1} - 12;
    epochList{2} = epochList{2} - 12;
    epochList{1}(epochList{1}<1) = 1;
    epochList{2}(epochList{2}<1) = 1;
    
    params = params(13:end);
    
    stim = Z.stimulus.allStimulusBehaviorData.StimulusData;
end