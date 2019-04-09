% use 10 minutes to find the newest data set for those path...
%given file path, first, find the flickerPath
%% 1. Select Path
% Create folder path for flick - master folder specified by
% dataPath.csv, subfolder reflecting date of extraction.
function [path] = FindFlickKernelPath_Main(filename,logName,varargin) % determine the way you create th
force_new_log = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii},' = varargin{', num2str(ii + 1), '};']);
end

S = GetSystemConfiguration;
% I-> kernel
folder = S.flickerSavePath;
% I->kernel->filename;
folderPath = sprintf('%s/twoPhoton/%s/',folder,filename);
% I -> kernel -> filename -> logName.m
fullLogName = [folderPath,logName,'.m'];

% before open the file, check whether we have that.
if force_new_log
    % uiget and write log.
    % write a small function on writing and getting filter.
    path = FindFlickKernelPath_UI(folderPath);
    FindFlickKernelPath_WriteLog(fullLogName,path);
    
else
    % if exit the log, open it and read it.
    if exist(fullLogName,'file')
        path = FindFlickKernelPath_ReadLog(fullLogName);
    else
        % if the log does not exit, create a new one and write that.
        path = FindFlickKernelPath_UI(folderPath);
        % before you write anything, check whether the absolute path
        % exists...
        FindFlickKernelPath_WriteLog(fullLogName,path);
    end
    
end