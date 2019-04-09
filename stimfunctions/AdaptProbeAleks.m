function [texStr,stimData] = AdaptProbeAleks(Q)
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
% 
%     if p.numDeg == 0
%         sizeX = 1;
%         sizeY = 1;
%     else
%         sizeX = round(360/p.numDeg);
%         sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
%     end
% 
%     mlumL = p.lumL;
% 
%     cL = p.contrastL;
%     
%     polL = p.polL;
% 
%     velL = p.velocityL; % degree/s into rad/s
%  
%     wnCL = p.wnCL;
%     
%     numBars= p.numBars;
%     numBars2=p.numBars2;
%     barWidth= 360/numBars;
%     half=floor(barWidth/2);
% 
%     framesPerUp = p.framesPerUp;
% 
%     if f == 1
%         stimData.sinPVL = zeros(2,1);
%         
%         if ~isfield(stimData,'sinWNL');
%             stimData.sinWNL = randn(sizeY,sizeX);
%         end
%     end
% 
%     sinWNL = zeros(sizeY,sizeX,framesPerUp);
%     hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
% 
%     theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

%     bitMap = zeros(1,sizeX,framesPerUp)-polL;
    if f<=p.adaptDur
        [texStr,stimData] = Q.stims.stimlookup{Q.stims.currParam.stimtype1}(Q);
    else
        R=Q;
%        R.stims.currParam.stimUpRateL=Q.stims.currParam.stimUpRateL2;
 %       R.stims.currParam.stimUpRateR=Q.stims.currParam.stimUpRateR2;
 %       R.stims.currParam.velUpRateL=Q.stims.currParam.velUpRateL2;
  %      R.stims.currParam.velUpRateR=Q.stims.currParam.velUpRateR2;
   %     R.stims.currParam.wnUpRateL=Q.stims.currParam.wnUpRateL2;
    %    R.stims.currParam.wnUpRateR=Q.stims.currParam.wnUpRateR2;
 %       R.stims.currParam.contrastL=Q.stims.currParam.contrastL2;
%        R.stims.currParam.contrastR=Q.stims.currParam.contrastR2;
        R.stims.currParam.velocityL=Q.stims.currParam.velocityL2;
        R.stims.currParam.velocityR=Q.stims.currParam.velocityR2;
         R.stims.currParam.numBars=Q.stims.currParam.numBars2;
        [texStr,stimData] = Q.stims.stimlookup{Q.stims.currParam.stimtype2}(R); 
    end

%     bitMap = repmat(bitMap,[sizeY,1])*cL;
%     bitMap = 255*mlumL*(1 + bitMap + wnCL*sinWNL);

    %always include this line in a stim function to make the texture from the
    %bitmap

end