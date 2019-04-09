function tp_STN( Z )
% Estimates the signal-to-noise ratio of two photon data based on control
% epoch averages.

    controlEpochs = {'Left Light Edge','Left Dark Edge','Right Light Edge', ...
        'Right Dark Edge','Square Left','Square Right','Square Up','Square Down'};
    loadFlexibleInputs(Z);
    
    %% Get control epoch indices
    allCat = [];
    for q = 1:length(controlEpochs)       
        inds{q} = getEpochInds(Z, controlEpochs{q});
        for r = 1:length(inds{q})
            allCat = cat(1,allCat,inds{q}{r});
        end
    end
    firstPt = min(allCat);
    lastPt = max(allCat);
    antiCat = [1:lastPt];
    antiCat(allCat) = [];
    allInds = zeros(1,lastPt);
    allInds(antiCat) = 1;
    allInds(1:firstPt-1) = 0;
%     figure; plot(allInds);

    %% Get control responses during off-indices
    interleaves = Z.filtered.roi_avg_intensity_filtered_normalized(antiCat,:);
    interSd = std(interleaves,[],1);
    interMean = mean(interleaves,1);
    
    %% Get mean responses during square wave responses
    if isstr(controlEpochs{1})
        dirNums = [ find(strcmp(controlEpochs,'Square Left')); find(strcmp(controlEpochs,'Square Right')) ];
    else
        dirNums =[ 1 2 ];
    end
    for qp = 1:length(dirNums)
        q = dirNums(qp);
        controlMeans{qp} = zeros(1,size(Z.ROI.roiMasks,3)-1);
        for r = 1:length(inds{q})
            controlResps{qp,r} = Z.filtered.roi_avg_intensity_filtered_normalized(inds{q}{r},:);
            controlMeans{qp} = controlMeans{qp} + mean(controlResps{qp,r},1)/2;            
        end
        stn(qp,:) = (controlMeans{qp} - interMean) ./ interSd;
    end
    
    %% Reorder STN to reflect 
    if ~isfield(Z,'eval')
        Z = tp_roiEval(Z);
    end
    
    [ vals dsSortInds ] = sort( Z.eval.direction_selectivity );
    MakeFigure; 
    subplot(1,2,1); 
    imagesc(flipud(stn(:,dsSortInds)'));
    set(gca,'FontSize',16);
    title('Signal to Noise Ratio');
    set(gca,'XTick',[1:2],'XTickLabel',{'Left','Right'});
    ylabel('ROI rank (leftmost to rightmost)');
    maxVal = max(abs(stn(:)));
    set(gca,'Clim',[-maxVal maxVal]);
    colormap_gen;
    colormap(mymap);
    subplot(2,2,2); 
    hist(stn(1,:),40); title('Left Control Response');
    set(gca,'FontSize',16);
    subplot(2,2,4);
    hist(stn(2,:),40); title('Right Control Response')
    set(gca,'FontSize',16);
    
end

