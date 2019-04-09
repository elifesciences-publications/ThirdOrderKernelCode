function [texStr,stimData] = Scint3(Q)

% Flickering two-point correlations with a moving mask

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% Input parameters

framesPerUp = p.framesPerUp;
mLum = p.mLum;
contrast = p.contrast;           
updateRate = p.updateRate;
binarize = p.binarize; 
pixX = p.pixX;
whichGlid = p.whichGlid;
pol = p.pol;
diagDirec = p.diagDirec;

if whichGlid > 10
    varDt = p.varDt;
else
    varDt = [];
end

%% Secondary parameters

btmpWd = floor(360/pixX);                        
lifespan = 60 * framesPerUp/updateRate;
printBitmap = 0; % only reasonable when updateRate = framesPerUp (prints one set of values per flip)
                 % for debugging purposes
                 
%% Parameters associated with each specific glider type

if diagDirec == 0
    dx1 = 0; dx2 = 0; dt1 = 0; dt2 = 0;
    glidOrder = 0;
else
    [ dx1,dx2,dt1,dt2,glidOrder ] = GlidDisp( whichGlid,varDt );
end

maxDispX = max([dx1 dx2]);
maxDispT = max([dt1 dt2]);

%% Setup for first frame - needs to come after glider type specifications

if f == 0
    stimData.age = 0;
    stimData.eta = sqrt(contrast)*randn(maxDispT+1,btmpWd + maxDispX);
    if isfield(stimData,'output')
        stimData = rmfield(stimData,'output');
    end
end


%% Draw the gliders

for q = 1:framesPerUp   
    if stimData.age == 0  
        % roll back old map
        stimData.eta(2:end,:) = stimData.eta(1:end-1,:);

        % generate eta for this update
        stimData.eta(1,:) = sqrt(contrast)*randn(1,btmpWd + maxDispX);
        
        if glidOrder == 0
            for x=maxDispX+1:btmpWd;  
                stimData.output(1,x) = stimData.eta(1,x); 
            end 
        elseif glidOrder == 2
            for x=maxDispX+1:btmpWd;  
                stimData.output(1,x) = stimData.eta(1,x) + pol * stimData.eta(dt1+1,x-dx1); 
            end 
        elseif glidOrder == 3
            for x=maxDispX+1:btmpWd;  
                stimData.output(1,x) = stimData.eta(1,x) + pol * stimData.eta(dt1+1,x-dx1) * stimData.eta(dt2+1,x-dx2); 
            end            
        end 
        
        if binarize
            stimData.output = sign(stimData.output);
        end
        
    end   
    
    if diagDirec == -1
        printOut = fliplr(mLum * (1 + stimData.output));
    else
        printOut = mLum * (1 + stimData.output);
    end    
    
    bitMap(:,:,q) = printOut;
    
%     if f == 100 && binarize == 0
%         keyboard
%     end

    % update saved parameters
    stimData.age = mod(stimData.age+1,lifespan);     
end

if printBitmap
    stimData.mat(1:5) = bitMap(1,4:8,1);
end

%% always include this line in a stim function to make the texture from the
% bitmap
texStr.tex = CreateTexture(bitMap,Q);
end