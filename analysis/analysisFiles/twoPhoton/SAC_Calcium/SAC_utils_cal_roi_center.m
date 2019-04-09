function roi_center = SAC_utils_cal_roi_center(roi_mask)
    n = max(roi_mask(:));
    [nline, nhor] = size(roi_mask);
    
    roi_center = zeros(n, 2);
    
    for ii = 1:1:n
        mask = roi_mask == ii;
        versum = sum(mask, 2);
        roi_center(ii, 1) = ((1:nline) * versum)/sum(versum);
        horsum = sum(mask, 1);
        roi_center(ii, 2) = ((1:nhor) * horsum')/sum(horsum);
    end
end