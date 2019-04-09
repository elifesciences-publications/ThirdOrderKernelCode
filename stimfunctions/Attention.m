function [texStr,stimData] = Attention(Q)

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
deltaY = p.deltaY; % negative numbers --> upward velocity

mLum = p.mLum; % out of 1
focusPol = p.focusPol;
focusCorr = p.focusCorr;
bgCorr = p.bgCorr; 

statBg = 0;
if isfield(p,'statBg')
    statBg = p.statBg;
end

%% derived parameters

frameSpan = 60 * framesPerUp/updateRate;

btmpWd = floor(360/dotWd);
btmpHt = floor(2/tand(dotHt));
numPix = btmpWd * btmpHt; 

focusPopulation = ceil(btmpWd*btmpHt*focusDensity/2);
bgPopulation = ceil(btmpWd*btmpHt*bgDensity/2);
totPop = 2*(2*focusPopulation + bgPopulation);
pNotOverlapped = (1-1/numPix)^(totPop);
forPop = (focusPopulation)*(pNotOverlapped);
bgPop = (focusPopulation + bgPopulation)*(pNotOverlapped);
forVal = focusPol > 0;
bgVal = focusPol < 0;

% The probability that a background pixel overlaps with another background
% pixel or a shadow pixel. Every such overlap results in the loss of TWO
% background-contrast dots. Necessary for contrast scaling. 

%% adjust bg

% adjust the background scaling to account for the effect of the background
% population. Not adjusting for the shadow population because this is
% evenly balanced by the focus population.
if isfield(p,'correctBg')
    if p.correctBg
        mLum = (numPix*mLum - 2*forPop * forVal - 2*bgPop * bgVal) / ...
            ( numPix - 2*(forPop + bgPop) );
    end
end

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
    stimData.focus(:,1,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpWd);
    stimData.shadow(:,1,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpWd);
    stimData.bg(:,1,:) = ceil(rand(bgPopulation,1,deltaT+1)*btmpWd);
    stimData.focus(:,2,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpHt);
    stimData.shadow(:,2,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpHt);      
    stimData.bg(:,2,:) = ceil(rand(bgPopulation,1,deltaT+1)*btmpHt);
    if ~focusPol
        stimData.focus(:,3,:) = randn(focusPopulation,1,deltaT+1) > 0;
        stimData.shadow(:,3,:) = randn(focusPopulation,1,deltaT+1) > 0;
        stimData.bg(:,3,:) = randn(bgPopulation,1,deltaT+1) > 0;
    else
        stimData.focus(:,3,:) = focusPol;
        stimData.shadow(:,3,:) = -focusPol;
        stimData.bg(:,3,:) = -focusPol;
    end
end

%% Cycle through flips

for qq = 1:framesPerUp
    if stimData.frameAge == 0
        
        if focusCorr
            % roll everything back by a frame
            stimData.focus(:,:,2:end) = stimData.focus(:,:,1:end-1);
            stimData.shadow(:,:,2:end) = stimData.shadow(:,:,1:end-1);
             % generate new "now" populations
            stimData.focus(:,1,1) = ceil(rand(focusPopulation,1,1)*btmpWd);
            stimData.shadow(:,1,1) = ceil(rand(focusPopulation,1,1)*btmpWd);
            stimData.focus(:,2,1) = ceil(rand(focusPopulation,1,1)*btmpHt);
            stimData.shadow(:,2,1) = ceil(rand(focusPopulation,1,1)*btmpHt);
             % Assign polarities
            if ~focusPol
                stimData.focus(:,3,1) = sign(randn(focusPopulation,1,1));
                stimData.shadow(:,3,1) = sign(randn(focusPopulation,1,1));
            else
                stimData.focus(:,3,1) = focusPol;
                stimData.shadow(:,3,1) = -focusPol;
            end
        else % regenerate entire matrix, not just "now population"
            stimData.focus(:,1,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpWd);
            stimData.shadow(:,1,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpWd);
            stimData.focus(:,2,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpHt);
            stimData.shadow(:,2,:) = ceil(rand(focusPopulation,1,deltaT+1)*btmpHt);
            if ~focusPol
                stimData.focus(:,3,:) = sign(randn(focusPopulation,1,1));
                stimData.shadow(:,3,:) = sign(randn(focusPopulation,1,1));
            else
                stimData.focus(:,3,:) = focusPol;
                stimData.shadow(:,3,:) = -focusPol;
            end
        end
        
        if ~statBg
            if bgCorr
                % roll everything back by a frame
                stimData.bg(:,:,2:end) = stimData.bg(:,:,1:end-1); 
                % generate new "now" populations
                stimData.bg(:,1,1) = ceil(rand(bgPopulation,1,1)*btmpWd);      
                stimData.bg(:,2,1) = ceil(rand(bgPopulation,1,1)*btmpHt);
                 % Assign polarities
                if ~focusPol
                    stimData.bg(:,3,1) = sign(randn(bgPopulation,1,1));
                else
                    stimData.bg(:,3,1) = -focusPol;
                end
            else 
                stimData.bg(:,1,:) = ceil(rand(bgPopulation,1,deltaT+1)*btmpWd);      
                stimData.bg(:,2,:) = ceil(rand(bgPopulation,1,deltaT+1)*btmpHt);
                if ~focusPol
                    stimData.bg(:,3,:) = sign(randn(bgPopulation,1,deltaT+1));
                else
                    stimData.bg(:,3,:) = -focusPol;
                end
            end
        end

        %% draw the bitmap

        % Along the third dimension, display the first and 1+deltaT'th slice. 
        preMap = mLum * ones(btmpHt+2*abs(deltaY),btmpWd+2*abs(deltaX));
        overlapMap = zeros(btmpHt+2*abs(deltaY),btmpWd+2*abs(deltaX));
        
        for ww = [1 1+deltaT]       
            focusShift = (ww == 1+deltaT);
            for zz = 1:focusPopulation           
                xf = stimData.focus(zz,1,ww) + deltaX*focusShift; yf = stimData.focus(zz,2,ww) + deltaY*focusShift; pf = stimData.focus(zz,3,ww);
                xs = stimData.shadow(zz,1,ww) - deltaX*focusShift; ys = stimData.shadow(zz,2,ww)  - deltaY*focusShift; ps = stimData.shadow(zz,3,ww);
                preMap(yf+abs(deltaY),xf+abs(deltaX)) = ( pf > 0 ); % want bitMap to range from 0 to 1
                preMap(ys+abs(deltaY),xs+abs(deltaX)) = ( ps > 0 );
                overlapMap(yf+abs(deltaY),xf+abs(deltaX)) = overlapMap(yf+abs(deltaY),xf+abs(deltaX)) + 1;
                overlapMap(ys+abs(deltaY),xs+abs(deltaX)) = overlapMap(ys+abs(deltaY),xs+abs(deltaX)) + 1;                
            end            
            
            for vv = 1:bgPopulation
                if bgCorr && (ww == 1 + deltaT)
                    bgShiftX = sign(randn);
                    bgShiftY = sign(randn);
                else
                    bgShiftX = 0;
                    bgShiftY = 0;
                end
                xb = stimData.bg(vv,1,ww) + deltaX*bgShiftX; yb = stimData.bg(vv,2,ww) + deltaY*bgShiftY; pb = stimData.bg(vv,3,ww);
                preMap(yb+abs(deltaY),xb+abs(deltaX)) = ( pb > 0 );
                overlapMap(yb+abs(deltaY),xb+abs(deltaX)) = overlapMap(yb+abs(deltaY),xb+abs(deltaX)) + 1;
            end
        end
        
        overlapMap = (overlapMap <= 1);
        preMap = preMap .* overlapMap + mLum * (1 - overlapMap);   
        stimData.preMap = preMap;
        
    end
    
    bitMap(:,:,qq) = stimData.preMap((1+abs(deltaY)):(btmpHt+abs(deltaY)),...
        (1+abs(deltaX)):(btmpWd+abs(deltaX)));
    
    stimData.frameAge = mod(stimData.frameAge+1,frameSpan);
end
    
stimData.mat(1) = mean(bitMap(:)); % To make sure compensating correctly
texStr.tex = CreateTexture(bitMap,Q);

end