function [texStr,stimData] = checkerboard(Q)
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
    stimData.flash = false;

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    sizeX = round(360/p.numDeg);
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
    
    
    mlum = p.lum;

    vel = p.vel*pi/180; %velocity in rad/s
    width = p.width; %width in rad


    if f == 1
        % in the first frame of this epoch see whether the sin wave subfields
        % exist. if they don't initialize them. If they already exist they will
        % be used in the normal loop below to be continuous between epochs
        if ~isfield(stimData,'sinPVL')
            stimData.sinPVL = zeros(2,1);
        end
        
        % if ~isfield(stimData,'sinPVR')
        %     stimData.sinPVR = zeros(2,1);
        % end
        %
        % if ~isfield(stimData,'sinWNL');
        %     stimData.sinWNL = randn(sizeY,sizeX);
        % end
        % 
        % if ~isfield(stimData,'sinWNR');
        %      stimData.sinWNR = randn(sizeY,sizeX);
        % end
    end

   framesPerUp = p.framesPerUp;
   
   dutyCycle = p.dutyCycle;
   period = p.period;
   stimData.flash = false;
   if ~isfield(stimData,'periodPosition')
       periodPosition = 1;
   else
       periodPosition = stimData.periodPosition;
   end
   
   positions = char([p.posX p.posY]);
   
   switch positions
       case char([0 0]);
           blockHorizontal = [ones(1,width) zeros(1, width)];
           blockVertical = [ones(1,width) zeros(1, width)]';
       case char([1 0]);
           blockHorizontal = [zeros(1, width) ones(1,width)];
           blockVertical = [ones(1,width) zeros(1, width)]';
       case char([0 1]);
           blockHorizontal = [ones(1,width) zeros(1, width)];
           blockVertical = [zeros(1, width) ones(1,width)]';
       case char([1 1]);
           blockHorizontal = [zeros(1, width) ones(1,width)];
           blockVertical = [zeros(1, width) ones(1,width)]';
   end
   
   numHorizontal = sizeX/(2*width);
   numVertical = sizeY/(2*width);
   horizontalLine = repmat(blockHorizontal, [1 numHorizontal]);
   verticalLine = repmat(blockVertical, [round(numVertical), 1]);
   
   horizontal = repmat(horizontalLine, [sizeY, 1, 3]);
   vertical = repmat(verticalLine, [1, sizeX, 3]);
   
   vertical(sizeY+1:end, :, :) = [];
   
   for cc = 1:framesPerUp
       if periodPosition < period*dutyCycle
           bitMap = 2*(horizontal .* vertical)-1;
       else
           bitMap = -ones(1,sizeX, 3);
       end
   end
   
   if periodPosition < period
       stimData.periodPosition = periodPosition+1;
   else
       stimData.periodPosition = 1;
       stimData.flash = true;
   end
   
   
    



    

    bitMap = 256*mlum*(1 + bitMap)-1;

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end