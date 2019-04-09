function [texStr,stimData] = switchDirectionFlicker(Q)

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

%% Input parameters

framesPerFlip = p.framesPerUp;
mLum = p.mLum;
var = p.var; % careful - depending on var value, might go outside possible range,
             % which probably won't be noticeable on your bitMap but will
             % make your statistics different than what you expect.
pixWd = p.pixWd;
flickerFreq = p.flickerFreq;
reseed = p.reseed;

%% Secondary parameters

btmpWd = floor(360/pixWd); % In degrees
lifespan = 60 * framesPerFlip/flickerFreq;
blockLen = 10; %I have no idea whether this is optimal
numBlocks = ceil(btmpWd/blockLen);
blockStarts = [ 1:blockLen:btmpWd+1 ];
blockStarts = [ blockStarts btmpWd+1 ];

%% reseed rng to be consistent between trials
% I'm not sure this works on twoPhoton
if f == 0
    if reseed
        rng(Q.timing.framenumber);
    end
    stimData.vals = 2*sqrt(var)*(randi(2,[1 btmpWd])-1.5);
    stimData.age = 0;
end
 
%% Draw the bitmap
bitMap = zeros(1,btmpWd,framesPerFlip);
stimData.writeColIndex = 0;
for q = 1:framesPerFlip        
    if stimData.age == 0
        stimData.writeColIndex = mod(stimData.writeColIndex + 1,ceil(framesPerFlip/lifespan));
        wc = (stimData.writeColIndex)*(numBlocks+1)+1;
        % Shift val and multiply by polarity, add new val
        stimData.pol = 2*(randi(2)-1.5);
        stimData.dir = 2*sqrt(var)*(randi(2)-1.5); 
        newVal = 2*sqrt(var)*(randi(2)-1.5);
        if stimData.dir > 0
            stimData.vals = [ newVal stimData.vals(1:end-1)*stimData.pol ];
        else
            stimData.vals = [ stimData.vals(1:end-1)*stimData.pol newVal ];
        end
        % Write out: polarity (for easy regression)
        stimData.mat(wc) = stimData.pol;
        stimData.mat(wc+1) = stimData.dir;
        % Encode and record all pixels
        for s = 1:numBlocks
            blockNum = stimData.vals(blockStarts(s):blockStarts(s+1)-1);
            blockBin = (blockNum > 0);
            blockBinStr = num2str(blockBin);
            blockBinStr = blockBinStr(~isspace(blockBinStr));
            blockBinCode = bin2dec(blockBinStr);
            stimData.mat(wc+1+s) = blockBinCode;
        end
    end    
    % Put into bitmap
    bitMap(:,:,q) =  mLum * ( 1 + stimData.vals);
    stimData.age = mod(stimData.age+1,lifespan);
end

texStr.tex = makeTexture(bitMap,Q);
end