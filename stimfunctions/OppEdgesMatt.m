function [texStr,stimData] = OppEdgesMatt(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

    %when choosing noise values for the sine wave make sure that:
    %noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
    %this insures that 3 std of the noise keeps you below a luminence of 1

%    sii = Q.stims.currStimNum;
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    if p.numDeg == 0
        sizeX = 1;
    else
        sizeX = round(360/p.numDeg);
    end

    mlum = p.lum;

    c = p.contrast;
    
    pol = p.pol;

    vel = abs(p.velocity);
    signVel = sign(p.velocity);
    
    barWidth= 2*p.distBetweenEdges; 
    half=floor(barWidth/2);

    framesPerUp = p.framesPerUp;

    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;

    bitMap = zeros(1,sizeX,framesPerUp)-1;
    for cc = 1:framesPerUp
        for pp = 0:barWidth:sizeX-barWidth
            b=ceil(hzFrame(cc)*(vel/(60*framesPerUp)));
            if b>=barWidth
               b=mod(b,barWidth); 
            end  
            if b<=half 
                bitMap(1,pp+barWidth-b:pp+barWidth,cc) = 1; 
                bitMap(1,pp+1+b:pp+half,cc)= 1;
            else
                bitMap(1,pp+b:pp+barWidth,cc) = 1;
                bitMap(1,pp+barWidth-b:pp+half,cc) = 1;
            end
        end
        
        bitMap(:,:,cc) = bitMap(:,:,cc)*signVel;
    end
    
    bitMap = mlum*(1 + pol*c*bitMap);
    
    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end