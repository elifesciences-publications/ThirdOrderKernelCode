function sheds = WatershedMovieAvg( movieFrames, fgThresh )
% Prints out watershed version of average movie. Fills in border regions by
% the nearest watershed center of mass.

    %% Defaults
    shedConnectivityParam = 8; 
    blurShed = 0;
    filtSpan = 15;
    filtSd = 5;
    watershedDebugMode = 0;
  
%     loadFlexibleInputs(Z)
    
    %% Unsharp mask meanImg to remove variations in brightness through 
    %  different parts of the image
    preMeanImg = mean(movieFrames,3); % unfiltered, unwindowed
    preMeanImgBord = ones(size(preMeanImg)+2*filtSpan) * max(preMeanImg(:));
    preMeanImgBord(filtSpan+1:end-filtSpan,filtSpan+1:end-filtSpan) = preMeanImg;
    % Create blurry version
    blurFilt = fspecial('gaussian',2*filtSpan,filtSd); % these are magic params chosen solely by inspection
    blurImage = filter2(blurFilt,preMeanImgBord);
    blurImage = blurImage(filtSpan+1:end-filtSpan,filtSpan+1:end-filtSpan);
    meanImg = preMeanImg - blurImage;
    % Want meanImg to be all positive
    meanImg = meanImg + abs(min(0,min(meanImg(:))));

    if watershedDebugMode
        figure;         
        subplot(1,2,1);
        imagesc(preMeanImg);
        title('Mean image before processing');
        subplot(1,2,2);
        imagesc(meanImg); 
        title('Mean image after unsharp masking');
    end

    %% Watershed selection
    preSeg = watershed(-meanImg,shedConnectivityParam);
    % The negative sign here is intentional! We want to pick out
    % high-activity areas, but watershedding finds valleys, so we invert
    % everything.
    preSeg = double(preSeg);  
    if watershedDebugMode
        borders = (preSeg == 0);
        figure; 
        imagesc(meanImg/max(meanImg(:))*7 + borders);
        title('Watershed regions prior to thresholding and elimination');
    end
    
    %% Compute the brightest pixels within the entire image
    meanImgRestrict = meanImg(:);
    meanImgRestrict = meanImgRestrict(find(meanImgRestrict ~= 0));
    fgThreshVal = percentileThresh( meanImgRestrict, fgThresh );
    fgThreshMask = double( meanImg >= fgThreshVal );
    
    if watershedDebugMode
        fractionRetained = sum(fgThreshMask(:)) / length(meanImgRestrict);
        fractionRetained = round(fractionRetained*100);
        fprintf('\n%i percent of pixels are retained in the foreground mask.\n',fractionRetained);
    end
    
    %% Assign borderline regions to nearest bright pixel   
    [iMesh jMesh] = ndgrid([1:size(meanImg,1)],[1:size(meanImg,2)]);   
    iMesh = iMesh(:); jMesh = jMesh(:);
    for q = 1:max(preSeg(:))
        thisShed = double( preSeg == q );
        thisMask = meanImg .* thisShed;
        thisPeak = find(thisMask == max(thisMask(:)),1);
        peakX(q) = iMesh(thisPeak);
        peakY(q) = jMesh(thisPeak);
        distMap(:,q) = sqrt((iMesh - peakX(q)).^2 + ...
            (jMesh - peakY(q)).^2);
    end
    
    [ distMapMin distMapMinInd ] = min(distMap,[],2);
    distMapMinInd = reshape(distMapMinInd,[size(meanImg,1) size(meanImg,2)]);
    getBorder = double( preSeg == 0 );
    borderAssign = getBorder .* distMapMinInd;
    filledIn = preSeg + borderAssign;
    
    if watershedDebugMode
        figure;
        subplot(3,1,1); imagesc(distMapMinInd); title('Distance Maximum Map');
        subplot(3,1,2); imagesc(preSeg); title('before border fill-in');
        subplot(3,1,3); imagesc(filledIn); title('after border fill-in');
    end
    
    %% filledIn becomes the watershed output
    sheds = filledIn;

end

