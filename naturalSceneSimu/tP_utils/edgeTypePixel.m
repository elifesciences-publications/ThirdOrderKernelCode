function edgeTypePixel( Z )
% Attempt to segment regions of the image by edge selectivity. This assumes
% that all the edge types have been presented (variable edgeTypes). Note
% that this script requires imgFrame! 

    loadFlexibleInputs(Z);
    
    %%  Get indices associated with different edge presentations.
    nEdges = length(edgeTypes);
    
    %% Activity image based on PEAK, not average
    percentileImg = zeros(imgSize(1),imgSize(2),nEdges);
   
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
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%___Changed by Juyue. At least, 
                % here, the loop go through all the stimulus...
                %% do a little bit of data processing here, to get df/f, and use df/f to estimate the roi...
                percentileThreshold = 0.99;
                percentileImg(m,n,q) = percentileThresh( Z.grab.imgFrames(m,n,indsCat{q}),percentileThreshold);
            end
        end
        percentileImg(:,:,q) = percentileImg(:,:,q) .* Z.grab.windowMask;
        % plot the histogram of the response of one edgeType, and the
        % corresponding image.   
        
    end
    
    % two set of picutures.
    % first, to observe the histogram and the pixels at the same time.
    MakeFigure;
    for q = 1:nEdges
        subplot(2,2,q);
        imshow(percentileImg(:,:,q),[]);
        title(edgeTypes{q});
       % imwrite(uint8(percentileImg(:,:,q)),[edgeTypes{q} '.png']);
    end
    MakeFigure;
    for q = 1:nEdges
        subplot(2,2,q);
        a = percentileImg(:,:,q);
        a = a(:);
        histogram(a);
        title(edgeTypes{q});
    end
    MakeFigure;
    % scatter plot, left light over left dark, left light over right light,
    % right light over right dart, left dark over right dark.
    % there are several good combination;
    epochCompare = [2,1;4,3;1,3;2,4];
    for q = 1:nEdges
        subplot(2,2,q);
        a = percentileImg(:,:,epochCompare(q,1));
        a = a(:);
        b = percentileImg(:,:,epochCompare(q,2));
        b = b(:);
        scatter(a,b,'r.');
        xlabel(edgeTypes{epochCompare(q,1)});
        ylabel(edgeTypes{epochCompare(q,2)});
        title('99th percentile of reponse');
        
    end
end

