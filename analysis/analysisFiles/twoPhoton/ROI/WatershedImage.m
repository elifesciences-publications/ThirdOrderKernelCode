function sheds = WatershedImage( imageIn )
% Prints out watershed version of average movie. Fills in border regions by
% the nearest watershed center of mass.

    %% Watershed selection
    shedConnectivityParam = 8; 
    preSeg = watershed(-imageIn,shedConnectivityParam);
    % The negative sign here is intentional! We want to pick out
    % high-activity areas, but watershedding finds valleys, so we invert
    % everything.
    preSeg = double(preSeg);  
    
    %% Assign borderline regions to nearest bright pixel   
    [iMesh, jMesh] = ndgrid([1:size(imageIn,1)],[1:size(imageIn,2)]);   
    iMesh = iMesh(:); jMesh = jMesh(:);
    for q = 1:max(preSeg(:))
        thisShed = double( preSeg == q );
        thisMask = imageIn .* thisShed;
        thisPeak = find(thisMask == max(thisMask(:)),1);
        peakX(q) = iMesh(thisPeak);
        peakY(q) = jMesh(thisPeak);
        distMap(:,q) = sqrt((iMesh - peakX(q)).^2 + ...
            (jMesh - peakY(q)).^2);
    end
    
    [ distMapMin, distMapMinInd ] = min(distMap,[],2);
    distMapMinInd = reshape(distMapMinInd,[size(imageIn,1) size(imageIn,2)]);
    getBorder = double( preSeg == 0 );
    borderAssign = getBorder .* distMapMinInd;
    filledIn = preSeg + borderAssign;
    
    %% filledIn becomes the watershed output
    sheds = filledIn;

end

