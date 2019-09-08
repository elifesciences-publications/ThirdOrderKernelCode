function combinedResp = CombineOpposites(snipMat)
    % move through the cell array average walking and 
    % antisymmetrically average turning
    
    if ~(mod(size(snipMat,1),2) == 1)
        error('to combine opposites you must have an even number of epochs without the interleave');
    end
    
    combinedResp = cell((size(snipMat,1)-1)/2+1,size(snipMat,2));

    % there may be faster ways to do this

    for ff = 1:size(snipMat,2)
        % interleave doesn't change
        combinedResp{1,ff} = snipMat{1,ff};
        
        for ee = 2:2:size(snipMat,1)
            combinedResp{ee/2+1,ff} = zeros(size(snipMat{ee,ff}));
            
            combinedResp{ee/2+1,ff}(:,:,1) = nanmean(cat(3,snipMat{ee,ff}(:,:,1),-snipMat{ee+1,ff}(:,:,1)),3);
            combinedResp{ee/2+1,ff}(:,:,2) = nanmean(cat(3,snipMat{ee,ff}(:,:,2),snipMat{ee+1,ff}(:,:,2)),3);
        end
    end
end