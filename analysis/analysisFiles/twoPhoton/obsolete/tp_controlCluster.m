function Z = tp_controlCluster( Z )
% Cluster ROIs based on their responses to the different parts of the
% control stimulus

    controlEpochs = { 'Left Light Edge','Left Dark Edge','Right Light Edge',...
        'Right Dark Edge','Square Left','Square Right' };
    
    loadFlexibleInputs(Z);
    nRoi = size(Z.ROI.roiMasks,3)-1;
    
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
        imagesc(flipud(Z.filtered.roi_avg_intensity_filtered_normalized(catInds{q},sortInds{q}(end-99:end))'));
        xTicks = [1:10:length(catInds{q})];
        set(gca,'XTick',xTicks,'XTickLabel',round(xTicks*fs));
        xlabel('time (ms)');        
        ylabel('ROI rank');
        title('Top 100 Traces Sorted by Response Mean');
        % view traces, peak heights and averages of strongest traces
        numBest = 10;
        bestInds = sortInds{q}(end-(numBest-1):end);
        for r = 1:numBest
            text{r} = sprintf('Mean: %0.2g; 99th percentile: %0.2g',...
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
        title('99th Percentile');
    end
%     keyboard    
    
    %%    
    si = 0;
    maxInd = 0;
    for q = 1:length(controlEpochs)
        for r = 1:length(inds{q})
            si = si + 1;
%             makeFigure; 
%             imagesc(Z.filtered.roi_avg_intensity_filtered_normalized(inds{q}{r},:));
            allInds{si} = inds{q}{r};
            whichControl(si,:) = [ q r ];  
            maxInd = max([ inds{q}{r}' maxInd ]);
        end
    end
    
    %% Sphere Traces
    % Does it makes sense to sphere before or after ?f/f ? 
    % Actually I don't think it matters. 
    % Sphere only while in control period   
    sphereTraces = Z.filtered.roi_avg_intensity_filtered_normalized(1:maxInd,:);
    sphereTraces = sphereTraces - repmat(mean(sphereTraces,1),[ maxInd 1 ]);
    sphereTraces = sphereTraces * diag(sqrt(diag(sphereTraces'*sphereTraces)))^(-1);    
    % Is this the right thing to do? It's not the same as mean subtracting
    % after averaging, though if all the epochs are the same length it woul
    % d be
    
    %% Project into different rois
    for q = 1:si
        means(q,:) = mean(sphereTraces(allInds{q},:),1);
    end
    
    %% Evaluate strength of this run
    fourT_tude = abs(means(1,:)) - abs(means(2,:)) + ...
        abs(means(3,:)) - abs(means(4,:));
    ds = means(5,:) - means(6,:);
    sinAxis = [1:52]'/fs;
    cosVect = cos(2*pi*sinAxis);
    sinVect = sin(2*pi*sinAxis);
    for q = 5:6
        for r = 1:2
            magCut(:,q-4,r) = norm(sphereTraces(inds{q}{r}(1:52),:));
            cosProj(:,q-4,r) = (sphereTraces(inds{q}{r}(1:52),:)'*cosVect)';
            sinProj(:,q-4,r) = (sphereTraces(inds{q}{r}(1:52),:)'*sinVect)';
            phiVect(:,q-4,r) = atan(cosProj(:,q-4,r)./sinProj(:,q-4,r));
        end
    end      
    phiVect = reshape(phiVect,[nRoi 4]);
    oscMag = sum(sum(cosProj.^2 + sinProj.^2,2),3) ./ sum(sum(magCut.^2,2),3);
    
    % how to line up phases across different trials? mean-phase-subtract?
    
    
    % 1. Histogram of direction selectivity
    figure;
    hist(ds,50);
%     [ centers n ] = hist(ds,50);
    figure;
    hist(fourT_tude,50);
    
    %% Cluster
    nClusters = 6;
    clusterType = 'kmeans';
    switch clusterType
        case 'kmeans'
        	[ cid centers ] = kmeans(means', nClusters,'replicates',1000);
            % USE LOTS OF REPLICATES FOR KMEANS!!!
            figure; imagesc(centers);
            title('Kmeans Centers');
            
        case 'hierarchical'
            distances = pdist(means');
            link = linkage(distances,'average');
            figure; dendrogram(link);
            
    end
    
    %% Visualize: each cluster separately, with direction selectivity/
    % 4T-tude 
    % computing t4-itude as absolute value of response to light versus dark
    % edges - does this make sense?
    
    ftMap = zeros([ imgSize(1) imgSize(2) nClusters]);
    dsMap = zeros([ imgSize(1) imgSize(2) nClusters]);
    phiMap = zeros([ imgSize(1) imgSize(2) 4 ]);
    oscMap = zeros([ imgSize(1) imgSize(2) ]);
    
%     phiVect = phiVect - repmat(mean(phiVect,1),[nRoi 1]);
    for q = 1:nRoi
        r = cid(q);
        ftMap(:,:,r) = ftMap(:,:,r) + Z.ROI.roiMasks(:,:,q) * fourT_tude(q);
        dsMap(:,:,r) = dsMap(:,:,r) + Z.ROI.roiMasks(:,:,q) * ds(q);
        for s = 1:4
            phiMap(:,:,s) = phiMap(:,:,s) + Z.ROI.roiMasks(:,:,q) * phiVect(q,s);
        end
        oscMap = oscMap + Z.ROI.roiMasks(:,:,q) * oscMag(q);
    end 
    %%
    MakeFigure;
    for r = 1:nClusters
        subplot(nClusters,2,1+2*(r-1));
        thisFt = ftMap(:,:,r);
        maxVal = max(abs(thisFt(:)));
        imagesc(thisFt);
        title('abs(Light) - abs(Dark) (L + R)');
        set(gca,'Clim',[-maxVal maxVal]);
        subplot(nClusters,2,2+2*(r-1));
        thisDs = dsMap(:,:,r);
        maxVal = max(abs(thisDs(:)));
        imagesc(thisDs);
        title('Right - Left');
        set(gca,'Clim',[-maxVal maxVal]);
    end
        %%
    wrapmap = parula;
    wrapmap = vertcat(wrapmap,flipud(wrapmap));    
    for r = 1:4
        MakeFigure;
        imagesc(phiMap(:,:,r))
        colormap(wrapmap);
    end
    imagesc(oscMap);
    colormap(parula);

    
    Z.controlCluster = controlCluster;
end