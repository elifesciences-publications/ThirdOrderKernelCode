function frames = DetectMotMovie(movie)
    %dMovie = diff(movie,4);
    dMovie = permute(movie(:,:,1,1:4:end),[1 2 4 3]);
    framesIn = size(dMovie,3);
    filtDim = -5:5;
    filtX = normpdf(filtDim,0,2);
    filtY = permute(filtX,[2 1]);
    filtT = permute(filtX,[1 3 2]);
    filt = repmat(filtY*filtX,[1 1 11]);
    filt = bsxfun(@times,filt,filtT);
    dMovie = convn(repmat(dMovie,[1 1 3]),filt,'same');
    dMovie = dMovie(:,:,framesIn+1:2*framesIn);
    
    hv1 = circshift(dMovie,1,3);
    h2 = circshift(dMovie,1,2);
    
    hv3 = dMovie;
    h4 = circshift(h2,1,3);
    
    v2 = circshift(dMovie,1,1);
    v4 = circshift(v2,1,3);
    
    respH = hv1.*h2-hv3.*h4;
    respV = hv1.*v2-hv3.*v4;
    
    
    numFrames = size(respH,3);
    frames(numFrames) = struct('cdata',[],'colormap',[]);
    
    movieHandle = VideoWriter('D:\Documents\motMovie','MPEG-4');
    movieHandle.FrameRate = 45;
    open(movieHandle);

    for ff = numFrames:-1:1
%         if respH(:,:,1,ff) == 0 & respV(:,:,1,ff) == 0
%             continue;
%         end
        
        respHSmall = imresize(respH(:,:,ff),0.20,'method','bilinear');
    	respVSmall = imresize(respV(:,:,ff),0.20,'method','bilinear');
        
        quiver(respHSmall,respVSmall);
        frames(ff) = getframe;
        
        writeVideo(movieHandle,frames(ff));
        
        if ~mod(ff,10)
            disp(['frames ' num2str(ff) ' out of ' num2str(numFrames) ' frames']);
        end
    end
end