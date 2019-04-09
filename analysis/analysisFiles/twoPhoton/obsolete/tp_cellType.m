function Z = tp_cellType( Z )
% Evaluate the light versus dark edge response magnitude for each ROI; plot
% scatter plots of relative responses

    edgeTypes = {'Left Light Edge','Left Dark Edge','Right Light Edge',...
        'Right Dark Edge'};
    seeCellTypes = 1;
    loadFlexibleInputs(Z);
    
    %% Which epoch numbers are these edges?
    epochNum = [];
    for q = 1:length(edgeTypes)
        epochNum = [epochNum find(strcmp({Z.stimulus.params.epochName}, edgeTypes{q}))];
    end
    
    %% Get indices corresponding to the different edge types
    for q = 1:length(epochNum)
    	bounds{q} = trigger_inds.(['epoch_' num2str(epochNum(q))]).bounds;
        finalBounds{q} = zeros(size(bounds{q}));
        finalBounds{q}(1, :) = ceil(bounds{q}(1, :));
        finalBounds{q}(2, :) = floor(bounds{q}(2, :));
        indices{q} = zeros(sum(diff(finalBounds{q}))+size(finalBounds{q}, 2), 1);
        indexInd = 1;
        for boundsLoop = finalBounds{q}
            theseBounds = boundsLoop(1):boundsLoop(2);
            indices{q}(indexInd:indexInd+length(theseBounds)-1) = theseBounds;
            indexInd = indexInd + length(theseBounds);
        end
    end
    %     keyboard 
    % erroneous last pixel in {1}?
    
    %% Average the filtered traces during these time points
    for q = 1:length(epochNum)
        diffEpProj(q,:) = mean(Z.filtered.roi_avg_intensity_filtered_normalized(indices{q},:),1);
    end
    
    %% Visualize the layout of ROIs with different selectivities
    if seeCellTypes
        % assuming four 
        colormap_gen;
        projMask = zeros([Z.params.imgSize(1),Z.params.imgSize(2),4]);
        figure;
        for r = 1:4;    
            for q = 1:size(Z.ROI.roiMasks,3)-1
                projMask(:,:,r) = projMask(:,:,r) + Z.ROI.roiMasks(:,:,q)*diffEpProj(r,q);
            end
            subplot(2,2,r);
            imagesc(projMask(:,:,r));
            extrem = max(max(abs(projMask(:,:,r))));
            set(gca,'Clim',[-extrem extrem]);
            title(edgeTypes{r});
            colormap(mymap);
        end
        figure; 
        subplot(1,2,1);
        imagesc(projMask(:,:,3) - projMask(:,:,4));
        thisTitle = sprintf('%s - %s',edgeTypes{3},edgeTypes{4});
        title(thisTitle);
        extrem = max(max(abs(projMask(:,:,3) - projMask(:,:,4))));
        set(gca,'Clim',[-extrem extrem]);
        subplot(1,2,2);
        imagesc(projMask(:,:,1) - projMask(:,:,2));
        thisTitle = sprintf('%s - %s',edgeTypes{1},edgeTypes{2});
        title(thisTitle);
        extrem = max(max(abs(projMask(:,:,1) - projMask(:,:,2))));
        set(gca,'Clim',[-extrem extrem]);
        colormap(mymap);

    %% Scatter plots
        compareTypes = [1 2; 3 4; 1 4; 1 3; 2 3; 2 4];
    %     compareTypes = [1 2];
        for q = 1:size(compareTypes,1)
            a = compareTypes(q,1);
            b = compareTypes(q,2);
            figure; scatter(diffEpProj(a,:),diffEpProj(b,:));
            R(q) = simple_r(diffEpProj(a,:),diffEpProj(b,:));
            thisTitle = sprintf('%s vs. %s; R^2 = %0.2g',edgeTypes{a},edgeTypes{b},R(q).^2);
            title(thisTitle);
            xlabel([edgeTypes{a} ' (mean delta F / F )']); ylabel([edgeTypes{b} ' (mean delta F / F )']); 
            hold all;
            xRange = [ min(diffEpProj(a,:)), max(diffEpProj(a,:)) ];
            xRange = linspace(xRange(1),xRange(2),1e3);
            polyCos = polyfit(diffEpProj(a,:),diffEpProj(b,:),1);
            yLine = polyval(polyCos,xRange);
            plot(xRange,yLine);
            hold off;
            eqnStr = sprintf('y = %0.2g x + %0.2g',polyCos(1),polyCos(2));
            legend('data',eqnStr);
        end

        %% Visualize all traces
        indicesCat = [];
        for q = 1:length(epochNum)
            indicesCat = cat(1,indicesCat,indices{q});
        end
        maxInd = max(indicesCat);
        padMaxInd = maxInd + 100;
        refTrace = zeros(padMaxInd,length(epochNum));
        for q = 1:length(epochNum)
            refTrace(indices{q},q) = size(Z.filtered.roi_avg_intensity_filtered_normalized,2);
        end    
        [ maxVal maxBin ] = max(diffEpProj);
        [ outVect permutation ] = sort(maxBin);
        figure;
        traceMap = Z.filtered.roi_avg_intensity_filtered_normalized(1:padMaxInd,permutation)';
        maxVal = max(abs(traceMap(:)));
        imagesc(traceMap); axis xy; 
        set(gca,'Clim',[-maxVal maxVal]);
        hold all;  plot(refTrace);
        colormap_gen; colormap(mymap);
        Z.cellType.maxBin = maxBin;
        title('All Traces During Epochs');
        legend(edgeTypes);

    end
    
    Z.cellType.edgeTypes = edgeTypes;
    Z.cellType.indices = indices;
    Z.cellType.diffEpProj = diffEpProj;
    
end

