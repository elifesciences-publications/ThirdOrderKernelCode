function projMovie = differentialImageProject( inMovie, differentialImages, cutThresh, see )
% "Filters" an output movie by weighting each pixel by its value in the sum
% of the differential images. 
%   Inputs:
%       imgFrames: movie to be filtered
%       differentialImages: output from triggeredResponseImages
%       cutThresh: option to truncate meanImg above a certain value, since
%           significance of negative values in differentialImages is a 
%           little unclear. Leaving empty will lead to no thresholding.
%       seeMovie: option to watch input and output movies side-by-side
%   Outputs:
%       outMovie: cleaned up movie
    
    if nargin < 4
        see = 0;
        if nargin < 3
            cutThresh = -Inf;
        end
    end
    
    imageCropPixelBorderRows = round(size(differentialImages, 1)/32);
    imageCropPixelBorderCols = round(size(differentialImages, 2)/32);
    nDI = size(differentialImages,3);
    nFrames = size(inMovie,3);
    meanImg = mean(differentialImages,3);
    meanImg = meanImg / max(max(abs(meanImg(imageCropPixelBorderRows+1:end-imageCropPixelBorderRows, imageCropPixelBorderCols+1:end-imageCropPixelBorderCols))));
    
    for q = 1:nFrames
        projMovie(:,:,q) = inMovie(:,:,q) .* meanImg .* (meanImg > cutThresh);
    end
    
    if see             
        figure; 
        for q = 1:nDI
            subplot(1,nDI,q);
            imagesc(differentialImages(:,:,q));
            thisTitle = sprintf('Differential Images %i',q);
        end           
        figure;
        imagesc(meanImg); title('Mean Differential Image');          
        figure; 
        for q = 1:nFrames
            subplot(1,2,1);
            imagesc(inMovie(:,:,q));
            title('input movie'); 
            subplot(1,2,2);
            imagesc(projMovie(:,:,q));
            title('output movie');
        end
    end                      
end

