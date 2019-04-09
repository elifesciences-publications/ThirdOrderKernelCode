function setScanImageSavePath(savePath)
global state


state.files.savePath=savePath;

updateFullFileName(0);
%cd(p); %VI092410A: REMOVED - scim_savePath() utility created as alternative.
disp(['*** SAVE PATH = ' state.files.savePath ' ***']);






