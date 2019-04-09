function SignalEndOfStimulus(Q)
    for final_frame = 1:21
        % 'But why not have these two if statements in one?' a clever person
        % may ask themselves. I just want to clearly note that I'm adjusting
        % the flash variable which is going to be written out to the
        % stimdata.csv file
        Q.stims.currParam.framesPerUp=3; % Necessary to not trip up CreateTexture
        Q.texStr.tex =  CreateTexture(cat(3, 0, 0, 0),Q);
        if final_frame == 21
            Q.stims.stimData.flash = false;
        else
            Q.stims.stimData.flash = true;
        end
        Q.stims.stimData.photoDiodeColor = 255*Q.stims.stimData.flash;
        DrawTexture(Q);
        %% flip buffers -- v-sync, and across DLPs if possible
        [Q.timing.flipt, ~, ~, Q.timing.missed, ~] = Screen('Flip',Q.windowIDs.pano,Q.timing.flipt+1/120);
        Q.timing.framenumber = Q.stims.duration+final_frame; % it increments no matter what
        Q.stims.currStimNum = 0; %Zero takes the place of the final frames?
        Q.stims.stimData.mat = zeros(size(Q.stims.stimData.mat));
        WriteStimData(Q);
    end
end