function [stimTimeStamps,stimLengthOneTrial,trialStarts,stimEpochs]=loadStimInfo(dataPath,stimName,numProbeEpochs,probeLength,epochs)

dataArrayStim=loadStimFile(dataPath,stimName);
numStimEpochs=0;
for m=2:length(dataArrayStim)
    if iscell(dataArrayStim{m}(1)) || isnan(dataArrayStim{m}(1))
    else
        numStimEpochs=numStimEpochs+1;
    end
end

stimEpochs=(1:numStimEpochs)+numProbeEpochs;
trialStarts = find(diff([-1;epochs;-1]==stimEpochs(1))==1)';
stimLengthOneTrial=min(diff(trialStarts));

lengthEachEpoch=zeros(length(stimEpochs),1);
for k=1:length(lengthEachEpoch)
    lengthEachEpoch(k)=length(find(epochs((probeLength:probeLength...
        +stimLengthOneTrial))==stimEpochs(k)));
end

stimTimeStamps=[1; cumsum(lengthEachEpoch)];

