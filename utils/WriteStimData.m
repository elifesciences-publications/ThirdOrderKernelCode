function WriteStimData(Q)
% frame, time, stim number for that frame, then 20 integers describing
% stimulus -- don't necessarily need to be used...
fprintf(Q.handles.stimdata,'%.6f,%d,',[Q.timing.flipt-Q.timing.t0,Q.timing.framenumber]);
fprintf(Q.handles.stimdata,'%d,',Q.stims.currStimNum); % prints epoch data was gathered at
fprintf(Q.handles.stimdata,'%.2f,',Q.stims.stimData.cl(1:10)); % prints 10 closed loop numbers here.
fprintf(Q.handles.stimdata,'%.2f,',Q.stims.stimData.mat(1:min([length(Q.stims.stimData.mat(:)) 20]))); % prints 10 numbers here. first 10 about data second 10 lum values
fprintf(Q.handles.stimdata,'%d,',Q.stims.stimData.flash);
fprintf(Q.handles.stimdata,'\n');
end