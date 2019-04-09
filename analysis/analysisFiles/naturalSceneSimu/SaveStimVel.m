function  SaveStimVel(stimID, dataArray, foldername)
% create the filename for the stimulus.
filename = ['DataUnit', num2str(stimID)];
fullname = [foldername,filename];
save(fullname,'dataArray');
end