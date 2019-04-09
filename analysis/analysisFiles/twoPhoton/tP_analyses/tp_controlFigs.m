function tp_controlFigs( Z )
% Save control epoch evaluation figures. 

    controlEpochs = { 'Left Light Edge','Left Dark Edge','Right Light Edge',...
        'Right Dark Edge','Square Left','Square Right' };
    
    loadFlexibleInputs(Z);
    nRoi = size(Z.ROI.roiMasks,3)-1;
    numKeep = min(100,nRoi);
        
    %% Get indices corresponding to each separate instance of each control stim
    %% Get numbers corresponding to control epochs
    for q = 1:length(controlEpochs)
        inds{q} = getEpochInds(Z, controlEpochs{q});
    end
    
    %% Visualize All Traces for Control Epochs
    % Concatenate indices by epoch type
    nEpTypes = length(controlEpochs);
    for q = 1:nEpTypes
        catInds{q} = [];
        for r = 1:length(inds{q})
            catInds{q} = cat(1,catInds{q},inds{q}{r});
        end
    end
    
    % take averages during these epochs
    for q = 1:nEpTypes
        stimTypeMeans(q,:) = mean(Z.filtered.roi_avg_intensity_filtered_normalized(catInds{q},1:nRoi),1);
        for r = 1:nRoi
            stimTypePeaks(q,r) = percentileThresh( Z.filtered.roi_avg_intensity_filtered_normalized...
                (catInds{q},r),.98 );
        end
    end
    
    % visualize sorted
    for q = 1:nEpTypes
        % view all
        [ sortVals sortInds{q} ] = sort(stimTypeMeans(q,:));
        MakeFigure;
        suptitle(controlEpochs{q});
        subplot(1,3,1); 
        tracesImg = Z.filtered.roi_avg_intensity_filtered_normalized(catInds{q},sortInds{q}(end-(numKeep-1):end))';
        imagesc(flipud(tracesImg));
        maxVal = percentileThresh(tracesImg,.99);
        xTicks = [1:10:length(catInds{q})];
        set(gca,'XTick',xTicks,'XTickLabel',round(xTicks*fs),'Clim',[-maxVal maxVal]);
        xlabel('time (ms)');        
        ylabel('ROI rank');
        title('Top 100 Traces Sorted by Response Mean');
        % view traces, peak heights and averages of strongest traces
        numBest = 10;
        bestInds = sortInds{q}(end-(numBest-1):end);
        for r = 1:numBest
            text{r} = sprintf('Mean: %0.2g; 98th percentile: %0.2g',...
                stimTypeMeans(q,bestInds(r)),stimTypePeaks(q,bestInds(r)));        
        end
        subplot(1,3,2);
        staggerPlotTraces(Z.filtered.roi_avg_intensity_filtered_normalized(catInds{q},bestInds),text);
        title(['Top ' num2str(numBest) ' Traces (Concatenated)']);
        xTicks = [1:10:length(catInds{q})];
        set(gca,'XTick',xTicks,'XTickLabel',round(xTicks*fs));
        xlabel('time (ms)');
        subplot(2,3,3);
        plot(stimTypeMeans(q,fliplr(sortInds{q})));
        xlabel('ROI rank'); ylabel('\Delta F/F');
        title('Mean Response');
        subplot(2,3,6);
        plot(stimTypePeaks(q,fliplr(sortInds{q})));
        xlabel('ROI rank'); ylabel('\Delta F/F');
        title('98th Percentile');
    end
    
%     %% Visualize Raw Traces
%     % sorted by direction selectivity
%     Z = tp_roiEval(Z); 
%     numKeep = 50;
%     [ vals dsSort ] = sort(Z.eval.direction_selectivity);
%     maxDs = [ dsSort(1:numKeep)'; dsSort(end-(numKeep-1):end)' ];
%     tp_plotROITraces(Z,maxDs);
%     
    

    %% Save figures in the data path
    hfigs = get(0, 'children'); 
    hfigs = sort(hfigs);  
    extLength = length(Z.params.fn);
    localPath = Z.params.filename(1:end-(extLength+1));
    for q = 1:nEpTypes
        imgFileName = controlEpochs{q};  
        if ~isdir([ localPath '/controlFigs' ])
            mkdir([ localPath '/controlFigs' ]);
        end
        savefig(hfigs(end-(q-1)),[ localPath '/controlFigs/' imgFileName ]);
    end

end

