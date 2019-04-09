function t0 = photoDiodeSyncSignal(Q)
    Q.windowIDs.active = Q.windowIDs.pano;
    usePhotoDiode = Q.usePhotoDiode;
    Q.usePhotoDiode = true;

    syncWord = '0x16EE';
    syncWordBinary = hexToBinaryVector(syncWord,16);

    flipt = GetSecs();
    i = 1;
    while i < length(syncWordBinary)+1
        Q.stims.stimData.photoDiodeColor = 255*syncWordBinary(i);
        Q.texStr.tex = Screen('MakeTexture', Q.windowIDs.pano, 0, [], 1);
        DrawTexture(Q);

        newFlipt =  Screen('Flip',Q.windowIDs.pano,flipt+1/120);
        if newFlipt - flipt > 20/1000 % missed a flip
            i = 1;
        else
            i = i+1;
        end
        flipt = newFlipt;
    end

    t0 = flipt;
    Q.usePhotoDiode = usePhotoDiode;
end