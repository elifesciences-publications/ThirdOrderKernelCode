function SaveStimulus(stimID, data, path)
pathname = path.stim;
filename = ['Stim', num2str(stimID)];
fullname = [pathname,filename];
save(fullname,'data');
end