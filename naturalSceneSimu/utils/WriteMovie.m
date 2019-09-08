function WriteMovie(bitMap,Q)
    movForMin = 64; % minimum pixels required by movie format in a diminsion
    % consider changing this to input aspect ratio if you want to keep the
    % relative sizes of objects in your movie the same
    aspectRatio = 10*16/9; % aspect ration, X/Y

    minX = round(movForMin*aspectRatio);
    minY = movForMin;
    
    frame = bitMap(:,:,1);
    sizeY = size(frame,1);
    sizeX = size(frame,2);
    
    tooSmallY = sizeY<minY;
    tooSmallX = sizeX<minX;
    
    % stretch the video to take the set aspect ratio while satisfying
    % minimum requirements of the video format
    switch tooSmallY
        case 0
            switch tooSmallX
                case 0 % Y is big, X is big
                    % not too small, do nothing
                case 1 % Y is big, X is small
                    % stretch X to sizeY*aspectRatio
                    frame = imresize(frame,[sizeY sizeY*aspectRatio],'nearest');
            end
        case 1
            switch tooSmallX
                case 0 % Y is small, X is big
                    % stretch Y to sizeX
                    frame = imresize(frame,[sizeX/aspectRatio sizeX],'nearest');
                case 1 % Y is small, X is small
                    % stretch X and Y to minX and minY respectively
                    frame = imresize(frame,[minY minX],'nearest');
            end
    end
    
    writeVideo(Q.handles.movie,frame);
end