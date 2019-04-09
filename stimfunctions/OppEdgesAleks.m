function [texStr,stimData] = OppEdgesAleks(Q)
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
        sizeY = 1;
    else
        sizeX = round(360/p.numDeg);
        sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
    end

    mlumL = p.lumL;

    cL = p.contrastL;
    
    polL = p.polL;

    velL = p.velocityL; 
 
    wnCL = p.wnCL;
    
    barWidth= 2*p.lambdaL; 
    half=floor(barWidth/2);

    framesPerUp = p.framesPerUp;

    sinWNL = zeros(sizeY,sizeX,framesPerUp);
    hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;

    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

    bitMap = zeros(1,sizeX,framesPerUp)-1;
    for cc = 1:framesPerUp
        for pp = 0:barWidth:sizeX-barWidth
            if velL > 0
                b=ceil(hzFrame(cc)*(velL/(60*framesPerUp)));
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
                
            else
                velL=-velL;
                b=ceil((hzFrame(cc)-1)*(velL/(60*framesPerUp)));
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
        end
    end

    bitMap = repmat(bitMap,[sizeY,1])*cL;
    bitMap = mlumL*(1 + polL*cL*bitMap + wnCL*sinWNL);
    
    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end