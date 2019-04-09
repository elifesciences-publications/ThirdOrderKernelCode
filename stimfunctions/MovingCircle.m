function [texStr,stimData] = MovingCircle(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

    %when choosing noise values for the sine wave make sure that:
    %noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
    %this insures that 3 std of the noise keeps you below a luminence of 1

    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;
    floc = Q.flyloc; % could potentially use this to update the stimulus as well

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    if p.numDeg == 0
        sizeX = 1;
        sizeY = 1;
    else
        sizeX = round(360/p.numDeg);
        sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
    end

    radius = p.radius;
    vel = p.velocity*pi/180;
    circRad = p.circRad;

    framesPerUp = p.framesPerUp;


    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'circPhase')
            stimData.circPhase = 0;
        end
    end

    bitMap(sizeY,sizeX,framesPerUp) = 1;

    for cc = 1:framesPerUp
        stimData.circPhase = stimData.circPhase + vel/(60*framesPerUp);

        for yy = 1:sizeY
            for xx = 1:sizeX
                locX = radius*cos(stimData.circPhase)+sizeX/2;
                locY = radius*sin(stimData.circPhase)+sizeY/2;
                if sqrt((xx-locX).^2+(yy-locY).^2) < circRad
                    bitMap(yy,xx,cc) = -1;
                end
                %bitMap(round((-circRad:circRad) + radius*sin(stimData.circPhase)+sizeY/2),round((-circRad:circRad) + radius*cos(stimData.circPhase)+sizeX/2),cc) = -1;
            end
        end
%         circMask = sqrt((-circRad:circRad)'.^2*(-circRad:circRad).^2)
    end

    bitMap = 0.5*(1 + bitMap);

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end