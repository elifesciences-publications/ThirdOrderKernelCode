function [numProbeEpochs,probeLength]=loadProbeInfo(dataPath,epochs)


dataArrayProbe = loadProbeFile(dataPath);
numProbeEpochs=0;
for m=2:length(dataArrayProbe)
    if iscell(dataArrayProbe{m}(1)) || isnan(dataArrayProbe{m}(1))
    else
        numProbeEpochs=numProbeEpochs+1;
    end
end

numProbeEpochs=length(dataArrayProbe)-2;
firstStimFrame=find(epochs==numProbeEpochs+1,1);
probeLength=firstStimFrame-1;
