% use 10 minutes to find the newest data set for those path...
%given file path, first, find the flickerPath
%% 1. Select Path
% Create folder path for flick - master folder specified by
% dataPath.csv, subfolder reflecting date of extraction.
function [path] = AutoLogKernelPath(filename,logName,path) % determine the way you create th

S = GetSystemConfiguration;
% I-> kernel
folder = S.flickerSavePath;
% I->kernel->filename;
folderPath = sprintf('%s/twoPhoton/%s/',folder,filename);
% I -> kernel -> filename -> logName.m
fullLogName = [folderPath,logName,'.m'];
FindFlickKernelPath_WriteLog(fullLogName,path);

end