function Z = diffEp(Z)
    % A simplification of triggeredResponseDifferentialROIDetection to just
    % spit out +/- images; Note it always compares to the directly previous
    % epoch

    
    loadFlexibleInputs(Z)
    imgFrames = Z.grab.imgFrames;
    triggerInds = trigger_inds;
%     differentialEpochs = Z.params.differentialEpochs;
    
    if ~isnumeric(differentialEpochs)
        if iscell(differentialEpochs)
            epochNum = [];
            for i = 1:size(differentialEpochs, 2)
                if isfield( Z.stimulus.params, 'epochName')
                    epochNum = [epochNum find(strcmp({Z.stimulus.params.epochName}, differentialEpochs{i}))];
                else
                    warning('diffEp couldn''t complete processing because the cardinal directions weren''t presented')
                    return
                end
            end
            differentialEpochs = epochNum;
        elseif ischar(differentialEpochs)
            differentialEpochs = find(strcmp(Z.stimulus.params.epochName), differentialEpochs);
        end
    elseif isnumeric(differentialEpochs)
        % Back compatible with previous versions that did a first row vs
        % second row comparison
        if size(differentialEpochs, 1) > 1
            differentialEpochs = differentialEpochs(2, :);
        end
    end
    
    imageCropPixelBorder = 0;    
    imgSize = size(imgFrames);
    meanImageFrames = mean(imgFrames, 3);
    epochs = fields(triggerInds);
    epoch_nums = cellfun(@(epoch) str2num(epoch(epoch>='0' & epoch<='9')), epochs);

    differentialImages = zeros(imgSize(1), imgSize(2), size(differentialEpochs, 2));

    for diffEpochInd = size(differentialEpochs, 2):-1:1
%         if ~any(epoch_nums==differentialEpochs(1, diffEpochInd))
%             warning(['Epoch ' num2str(differentialEpochs(1, diffEpochInd)) ' not found in the photodiode data']);
%             differentialImages(:, :, diffEpochInd) = [];
%             continue;
%         end
        if ~any(epoch_nums==differentialEpochs(1, diffEpochInd))
            warning(['Epoch ' num2str(differentialEpochs(1, diffEpochInd)) ' not found in the photodiode data']);
            differentialImages(:, :, diffEpochInd) = [];
            continue;
        end
%         epochBase = differentialEpochs(1, diffEpochInd);
        epochOpposite = differentialEpochs(1, diffEpochInd);

        boundsOpposite = triggerInds.(['epoch_' num2str(epochOpposite)]).bounds;
        boundsBase = [];
        for i = 1:size(boundsOpposite, 2)
            indBefore = boundsOpposite(1, i)-1;
            indexBoundsBase = cellfun(@(epochField) sum(find([true triggerInds.(epochField).bounds(1, :)<=indBefore & triggerInds.(epochField).bounds(2, :)>=indBefore]))-2, epochs);
            boundsBase = [boundsBase triggerInds.(epochs{indexBoundsBase>0}).bounds(:, indexBoundsBase(indexBoundsBase>0))];
        end
        
        % Take ceil and floor because the full image won't see the stimulus
        % until after the frame that got the PD signal and it will have lost
        % the stimulus right before the frame that got the PD signal
        finalBoundsBase = zeros(size(boundsBase));
        finalBoundsBase(1, :) = ceil(boundsBase(1, :));
        finalBoundsBase(2, :) = floor(boundsBase(2, :));
        finalBoundsOpposite = zeros(size(boundsOpposite));
        finalBoundsOpposite(1, :) = ceil(boundsOpposite(1, :));
        finalBoundsOpposite(2, :) = floor(boundsOpposite(2, :));

        % Works because we'll take all the indexes between the top row values
        % and the bottom row values; add one for each column because
        % subtraction isn't inclusive of both bounds
        indexesBase = zeros(sum(diff(finalBoundsBase))+size(finalBoundsBase, 2), 1);
        indexesOpposite = zeros(sum(diff(finalBoundsOpposite))+size(finalBoundsOpposite, 2), 1);

        % Loop through to create the base indexes
        indexInd = 1;
        for boundsBaseLoop = finalBoundsBase
            bounds = boundsBaseLoop(1):boundsBaseLoop(2);
            indexesBase(indexInd:indexInd+length(bounds)-1) = bounds;
            indexInd = indexInd + length(bounds);
        end

        % Loop through to create the opposite indexes
        indexInd = 1;
        for boundsOppositeLoop = finalBoundsOpposite
            bounds = boundsOppositeLoop(1):boundsOppositeLoop(2);
            indexesOpposite(indexInd:indexInd+length(bounds)-1) = bounds;
            indexInd = indexInd + length(bounds);
        end
    %     
    %     indexesBaseRef = logical([diff(indexesBase)>1; 1]+[diff(indexesBase(2:end))>1; 1; 0]+[diff(indexesBase(3:end))>1; 1; 0; 0]);
        indexesBaseRef = indexesBase;
        epochImageBaseMean = mean(imgFrames(:, :, indexesBaseRef), 3)+1;
        epochImageOppositeMean = mean(imgFrames(:, :, indexesOpposite), 3)+1;
        epochImageBase = epochImageBaseMean - 1;
        epochImageOpposite = epochImageOppositeMean - 1;
        responseDifference = (epochImageOpposite-epochImageBase)./epochImageBase;

        % For when epochImageBase=0, we assume that this pixel is very
        % different
        responseDifference(abs(responseDifference) == Inf) = max(responseDifference(abs(responseDifference)~=Inf));
        % For when both epochImageBase=0 and epochImageOpposite = 0, we assume
        % that they two pixels are pretty similar
        responseDifference(isnan(responseDifference)) = 0;
        differentialImages(:, :, diffEpochInd) = responseDifference;
        
        % Save index bounds to upperIndices and lowerIndices
        upperInds{diffEpochInd} = indexesBase;
        lowerInds{diffEpochInd} = indexesOpposite;        
    end  
    
    Z.diffEp.differentialImages = differentialImages;
    Z.diffEp.upperInds = upperInds;
    Z.diffEp.lowerInds = lowerInds;
    
end