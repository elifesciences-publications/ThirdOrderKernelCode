function [texStr,stimData] = GramSchmidt(Q)
% A modified version of newsome dots that tests whether 3 (+?) lifespan
% dots are the sum of their component correlations

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% parameters

dotWd = p.dotWd;
dotHt = p.dotHt;
framesPerUp = p.framesPerUp;
updateRate = p.updateRate;
frameSpan = (60 * framesPerUp)/updateRate;
density = p.density;
deltaX = p.deltaX; % negative numbers --> leftward velocity
deltaY = p.deltaY; % negative numbers --> upward velocity
mLum = p.mLum; % out of 1
randomizeContrast = p.randomizeContrast; % true/false 
Pol = p.Pol;
noCorr = p.noCorr;
intensity = p.intensity/2;

%% setup

btmpWd = floor(360/dotWd);
btmpHt = floor(2/tand(dotHt));
sumPopulation = ceil(btmpWd*btmpHt*density);

%% initialize dot matrix

% Each dot gets a row. The first column indexes the X axis, second col, Y
% axis, third col, value. Third dimension separates into populations over
% flips

%% update dots

% Initialization so that bitMap draw doesn't fail on first loop. 
if f == 1
    if isfield(stimData,'doubles')
        stimData = rmfield(stimData,{'doubles','jumps','sums'});
    end
    % to prevent dimension change issues between epochs
    stimData.frameAge = 0;
    stimData.doubles(:,1,:) = ceil(rand(2*sumPopulation,1,2)*btmpWd);
    stimData.jumps(:,1,:) = ceil(rand(sumPopulation,1,3)*btmpWd);
    stimData.sums(:,1,:) = ceil(rand(sumPopulation,1,3)*btmpWd);
    stimData.doubles(:,2,:) = ceil(rand(2*sumPopulation,1,2)*btmpHt);
    stimData.jumps(:,2,:) = ceil(rand(sumPopulation,1,3)*btmpHt);
    stimData.sums(:,2,:) = ceil(rand(sumPopulation,1,3)*btmpHt);   
    if ~Pol % Pol = 0 means random polarities
        stimData.doubles(:,3,:) = randn(2*sumPopulation,1,2) > 0;
        stimData.jumps(:,3,:) = randn(sumPopulation,1,3) > 0;
        stimData.sums(:,3,:) = randn(sumPopulation,1,3) > 0;
    else
        stimData.doubles(:,3,:) = Pol;
        stimData.jumps(:,3,:) = Pol;
        stimData.sums(:,3,:) = Pol;
    end      
end

for qq = 1:framesPerUp
    if stimData.frameAge == 0
        if noCorr 
            % completely refresh dot locations for every flip
            stimData.doubles(:,1,:) = ceil(rand(2*sumPopulation,1,2)*btmpWd);
            stimData.jumps(:,1,:) = ceil(rand(sumPopulation,1,3)*btmpWd);
            stimData.sums(:,1,:) = ceil(rand(sumPopulation,1,3)*btmpWd);
            stimData.doubles(:,2,:) = ceil(rand(2*sumPopulation,1,2)*btmpHt);
            stimData.jumps(:,2,:) = ceil(rand(sumPopulation,1,3)*btmpHt);
            stimData.sums(:,2,:) = ceil(rand(sumPopulation,1,3)*btmpHt);   
            if ~Pol
                stimData.doubles(:,3,:) = randn(2*sumPopulation,1,1) > 0;
                stimData.jumps(:,3,:) = randn(sumPopulation,1,1) > 0;
                stimData.sums(:,3,:) = randn(sumPopulation,1,1) > 0;
            else
                stimData.doubles(:,3,:) = Pol;
                stimData.jumps(:,3,:) = Pol;
                stimData.sums(:,3,:) = Pol;
            end 
        else      
            % roll back matrices from last time
            stimData.doubles(:,:,2:end) = stimData.doubles(:,:,1:end-1);
            stimData.jumps(:,:,2:end) = stimData.jumps(:,:,1:end-1);
            stimData.sums(:,:,2:end) = stimData.sums(:,:,1:end-1);

            % Assign X and Y to new populations
            stimData.doubles(:,1,1) = ceil(rand(2*sumPopulation,1,1)*btmpWd);
            stimData.jumps(:,1,1) = ceil(rand(sumPopulation,1,1)*btmpWd);
            stimData.sums(:,1,1) = ceil(rand(sumPopulation,1,1)*btmpWd);
            stimData.doubles(:,2,1) = ceil(rand(2*sumPopulation,1,1)*btmpHt);
            stimData.jumps(:,2,1) = ceil(rand(sumPopulation,1,1)*btmpHt);
            stimData.sums(:,2,1) = ceil(rand(sumPopulation,1,1)*btmpHt);

            % Assign polarities
            if ~Pol
                stimData.doubles(:,3,1) = randn(2*sumPopulation,1,1) > 0;
                stimData.jumps(:,3,1) = randn(sumPopulation,1,1) > 0;
                stimData.sums(:,3,1) = randn(sumPopulation,1,1) > 0;
            else
                stimData.doubles(:,3,1) = Pol;
                stimData.jumps(:,3,1) = Pol;
                stimData.sums(:,3,1) = Pol;
            end
        end

        %% generate bitmap
        
        preMap = ones(btmpHt+4*abs(deltaY),btmpWd+4*abs(deltaX))*mLum;
        % padding by 2*deltaX/Y on either side so that jumps and sums
        % located on the very edge (with have to travel two pixels) don't
        % crash the bitMap (though edges are cut off so they won't be
        % seen). 
        
        % current frame
        for z = 1:2*sumPopulation
            zh = ceil(z/2); % this will lead to repetition of assignment for jumps and sums-
                            % not an issue, since there's no "addition" --
                            % assigning twice is as good as assigning once!
            xd = stimData.doubles(z,1,1); yd = stimData.doubles(z,2,1); pd = stimData.doubles(z,3,1);
            xj = stimData.jumps(zh,1,1); yj = stimData.jumps(zh,2,1); pj = stimData.jumps(zh,3,1);
            xs = stimData.sums(zh,1,1); ys = stimData.sums(zh,2,1); ps = stimData.sums(zh,3,1);
            preMap(yd+2*abs(deltaY),xd+2*abs(deltaX)) = intensity*pd+mLum; 
            preMap(yj+2*abs(deltaY),xj+2*abs(deltaX)) = intensity*pj+mLum;
            preMap(ys+2*abs(deltaY),xs+2*abs(deltaX)) = intensity*ps+mLum;
            % The shift in the premap index here is to account for the
            % border, not related to the shift in time of the dots. 
        end

        % one back
        for z = 1:2*sumPopulation
            zh = ceil(z/2);
            xd = stimData.doubles(z,1,2) - deltaX; yd = stimData.doubles(z,2,2) - deltaY; pd = stimData.doubles(z,3,2);
            xs = stimData.sums(zh,1,2) + deltaX; ys = stimData.sums(zh,2,2) + deltaY; ps = stimData.sums(zh,3,2);
            preMap(yd+2*abs(deltaY),xd+2*abs(deltaX)) = intensity*pd+mLum; 
            preMap(ys+2*abs(deltaY),xs+2*abs(deltaX)) = intensity*ps+mLum;
        end

        % two back
        for zh = 1:sumPopulation
            xj = stimData.jumps(zh,1,3) - 2*deltaX; yj = stimData.jumps(zh,2,3) - 2*deltaY; pj = stimData.jumps(zh,3,3);
            xs = stimData.sums(zh,1,3) + 2*deltaX; ys = stimData.sums(zh,2,3) + 2*deltaY; ps = stimData.sums(zh,3,3);
            preMap(yj+2*abs(deltaY),xj+2*abs(deltaX)) = intensity*pj+mLum;
            preMap(ys+2*abs(deltaY),xs+2*abs(deltaX)) = intensity*ps+mLum;
        end
        
        stimData.preMap = preMap;
    end   
    
    bitMap(:,:,qq) = stimData.preMap((1+2*abs(deltaY)):(btmpHt+2*abs(deltaY)),...
            (1+2*abs(deltaX)):(btmpWd+2*abs(deltaX)));  
    stimData.frameAge = mod(stimData.frameAge+1,frameSpan);
end

texStr.tex = CreateTexture(bitMap,Q);
end