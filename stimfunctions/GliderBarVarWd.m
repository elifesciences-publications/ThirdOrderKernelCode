function [texStr,stimData] = GliderBarVarWd(Q)

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
f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% input parameters

whichGlid = p.whichGlid;
framesPerUp = p.framesPerUp;
updateRate = p.updateRate;
    lifespan = 60 * framesPerUp / updateRate; % flips per stimulus update
pixX = p.pixX;
    btmpWd = round(360/pixX);
    cycleWd = 4;
    numFullCycles = floor(btmpWd/cycleWd);
    pixelsOverflow = mod(btmpWd,cycleWd);
diagDirec = p.diagDirec; % one: to the right
pol = p.pol;
reseed = p.reseed;
contrast = p.contrast;
mLum = p.mLum;
grayContrast = p.grayContrast;
glidWd = p.glidWd;

%% Parameters associated with each specific glider type
dx2 = 0; 
dt2 = 0; % in case you are doing 2d gliders, so that maxDisp line still works

switch whichGlid
    case 1 % div 3
        dx1 = 1;
        dx2 = 1;
        dt1 = 1;
        dt2 = 0;
        glidOrder = 3;
    case 2 % con 3
        dx1 = 1;
        dx2 = 0;
        dt1 = 1;
        dt2 = 1;
        glidOrder = 3;
    case 3 % R 2
        dx1 = 1;
        dt1 = 1;
        glidOrder = 2;
    case 4 % elbow
        dx1 = 1;
        dx2 = 0;
        dt1 = 1;
        dt2 = 2;
        glidOrder = 3;
    case 5 % late knight
        dx1 = 1;
        dx2 = 1;
        dt1 = 1;
        dt2 = 2;
        glidOrder = 3;
    case 6 % early knight
        dx1 = 0;
        dx2 = 1;
        dt1 = 1;
        dt2 = 2;
        glidOrder = 3;
end

maxDispX = max([dx1 dx2]);
maxDispT = max([dt1 dt2]);

%% Setup for first frame - needs to come after glider type specifications

if f == 0
    if reseed
        rng(Q.timing.framenumber);
    end
    stimData.age = 0;
    stimData.map = 2*(randi(2,[maxDispT+1,maxDispX+glidWd])-1.5);
    stimData.phase = floor(rand*btmpWd);
end

phase = stimData.phase;
rot = [ zeros(phase,btmpWd-phase) eye(phase,phase);  eye(btmpWd-phase,btmpWd-phase) zeros(btmpWd-phase,phase) ];

%% Generate glider bars

for q = 1:framesPerUp   
    if stimData.age == 0  
        % roll back old map
        stimData.map(2:end,:) = stimData.map(1:end-1,:);
        % generate current output in first column of map
        for x = 1:maxDispX
            stimData.map(1,x) = 2*(randi(2)-1.5);
        end
        if glidOrder == 2
            for x=[ maxDispX+1 : maxDispX+glidWd ] 
                stimData.map(1,x) = pol * stimData.map(dt1+1,x-dx1); 
                % adding 1 to dt because first row of map is "t=0" - the
                % map that will be printed
            end 
        elseif glidOrder ==3
            for x=[ maxDispX+1 : maxDispX+glidWd ] 
                stimData.map(1,x) = pol * stimData.map(dt1+1,x-dx1)*stimData.map(dt2+1,x-dx2); 
            end            
        end       
    end       
    
    if diagDirec == -1
        bars = fliplr(stimData.map(1,end-(glidWd-1):end));
    else
        bars = stimData.map(1,end-(glidWd-1):end);
    end    
    
    core = [ bars grayContrast*ones(1,glidWd) ];
    preMap = [ repmat(core,1,numFullCycles) core(1,1:pixelsOverflow) ];
    preMap = preMap(1,1:btmpWd) * rot;
    bitMap(:,:,q) = mLum * ( 1 + preMap );
    
    % update saved parameters
    stimData.age = mod(stimData.age+1,lifespan);     
end

% if f == 1
%     keyboard
% end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
end

