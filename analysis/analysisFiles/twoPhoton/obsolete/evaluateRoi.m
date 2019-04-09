function Z = evaluateRoi( Z )
% Evaluates ROI's selected earlier in the process by outputting plots
% comparing several different features:
%   ROI variances v. mean
%   z-score on a given set of epochs v. mean
%   size v. mean
%   size v. variance
%   anything else that might be useful?

    roi_scatter_combos = ...
        {'roiMean','roiVariance'; ...
         'roiSize','roiVariance'; ...
         'roiSize','roiMean'; ...
         'roiSize','roiMeanAct';...
         'roiMean','roiMeanAct'};
    whichTraces = 'raw';
    
    loadFlexibleInputs(Z)

    %% load traces and maps from previous functions
    maps = Z.ROI.roiMasks;
    switch whichTraces
        case 'filtered'
            traces = Z.filtered.roi_avg_intensity_filtered_normalized;
        case 'raw'
            traces = Z.rawTraces.roi_intensities;
    end   
    
    %% create relevant variables
    roiVariance = std(traces,[],1).^2;
    roiMean = mean(traces,1);  
    actImg = mean(abs(Z.diffEp.differentialImages),3);
    for q = 1:size(maps,3)-1
        roiSize(1,q) = sum(sum(maps(:,:,q)));
        thisAct = actImg .* Z.ROI.roiMasks(:,:,q);
        roiMeanAct(1,q) = sum(thisAct(:)) / roiSize(1,q);
    end   
    
    %% Scatter
     
    for q = 1:size(roi_scatter_combos,1)
        figure;
        evalc(['thisR = simple_r(' roi_scatter_combos{q,1} ',' roi_scatter_combos{q,2} ');']);
        thisTitle = sprintf('%s v %s; R = %0.5g',roi_scatter_combos{q,1},roi_scatter_combos{q,2},thisR);
        evalc(['scatter(' roi_scatter_combos{q,1} ',' roi_scatter_combos{q,2} ');']);
        xlabel(roi_scatter_combos{q,1}); ylabel(roi_scatter_combos{q,2});
        title(thisTitle); 
    end
    
end

