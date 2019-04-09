function [respByTrial,recordingTimeNew] = MultibarFlicker_alignResponseInRepSeg_ShiftBack(respFull,indSetToZeros,recordingTime)
nSeg = size(respFull,2);
respByTrial = cell(nSeg,1);
recordingTimeNew = false(size(respFull));
for ss = 1:1:nSeg
    % first of all.
    indThis = ~indSetToZeros & recordingTime(:,ss); % only part of it...
    recordingTimeNew(:,ss) = indThis;
    respByTrial{ss} = respFull(indThis,ss);
    
end
%

end