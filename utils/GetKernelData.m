function [ kernelData ] = GetKernelData( D,OD,q )
% Takes output from grabData and picks out parts necessary for kernel
% extraction. Interpolates response data for high-frequency inputs.
% Interpolation necessary if freqRatio (the ratio of stimulus update to
% response sampling) is greater than 1. If freqRatio is less than one
% (1/n), you can write your stimulus script to re-save the stimulus n
% times, making extra effort here unnecessary--same as freqRatio = 1. There
% is currently no method for dealing with freqRatios that are not n or 1/n.

freqRatio = D.data.params.flickerFreq/60;   

if freqRatio >= 1
    upsampleResp = 1;
    downsampleResp = 0;
elseif freqRatio < 1 &&  (mod(1/freqRatio,1) == 0)
    upsampleResp = 0;
    downsampleResp = 1;
    downsampleRespRatio = 1/freqRatio;
    freqRatio = 1;    
else
    error('This script only works for freqRatio = n or 1/n');
end

interp = D.analysis.analysisParams.interp;
numFiles = OD.numFiles;

preStimTraces = zeros(OD.numData,2,freqRatio,numFiles); % (Time-1,L/R,Time-2,Files)  

%% Pull the right columns out of D.data
     
qRange = find( D.kernelData.whichFile == q );
kernelData.qSize = size(qRange,2); % corresponds to number of flies in this q

preTurnTraces(:,:) = OD.XY(:,qRange,1);
preWalkTraces(:,:) = OD.XY(:,qRange,2);   

for p = 1:freqRatio      
      rIndex = 14+(p-1)*2;   % How it should be
%           rIndex = 14+(p-1)*4; % To get data out of 6/20/14 runs - writing in wrong columns.  
%       rIndex = 5:6;
      preStimTraces(:,:,p) = D.data.stim(:,rIndex:rIndex+1,q);          
end      


%% Line up stimTraces properly

stimTraces = zeros(OD.numData*freqRatio,2);
lvector = zeros(freqRatio,OD.numData);
rvector = zeros(freqRatio,OD.numData);

for p = 1:freqRatio
    lvector(p,:) = preStimTraces(:,1,p)';
    rvector(p,:) = preStimTraces(:,2,p)';
end
stimTraces(:,1) = (reshape(lvector,[1 OD.numData*freqRatio]))';
stimTraces(:,2) = (reshape(rvector,[1 OD.numData*freqRatio]))';    

%% Upsample or downsample response - linear

if upsampleResp    
    turnTraces = zeros(OD.numData*freqRatio,kernelData.qSize); % (Time,Flies) 
    walkTraces = zeros(OD.numData*freqRatio,kernelData.qSize);

    switch interp
        case 'linear'
            for qq = 1:kernelData.qSize
                givenIndex = linspace(1,OD.numData,OD.numData)';
                queryIndex = linspace(1,OD.numData,OD.numData*freqRatio-(freqRatio-1))'; 
                % Wierdness here. Interp1 only wants to assign values in
                % between points, but we want to project a little over the end.
                % Deal with this by having interp do all but this little bit 
                % and then just "stretching" the last value. 
                turnTraces(1:OD.numData*freqRatio-(freqRatio-1),qq) = ...
                    interp1(givenIndex,preTurnTraces(:,qq),queryIndex);
                turnTraces(OD.numData*freqRatio-(freqRatio-2):end,qq) = ...
                    repmat(turnTraces(OD.numData*freqRatio-(freqRatio-1)),freqRatio-1,1);                
                walkTraces(1:OD.numData*freqRatio-(freqRatio-1),qq) = ...
                    interp1(givenIndex,preWalkTraces(:,qq),queryIndex);
                walkTraces(OD.numData*freqRatio-(freqRatio-2):end,qq) = ...
                    repmat(walkTraces(OD.numData*freqRatio-(freqRatio-1)),freqRatio-1,1);
            end
    end 
    
elseif downsampleResp
    turnTraces = zeros(OD.numData/downsampleRespRatio,kernelData.qSize); % (Time,Flies) 
    walkTraces = zeros(OD.numData/downsampleRespRatio,kernelData.qSize);
    for qq = 1:kernelData.qSize
        givenIndex = linspace(1,OD.numData-1,OD.numData)';
        queryIndex = linspace(1,OD.numData-1,OD.numData/downsampleRespRatio)'; 
        turnTraces(:,qq) = interp1(givenIndex,preTurnTraces(:,qq),queryIndex);           
        walkTraces(:,qq) = interp1(givenIndex,preWalkTraces(:,qq),queryIndex); 
    end
    stimTraces(1:OD.numData/downsampleRespRatio,1) = interp1(givenIndex,stimTraces(:,1),queryIndex); 
    stimTraces(1:OD.numData/downsampleRespRatio,2) = interp1(givenIndex,stimTraces(:,2),queryIndex);
    stimTraces = stimTraces(1:OD.numData/downsampleRespRatio,:);
    OD.numData = OD.numData/downsampleRespRatio;
end

%% Break up long experiments

catStimFile = zeros(OD.numData,2,freqRatio); 
for jj = 1:freqRatio   
    catStimFile(:,:,jj) = stimTraces((jj-1)*OD.numData+1:jj*OD.numData,:);
end

catTurnFile = zeros(OD.numData,kernelData.qSize,freqRatio);
catWalkFile = zeros(OD.numData,kernelData.qSize,freqRatio); 

for ii = 1:kernelData.qSize
    for jj = 1:freqRatio   
        catTurnFile(:,ii,jj) = turnTraces((jj-1)*OD.numData+1:jj*OD.numData,ii);
        catWalkFile(:,ii,jj) = walkTraces((jj-1)*OD.numData+1:jj*OD.numData,ii);
    end
end

stimTraces = catStimFile;
turnTraces = catTurnFile;
walkTraces = catWalkFile;

%% Save output

kernelData.numFiles = numFiles;
kernelData.stimTraces = stimTraces;
kernelData.turnTraces = turnTraces;
kernelData.walkTraces = walkTraces;

end

