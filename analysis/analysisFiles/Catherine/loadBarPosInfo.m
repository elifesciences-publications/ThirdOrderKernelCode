function [stimLoc,posTimeStamps]=loadBarPosInfo(dataPath,stimEpochs)

[stimLoc,epochsHighRate]=loadBarPos(dataPath);
stimLoc=stimLoc{1};

posTimeStamps=cell(length(stimEpochs),1);
for k=1:length(posTimeStamps)
    a=find(epochsHighRate==stimEpochs(k));
    b=find(diff(a)>1);
    starts=[a(1); a(b+1)];
    starts=starts(1:end-1);
    ends=[a(b);a(end)];
    ends=ends(1:end-1);
    posTimeStamps{k}=[starts ends];
end
