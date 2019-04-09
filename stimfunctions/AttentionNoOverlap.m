function [texStr,stimData] = AttentionNoOverlap(Q)

% Newsome Dot stimulus. A dot born in frame A appears in frame A and frame
% A+ deltaT, translated by deltaX, deltaY and with a new contrast value determined
% by Hi, Lo, and increment.

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% input parameters

dotWd = p.dotWd;
dotHt = p.dotHt;

framesPerUp = p.framesPerUp;
updateRate = p.updateRate;

focusDensity = p.focusDensity;
bgDensity = p.bgDensity;

deltaT = p.deltaT;
deltaX = p.deltaX; % negative numbers --> leftward velocity

mLum = p.mLum; % out of 1
intensity = p.intensity/2;
focusPol = p.focusPol;
focusCorr = p.focusCorr;
bgCorr = p.bgCorr; 

%% derived parameters

frameSpan = 60 * framesPerUp/updateRate;

btmpWd = floor(360/dotWd);
btmpHt = floor(2/tand(dotHt));
pixels = btmpWd * btmpHt;

focusPopulation = ceil(btmpWd*btmpHt*focusDensity/2);
bgPopulation = ceil(btmpWd*btmpHt*bgDensity/2);

%% initialize dot matrix

% dim 1: dot identity
% dim 2: x, y, val
% dim 3: intercalated populations

if f == 1
    stimData.frameAge = 0;
    if isfield(stimData,'focus')
        stimData = rmfield(stimData,{'focus','shadow','bg'});
    end
    % random initialization
    for zz = 1:deltaT+1       
        allPerm = randperm(pixels);
        focusPerm = allPerm(1:focuspopulation);
        stimData.predFocus(:,zz) = focusPerm + deltaX;
        restPerm = cutPermute(allPerm,stimData.predFocus(:,zz));
        restPerm = restPerm(1:focusPopulation+bgPopulation);
        stimData.predShadow(:,zz) = restPerm(1:focusPopulation) - deltaX;
        stimData.predBg(:,zz) = restPerm(focusPopulation+1:focusPopulation+bgPopulation) - deltaX;

        getX = @(x) mod(x,btmpWd) + 1;
        getY = @(y) ceil(y/btmpWd); 

        stimData.focus(:,1,zz) = getX(focusPerm);
        stimData.shadow(:,1,zz) = getX(restPerm(1:focusPopulation));
        stimData.bg(:,1,zz) = getX(restPerm(focusPopulation+1:focusPopulation+bgPopulation);
        stimData.focus(:,2,zz) = getY(focusPerm);
        stimData.shadow(:,2,zz) = getY(restPerm(1:focusPopulation));
        stimData.bg(:,2,zz) = getY(restPerm(focusPopulation+1:focusPopulation+bgPopulation);
    end
    
    if ~focusPol
        stimData.focus(:,3,:) = 2*(randn(focusPopulation,1,deltaT+1) > 0) - .5;
        stimData.shadow(:,3,:) = 2*(randn(focusPopulation,1,deltaT+1) > 0) - .5;
        stimData.bg(:,3,:) = 2*(randn(bgPopulation,1,deltaT+1) > 0) - .5;
    else
        stimData.focus(:,3,:) = focusPol;
        stimData.shadow(:,3,:) = -focusPol;
        stimData.bg(:,3,:) = -focusPol;
    end
    
end

%% Cycle through flips

for qq = 1:framesPerUp
    if stimData.frameAge == 0
        % roll everything back
        stimData.focus(:,:,2:end) = stimData.focus(:,:,1:end-1);
        stimData.shadow(:,:,2:end) = stimData.shadow(:,:,1:end-1);
        stimData.bg(:,:,2:end) = stimData.bg(:,:,1:end-1); 
        stimData.predFocus(:,2:end) = stimData.predFocus(:,1:end-1);
        stimData.predShadow(:,2:end) = stimData.predShadow(:,1:end-1);
        stimData.predBg(:,2:end) = stimData.predBg(:,1:end-1);
        
        if focusCorr
            regenFocus = [ 1 ];
        else
            regenFocus = [ 1 deltaT+1 ]
        end
        
        for zz = regenFocus
            % generate new "now" populations. Locations drawn from those
            % not excluded by predFocus/Shadow/Bg. This is the
            % same process done in initialization, but with an additional
            % restriction on the "starting material"
            focusPerm = cutPermute(allPerm,[stimData.predFocus(:,deltaT+1) stimData.predRest(:,deltaT+1)]);
            focusPerm = focusPerm(1:focusPopulation);
            restPerm = cutPermute(allPerm,[stimData.predFocus(:,deltaT+1) stimData.predRest(:,deltaT+1) focusPerm]);                       
            stimData.focus(:,1,zz) = getX(focusPerm);
            stimData.shadow(:,1,zz) = getX(restPerm(1:focusPopulation));
            stimData.focus(:,2,zz) = getY(focusPerm);
            stimData.shadow(:,2,zz) = getY(restPerm(1:focusPopulation));
            % save overlap parameters
            stimData.predFocus(:,zz) = focusPerm + deltaX;
            stimData.predShadow(:,zz) = restPerm(1:focusPopulation) - deltaX;
            
            % Assign polarities
            if ~focusPol
                stimData.focus(:,3,zz) = 2*(randn(focusPopulation,1,1) > 0)-.5;
                stimData.shadow(:,3,zz) = 2*(randn(focusPopulation,1,1) > 0)-.5;
            else
                stimData.focus(:,3,zz) = focusPol;
                stimData.shadow(:,3,zz) = -focusPol;
            end
        end
        
        if bgCorr
            regenBg = [ 1 ];
        else
            regenBg = [ 1 deltaT+1 ];
        end
        
        for zz = regenBg
            % generate new "now" populations
            stimData.bg(:,1,zz) = ceil(rand(bgPopulation,1,1)*btmpWd);      
            stimData.bg(:,2,zz) = ceil(rand(bgPopulation,1,1)*btmpHt);
             % Assign polarities
            if ~focusPol
                stimData.bg(:,3,zz) = 2*(randn(bgPopulation,1,1) > 0)-.5;
            else
                stimData.bg(:,3,zz) = -focusPol;
            end
        end

        %% draw the bitmap

        % Along the third dimension, display the first and 1+deltaT'th slice. 
        preMap = ones(btmpHt+2*abs(deltaY),btmpWd+2*abs(deltaX))*mLum;
        
        for ww = [1 1+deltaT]       
            for zz = 1:focusPopulation           
                xf = stimData.focus(zz,1,ww); yf = stimData.focus(zz,2,ww); pf = stimData.focus(zz,3,ww);
                xs = stimData.shadow(zz,1,ww); ys = stimData.shadow(zz,2,ww); ps = stimData.shadow(zz,3,ww);
                preMap(yf+abs(deltaY),xf+abs(deltaX)) = intensity*pf+mLum; 
                preMap(ys+abs(deltaY),xs+abs(deltaX)) = intensity*ps+mLum;
            end            
            
            for vv = 1:bgPopulation
                xb = stimData.bg(vv,1,ww); yb = stimData.bg(vv,2,ww); pb = stimData.bg(vv,3,ww);
                preMap(yb+abs(deltaY),xb+abs(deltaX)) = intensity*pb+mLum; 
            end
        end
        
        stimData.preMap = preMap;
        
        %% shift the dots just drawn so that they will appear shifted next time
                
        for zz = 1:focusPopulation           
            stimData.focus(zz,1,ww) = stimData.focus(zz,1,ww) + deltaX;
            stimData.focus(zz,2,ww) = stimData.focus(zz,2,ww) + deltaY;
            stimData.shadow(zz,1,ww) = stimData.shadow(zz,1,ww) - deltaX;
            stimData.shadow(zz,2,ww) = stimData.shadow(zz,2,ww) - deltaY;
        end            
            
        if bgCorr           
            for vv = 1:bgPopulation
                stimData.bg(vv,1,ww) = stimData.bg(vv,1,ww) - deltaX;
                stimData.bg(vv,2,ww) = stimData.bg(vv,2,ww) - deltaY;
            end
        end
                
    end
    
    bitMap(:,:,qq) = stimData.preMap((1+abs(deltaY)):(btmpHt+abs(deltaY)),...
        (1+abs(deltaX)):(btmpWd+abs(deltaX)));
    stimData.frameAge = mod(stimData.frameAge+1,frameSpan);
end

texStr.tex = CreateTexture(bitMap,Q);
end