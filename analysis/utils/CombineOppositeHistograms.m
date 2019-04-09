function combinedResp = CombineOppositeHistograms(snipMat,asymAve)
    % move through the cell array average walking and 
    % antisymmetrically average turning
    
    if nargin<2
        asymAve = 1;
    end
    
    if ~(mod(size(snipMat,1),2) == 0)
        error('to combine opposites you must have an even number of epochs');
    end
    
    combinedResp = cell(size(snipMat,1)/2,size(snipMat,2));

    % there may be faster ways to do this

    for ff = 1:size(snipMat,2)
        for ee = 1:2:size(snipMat,1)
            combinedResp{(ee+1)/2,ff} = zeros(size(snipMat{ee,ff}));

            if asymAve
                combinedResp{(ee+1)/2,ff}(:,:,1) = nanmean(cat(3,snipMat{ee,ff}(:,:,1),flipud(snipMat{ee+1,ff}(:,:,1))),3);
            else
                combinedResp{(ee+1)/2,ff}(:,:,1) = nanmean(cat(3,snipMat{ee,ff}(:,:,1),snipMat{ee+1,ff}(:,:,1)),3);
            end
            
            if size(combinedResp{(ee+1)/2,ff},3) == 2
                combinedResp{(ee+1)/2,ff}(:,:,2) = nanmean(cat(3,snipMat{ee,ff}(:,:,2),snipMat{ee+1,ff}(:,:,2)),3);
            end
        end
    end
end