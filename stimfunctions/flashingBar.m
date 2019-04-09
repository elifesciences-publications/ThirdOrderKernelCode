function [texStr,stimData] = flashingBar(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

    %when choosing noise values for the sine wave make sure that:
    %noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
    %this insures that 3 std of the noise keeps you below a luminence of 1

    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    numDeg = p.numDeg;
    sizeX = round(360/numDeg);
    
    backgroundLum = p.backgroundLum;
    
    barMeanLum = p.barMeanLum;
    barContrast = p.barContrast;
    barTemporalFrequency = p.barTemporalFrequency;

    vel = p.velDeg*pi/180; %velocity in rad/s
    width = p.widthDeg*pi/180; %width in rad

    framesPerUp = p.framesPerUp;
    
    if f == 1
        startingLocIn = p.startingLocDeg*pi/180;
        if startingLocIn < 0 || startingLocIn > 2*pi
            stimData.flashingBar.startingLoc = rand()*2*pi;
        else
            stimData.flashingBar.startingLoc = startingLocIn;
        end
    end
    
    startingLoc = stimData.flashingBar.startingLoc;

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    bitMap(1,sizeX,framesPerUp) = 0;
    for ff = 1:framesPerUp
        t = f*(1/60) + ff*(1/(60*framesPerUp));
        bitMap(:,:,ff) = backgroundLum;
        currentLoc = startingLoc + vel*t;
        barStart = mod(currentLoc - width/2,2*pi);
        barEnd = mod(currentLoc + width/2,2*pi);
        
        if barStart < barEnd
            bar = and(theta >= barStart , theta < barEnd);
        else
            bar =  or(theta >= barStart , theta < barEnd);
        end
        
        barValue = sin(barTemporalFrequency*t*2*pi);
        
        bitMap(:,bar,ff) = barMeanLum * (1 + barContrast*barValue);
    end

    texStr.tex = CreateTexture(bitMap,Q);
end