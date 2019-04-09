function roisToUse = SelectRoisBySize(timeByRois,roiMask,sizeMinAndMax)
    numRois = size(timeByRois,2);
    roiSize = zeros(1,numRois);

    for rr = 1:numRois
        roiSize(rr) = sum(sum(roiMask==rr));
    end
    
    roisToUse = (roiSize>=sizeMinAndMax(1)) & (roiSize<=sizeMinAndMax(2));
end