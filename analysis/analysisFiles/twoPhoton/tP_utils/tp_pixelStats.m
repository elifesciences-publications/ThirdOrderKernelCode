function [ output_args ] = tp_pixelStats( Z )
% Understanding the statistics of the pixels in a movie to see the effect
% our edgeTypeRoi script is having. 

    percentileKeep = .98;
    edgeTypes = { 'Left Light Edge','Left Dark Edge','Right Light Edge', ...
        'Right Dark Edge' };
    nEdges = length(edgeTypes);
    
    loadFlexibleInputs(Z);
    
    %% Narrow down the pixels used to ones that respond to square left or
    % square right, because otherwise carrying around huge matrix.
    squareLeftInds = getEpochInds(Z,'Square Left');
    squareLeftInds = cat(1,squareLeftInds{1},squareLeftInds{2});
    squareRightInds = getEpochInds(Z,'Square Right');
    squareRightInds = cat(1,squareRightInds{1},squareRightInds{2});
    % Make maps of average activity during these epochs
    squareLeftImg = mean(Z.grab.imgFrames(:,:,squareLeftInds),3);
    squareRightImg = mean(Z.grab.imgFrames(:,:,squareRightInds),3);
    % Find top (percentileKeep)th percentile of responders to each
    leftThresh = percentileThresh(squareLeftImg,percentileKeep);
    leftKeep = squareLeftImg .* (squareLeftImg > leftThresh);
    rightThresh = percentileThresh(squareRightImg,percentileKeep);
    rightKeep = squareRightImg .* (squareRightImg > rightThresh);
    % Keep pixels above threshold for either
    allKeep = (leftKeep + rightKeep) ~= 0;
    figure; imagesc(allKeep);
    allKeep = find(allKeep);
    
    %% Of these pixels, get responses to each edge type
    for q = 1:nEdges
        % Grabbing the frames in which the edge types occurred
        controlEpochInds{q} = getEpochInds(Z, edgeTypes{q});
        indsCat{q} = [];
        for r = 1:length(controlEpochInds{q})
            % indscat contains all the indexes for those frames in linear
            % form, as opposed to separated into presentations as in
            % controlEpochInds
            indsCat{q} = cat(1,indsCat{q},controlEpochInds{q}{r});
        end
        for m = 1:imgSize(1)
            for n = 1:imgSize(2)
                % percentileImg will contain the value of the pixel at the
                % time point when, if all the time points in the
                % presentation of the given edge type were sorted by
                % intensity, the intensity value would be the
                % percentileThreshold percent of the way through the sorted
                % values
                percentileThreshold = 0.99;
                percentileImg(m,n,q) = percentileThresh( Z.grab.imgFrames(m,n,indsCat{q}),percentileThreshold );
            end
        end        
    end   
    percentileImg = reshape(percentileImg,[imgSize(1)*imgSize(2), nEdges]);
    pixAct = percentileImg(allKeep,:);
    
    %% Plot various distributions
    MakeFigure;
    subplot(2,2,1);
    scatter(pixAct(:,1),pixAct(:,2));
    xlabel('Left Light (\DeltaF/F)'); ylabel('Left Dark (\DeltaF/F)');
    
    subplot(2,2,2);
    scatter(pixAct(:,3),pixAct(:,4));
    xlabel('Right Light (\DeltaF/F)'); ylabel('Right Dark (\DeltaF/F)');
    
    subplot(2,2,3);
    scatter(pixAct(:,1),pixAct(:,3));
    xlabel('Left Light (\DeltaF/F)'); ylabel('Right Light (\DeltaF/F)');
    
    subplot(2,2,4);
    scatter(pixAct(:,2),pixAct(:,4));
    xlabel('Left Dark (\DeltaF/F)'); ylabel('Right Dark (\DeltaF/F)');
    
    keyboard;
%     leftImg = 
    
    % 

end

