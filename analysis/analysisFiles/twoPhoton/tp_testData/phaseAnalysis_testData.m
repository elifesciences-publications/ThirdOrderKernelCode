function Z = phaseAnalysis_testData( Z )
% Generates test data to validate tp_phaseAnalysis

    loadFlexibleInputs
    
    % Create a test movie
    iAxis = [1:1:imgSize(1)];
    jAxis = [1:1:imgSize(2)];
    tAxis = [1:1:imgSize(3)]*1/fs;
    [iMesh jMesh tMesh] = ndgrid(iAxis,jAxis,tAxis);
    omega = 1; % hz
    lambda = 40; % pixels
    dir = [1 1] /sqrt(2);
    movie = cos(2*pi*( (iMesh*dir(1)+jMesh*dir(2)) / lambda - omega*tMesh ));
    
%     figure; 
%     for q = 1:imgSize(3)
%         imagesc(movie(:,:,q));
%         pause(.01);
%     end
    for q = 1:imgSize(3)
        thisFrame = movie(:,:,q);
        movRoll(:,q) = thisFrame(:);
    end
    for q = 1:nRoi
        thisRoi = Z.ROI.roiMasks(:,:,q);
        roiRoll(:,q) = thisRoi(:);
    end

    Z.filtered.roi_avg_intensity_filtered_normalized = movRoll'*roiRoll;
    
end

