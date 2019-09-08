function data = LoadStimulus(stimID, stimDataInfo,pathname)

% given the name and path of the image, 
% return the lumninance of the picture

filename = stimDataInfo(stimID).name;
load([pathname,filename]);

end