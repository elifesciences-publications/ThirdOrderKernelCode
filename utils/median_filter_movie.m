function [ newMov ] = median_filter_movie( inPath, outPath, show, preprocess, truncLen )
% Reads a tiff movie, performs spatial median filtering, and resaves a new
% tiff movie. Border pixels are from the original movie.  
% 
%   Inputs
%       inPath: path (full, a string, ending in '.tif') of the input movie
%       outPath: full path ('.tif') to which to save the filtered movie
%       show: binary flag whether to play the movie back
%       preprocess: choice whether to apply preprocessMat function
%   Outputs
%       newMov: image intensities of new movie in array form
    
    numFrames = tiff_frames( inPath );

    if nargin < 5
        truncLen = numFrames;
    elseif truncLen == 0
        truncLen = numFrames;
    end
    
    if nargin < 4
        preprocess = 1;
    end
    
    if nargin < 3
        see = 0;
    end
    
    for q = 1:truncLen
        oldMov(:,:,q) = imread(inPath,q);
    end
    
    oldMov = double(oldMov);
    if preprocess
        oldMov = preprocessMovie(oldMov);
    end
    
    for q = 1:truncLen
        oldFrame = oldMov(:,:,q);
        newFrame = medfilt2(oldFrame);
        newFrameClip = newFrame(2:end-1,2:end-1);
%         newMov(:,:,q) = oldFrame;
%         newMov(2:end-1,2:end-1,q) = newFrame(2:end-1,2:end-1);
        newMov(:,:,q) = newFrameClip;
    end
    
    delete(outPath);

    maxMax = max(abs(newMov(:)));
    newMov = newMov ./ maxMax * 128 + 128;
    newMov = uint8(newMov);

    for K=1:truncLen
       imwrite(newMov(:, :, K), outPath, 'WriteMode', 'append');
    end

    if show
        figure;
        showMov = imagesc(newMov(:,:,q));
        title('median filtered');
        for q = 2:truncLen
            set(showMov,'Cdata',newMov(:,:,q));
            pause(.02);
        end
    end
end

