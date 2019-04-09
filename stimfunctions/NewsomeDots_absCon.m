function [texStr,stimData] = NewsomeDots_absCon(Q)

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

%% parameters

dotWd = p.dotWd; % don't set these to 0, even on interleaf - makes problems 
% (see right under 'setup' below).
dotHt = p.dotHt;
framesPerUp = p.framesPerUp;
density = p.density;
deltaT = p.deltaT;
deltaX = p.deltaX; % negative numbers --> leftward velocity
deltaY = p.deltaY; % negative numbers --> upward velocity
bg = p.bg; % Not mean luminance - can set arbitrarily.
Hi = p.Hi; % don't make it larger than 255
Lo = p.Lo;
increment = p.incrementContrast; % true/false
randomizeContrast = p.randomizeContrast; % true/false 
noCorr = p.noCorr;
Pol = p.Pol;

%% setup

% stimData.mat = zeros(3,50,8);
% s([1 2],1:end/2,3)=[rand(1,25)*bigX

fr = Q.timing.framenumber - Q.timing.framelastchange;
btmpWd = floor(360/dotWd);
btmpHt = floor(2/tand(dotHt));
population = ceil(btmpWd*btmpHt*density/2);

% A little bit of awkwardness here to accomodate deltaT = 0. Because deltaT
% is a dimension of the dots matrix, we set it to one, and then make true
% simul, which changes the sequence of events below. Is there a neater
% way to do this?

simul = 0;

if deltaT == 0
    deltaT = 1;
    simul = 1;
end

if randomizeContrast
    increment = ( rand > .5 );
end

%% initialize dot matrix

% Each dot gets a row. The first column indexes the X axis, second col, Y
% axis, third col, intensity, fourth col, polarity.

% The third dimension separates each population into two to keep
% mean lum consistent. The fourth dimension holds the last 2*deltaT dot
% matrices for retrieval in subsequent calls. 

if fr == 1
    stimData.mat=zeros(population,4,2,deltaT*2);
end

%% update dots

dots = zeros(population,4,2); 

% You need to initialize dots with data for the second subpopulation so
% that the first preMap doesn't fail. Same procedure as done within loop:
if fr ==1
    for ii = 1:deltaT
        dots(:,1,2) = ceil(rand(population,1,1)*btmpWd);
        dots(:,2,2) = ceil(rand(population,1,1)*btmpHt);
        dots(:,3,2) = increment * (Hi) + ( 1 - increment ) * (Lo); 
        if ~Pol
            dots(:,4,2) = Pol;
        else
            dots(:,4,2) = (rand(population,1,1)>.5) * 2 - 1;
        end
        stimData.mat(:,:,:,ii) = dots;
    end
end

bitMap = zeros(btmpHt,btmpWd,framesPerUp);

for k=linspace(1,framesPerUp,framesPerUp);
    
    %% dot info
    q = (fr-1)*framesPerUp+k;
    r = uint8(mod(q-1,2*deltaT)+1);
    first = ( r-1 < deltaT );
    subpop = 2 - first;
    % randomize polarity of dots. While in non-random-pol case Hi and Lo
    % are just scalars, this makes them into vectors with different
    % polarities for different components. At the bottom, we will save Hi 
    % and Lo from this run to use in the next instance of each
    % subpopulation (must save deltaT versions, rolling like the dots
    % matrix).
    
    if noCorr
        
    dots(:,1,1) = ceil(rand(population,1,1)*btmpWd); % pick X coords
    dots(:,2,1) = ceil(rand(population,1,1)*btmpHt); % pick Y coords
    dots(:,3,1) = increment .* (Lo) + ( 1 - increment ) .* (Hi); % set contrast
    if Pol
        dots(:,4,1) = Pol;
    else
        dots(:,4,1) = (rand(population,1,1)>.5) * 2 - 1;
    end
    % generate second population in the exact same way - no correlations
    dots(:,1,2) = ceil(rand(population,1,1)*btmpWd); % pick X coords
    dots(:,2,2) = ceil(rand(population,1,1)*btmpHt); % pick Y coords
    dots(:,3,2) = increment .* (Lo) + ...
        ( 1 - increment ) .* (Hi); % set contrast
    if Pol
        dots(:,4,2) = Pol;
    else
        dots(:,4,2) = (rand(population,1,1)>.5) * 2 - 1;
    end
    
    elseif first && ~simul

    % initialize first subpopulation
    dots(:,1,1) = ceil(rand(population,1,1)*btmpWd); % pick X coords
    dots(:,2,1) = ceil(rand(population,1,1)*btmpHt); % pick Y coords
    dots(:,3,1) = increment .* (Lo) + ( 1 - increment ) .* (Hi); % set contrast
    if Pol
        dots(:,4,1) = Pol;
    else
        dots(:,4,1) = (rand(population,1,1)>.5) * 2 - 1;
    end
    % shift second subpopulation
    dots(:,1,2) = stimData.mat(:,1,2,deltaT) + deltaX; % varies from 1-deltaX to btmpWd+deltaX
    % the tricky thing is whether I'm using stimData.mat right here
    dots(:,2,2) = stimData.mat(:,2,2,deltaT) + deltaY; % varies from 1-deltaY to btmpWd+deltaY
    dots(:,3,2) = increment .* (Hi) + ... 
        ( 1 - increment ) .* (Lo); % set contrast
    dots(:,4,2) = stimData.mat(:,4,1,deltaT);
    
    elseif ~first && ~simul

    % shift first subpopulation
    dots(:,1,1) = stimData.mat(:,1,1,deltaT) + deltaX; % call stimData.mat at deltaT because it hasn't been "rolled" yet
    dots(:,2,1) = stimData.mat(:,2,1,deltaT) + deltaY;
    dots(:,3,1) = increment .* (Hi) + ... 
        ( 1 - increment ) .* (Lo); % set contrast
    dots(:,4,1) = stimData.mat(:,4,1,deltaT);   
    % initialize second subpopulation
    dots(:,1,2) = ceil(rand(population,1,1)*btmpWd);
    dots(:,2,2) = ceil(rand(population,1,1)*btmpHt);
    dots(:,3,2) = increment .* (Lo) + ( 1 - increment ) .* (Hi);
    if Pol
        dots(:,4,2) = Pol;
    else
        dots(:,4,2) = (rand(population,1,1)>.5) * 2 - 1;
    end
    
    elseif simul
    
    % initialize first subpopulation
    dots(:,1,1) = ceil(rand(population,1,1)*btmpWd);
    dots(:,2,1) = ceil(rand(population,1,1)*btmpHt);
    dots(:,3,1) = increment .* (Lo) + ( 1 - increment ) .* (Hi);
    if Pol
        dots(:,4,1) = Pol;
    else
        dots(:,4,1) = (rand(population,1,1)>.5) * 2 - 1;
    end
    % second subpopulation is the shifted/contrast changed version of this
    % one, but they must be presented simultaneously. Does this impact
    % density?
    dots(:,1,2) = dots(:,1,1) + deltaX; % see that the 3rd dim variable is 1
    dots(:,2,2) = dots(:,2,1) + deltaY;
    dots(:,3,2) = increment .* (Hi) + ... 
        ( 1 - increment ) .* (Lo); % set contrast
    dots(:,4,2) = dots(:,4,1);
    
    end
    
    % stim data keeps track of the last 2*deltaT dot matrices, rolling
    stimData.mat(:,:,:,2:end) = stimData.mat(:,:,:,1:end-1);
    stimData.mat(:,:,:,1) = dots;

    %% draw the bitmap

    % In order to take care of border problems, make the bitmap 2 |deltaX|
    % wider than you want it to be and then trim it. This allows for dots
    % to be born off-screen or move off-screen in the second frame, so that the
    % whole image doesn't shift over.

    preMap = ones(btmpHt+2*abs(deltaY),btmpWd+2*abs(deltaX))*bg;

    for z = 1:population % go through all the dots (tot # = population)
        for a = 1:2 % born v. kill subpops
            x = dots(z,1,a);
            y = dots(z,2,a);
            preMap(y+abs(deltaY),x+abs(deltaX)) = dots(z,4,a)*dots(z,3,a);
            % The shift in the premap index here is to account for the
            % border, not related to the shift in time of the dots. 
        end
    end
    
    bitMap(:,:,k) = preMap((1+abs(deltaY)):(btmpHt+abs(deltaY)),...
        (1+abs(deltaX)):(btmpWd+abs(deltaX)));

end
% if Hi ~=127.5
%     keyboard
% end
texStr.tex = CreateTexture(bitMap,Q);
end