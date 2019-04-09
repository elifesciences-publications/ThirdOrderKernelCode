function [texStr,stimData] = SineWaveOrthoDirs(Q)
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

    %when choosing noise values for the sine wave make sure that:
    %noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
    %this insures that 3 std of the noise keeps you below a luminence of 1
    
    parameters = {'lum', 'vel', 'lambda', 'numDeg', 'framesPerUp', 'direction', 'range','phase'};
    
    lum = 0.5;
    vel = 30;
    lambda = 30;
    numDeg = 1;
    framesPerUp = 3;
    direction = 0;
    range = 1;
    phase = 0;

    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
    
    for input_param = fieldnames(p)'
        expected_parameter = strcmp(parameters, input_param);
        if any(expected_parameter)
            eval([parameters{expected_parameter} '= p.' input_param{1} ';']);
        end
    end
    
    % In case another file overwrites the phase with a nonvalue >.>
    if isempty(phase)
        phase = 0;
    end
    
    f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
    stimData = Q.stims.stimData;

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    sizeX = round(360/numDeg);
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));
    
    vel = vel*pi/180;
    lambda = lambda*pi/180;

    
    norm_direction = mod(direction, 360);

    %% left eye
    %stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
    %is constant unless noise is added

    if f == 1
%         % in the first frame of this epoch see whether the sin wave subfields
%         % exist. if they don't initialize them. If they already exist they will
%         % be used in the normal loop below to be continuous between epochs
         if ~isfield(stimData,'sinPVL')
            stimData.sinPVL = zeros(2,1);
         end

%         if ~isfield(stimData,'sinPVR')
%             stimData.sinPVR = zeros(2,1);
%         end
% 
%         if ~isfield(stimData,'sinWNL');
%             stimData.sinWNL = randn(sizeY,sizeX);
%         end
% 
%         if ~isfield(stimData,'sinWNR');
%             stimData.sinWNR = randn(sizeY,sizeX);
%         end
    end

%     switch norm_direction
%         case {0, 180}
%             theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
%             bitMap = zeros(1,sizeX,framesPerUp);
%             for cc = 1:framesPerUp
%                 stimData.sinPVL(2) = vel;
%                 stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
%                 
%                 bitMap(1,:,cc) = range*sin(2*pi*(theta-stimData.sinPVL(1))/lambda);
%                 
%                 stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
%             end
%             bitMap = repmat(bitMap,[sizeY,1]);
%         case {90, 270}
%             theta = (0:sizeY-1)/sizeY*2*pi; %theta in radians
%             bitMap = zeros(sizeY, 1, framesPerUp);
%             for cc = 1:framesPerUp
%                 stimData.sinPVL(2) = vel;
%                 
%                 stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
%                 
%                 bitMap(:,1,cc) = range*sin(2*pi*(theta-stimData.sinPVL(1))/lambda);
%                 
%                 stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
%             end
%             bitMap = repmat(bitMap,[1,sizeX]);
%         otherwise
%             disp(norm_direction);
%     end

    bitMap(1,sizeX,framesPerUp) = 0;
    
    if mod(direction-90, 180) ~= 0
        theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
        for cc = 1:framesPerUp
            %x direction is the cos
            stimData.sinPVL(2) = vel*cosd(direction);
            stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
            
            lambda_actual = lambda/cosd(direction);
            

%             shift = tand(direction)*diff(theta(1:2));%tan(dir) = horizontal/vertical; vertical = 1pxl
            
%             for i = 1:abs(sizeY)
                bitMap(1, :, cc) = sin(2*pi*(theta+phase-stimData.sinPVL(1))/lambda_actual);
%                 overall_shift = overall_shift+shift;
%             end

%             bitMap(1,:,cc) = range*sin(2*pi*(theta-stimData.sinPVL(1))/lambda_actual);
            
            
            stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
        end
    else
        %Fill in for vertical movement
        theta = (0:sizeY-1)/sizeX*2*pi; %theta in radians
        bitMap = zeros(sizeY, 1, framesPerUp);
        for cc = 1:framesPerUp
            stimData.sinPVL(2) = vel;
            
            stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
            
            bitMap(:,1,cc) = sin(2*pi*(theta+phase-stimData.sinPVL(1))/lambda);
            
            stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
        end
        bitMap = repmat(bitMap,[1,sizeX]);
    end

    



    
    if range == inf
        bitMap = round(lum*(1+bitMap));
    else
        bitMap = lum*(1 + range*bitMap);
    end

    %always include this line in a stim function to make the texture from the
    %bitmap

    texStr.tex = CreateTexture(bitMap,Q);
end