
stimData.cl(1) = mod(floor(Q.timing.framenumber/(Q.stims.duration/5)),5)+1;

% input is in dots / frame
% multiply by 60 frames / sec to get dots / sec
% multiply by 2*pi radians / cycle
% each ball is 1/4 inch diameter so divide 1000*1/4*pi dots / cycle
% end with radians / sec
vFor = Q.flyTimeline.curFlyStates.mdy;
vFor = vFor(stimData.cl(1))*(60*2*pi/(1000*1/4*pi));

% input is in degrees / frame
% multiply by pi radians / 180 degrees
% multiply by 60 frames / sec
% end with radians / sec
vTheta = Q.flyTimeline.curFlyStates.vtheta;
vTheta = vTheta(stimData.cl(1))*pi/180;

switch p.CLmapType
    case 0
        % do nothing
    
    case 1
        % flicker is closed loop with walking speed
        flickL = UpdateLoop(vFor,p.inLowLimitL,p.inHighLimitL,p.outLowLimitL,p.outHighLimitL);
        flickR = UpdateLoop(vFor,p.inLowLimitR,p.inHighLimitR,p.outLowLimitR,p.outHighLimitR);
        stimData.cl(2) = flickL;
        stimData.cl(3) = flickR;
    
    case 2
        % trans motion is closed loop with walking speed
        dirWalk = sign(vFor - p.zeroOffset);
        motL = UpdateLoop(vFor,p.inLowLimitL,p.inHighLimitL,p.outLowLimitL,p.outHighLimitL);
        motR = UpdateLoop(vFor,p.inLowLimitR,p.inHighLimitR,p.outLowLimitR,p.outHighLimitR);
    
        dirXL = -1*dirXL*dirWalk;
        dirXR = dirXR*dirWalk;
        
        stimData.cl(2) = motL;
        stimData.cl(3) = motR;
        stimData.cl(4) = dirXL;
        stimData.cl(5) = dirXR;
    
    case 3
        % sine wave velocity is closed loop with walking speed
        velL = UpdateLoop(vFor,p.gainL,p.offsetL);
        velR = UpdateLoop(vFor,p.gainR,p.offsetL);
        
        stimData.cl(2) = velL;
        stimData.cl(3) = velR;
    
    case 4
        % sine wave velocity is closed loop with turning speed
        velL = UpdateLoop(vTheta,p.gainL,p.offsetL);
        velR = UpdateLoop(vTheta,p.gainR,p.offsetL);
        
        stimData.cl(2) = velL;
        stimData.cl(3) = velR;
    
    case 5
        % phase offset (sin4p) is closed loop with walking speed
        phaseOffsetL = UpdateLoop(vFor,p.inLowLimitL,p.inHighLimitL,p.outLowLimitL,p.outHighLimitL);
        phaseOffsetR = UpdateLoop(vFor,p.inLowLimitR,p.inHighLimitR,p.outLowLimitR,p.outHighLimitR);
        
        stimData.cl(2) = phaseOffsetL;
        stimData.cl(3) = phaseOffsetR;
        
    case 6
        % mean luminance is closed loop with turning speed
        mlumL = UpdateLoop(vTheta,p.inLowLimitL,p.inHighLimitL,p.outLowLimitL,p.outHighLimitL);
        mlumR = UpdateLoop(vTheta,p.inLowLimitR,p.inHighLimitR,p.outLowLimitR,p.outHighLimitR);
        
        stimData.cl(2) = mlumR;
        stimData.cl(3) = mlumR;
        
    case 7
        % contrast fequency (sin4p) is closed loop with walking speed
        contFreqL = UpdateLoop(vFor,p.gainL,p.offsetL);
        contFreqR = UpdateLoop(vFor,p.gainR,p.offsetR);
        
        stimData.cl(2) = contFreqL;
        stimData.cl(3) = contFreqR;
    case 8
        % contrast fequency (sin4p) is closed loop with walking speed
        % assumes a lambda of 30 degress or pi/6 radians
        contFreqL = UpdateLoop(vFor,p.gainL,p.offsetL)*pi/6;
        contFreqR = UpdateLoop(vFor,p.gainR,p.offsetR)*pi/6;
        
        stimData.cl(2) = contFreqL;
        stimData.cl(3) = contFreqR;
end