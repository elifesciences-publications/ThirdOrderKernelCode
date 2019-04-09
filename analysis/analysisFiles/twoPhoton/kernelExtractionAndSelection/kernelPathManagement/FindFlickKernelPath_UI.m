function path = FindFlickKernelPath_UI(folderPath)
% sometimes, the information are missing, you have to deal with that...
flickFolderSpec = [folderPath,'flick*.mat'];
[flickName,flickPathName]= uigetfile(flickFolderSpec,'select a flicker path');
flickStr = [flickPathName,flickName];

if flickName == 0
    flickStr = 'NA';
end

firstkernelFolderSpec = [folderPath,'first*.mat'];
[firstkernelName,firstkernelPathName]= uigetfile(firstkernelFolderSpec,'select a firstkernel path');
firstkernelStr = [firstkernelPathName,firstkernelName];

if firstkernelName == 0
    firstkernelStr = 'NA';
end

firstnoiseFolderSpec = [folderPath,'firstnoise*.mat'];
[firstnoiseName,firstnoisePathName]= uigetfile(firstnoiseFolderSpec,'select a firstnoise path');
firstnoiseStr = [firstnoisePathName,firstnoiseName];

if firstnoiseName == 0
    firstnoiseStr = 'NA';
end

secondkernelFolderSpec = [folderPath,'second*.mat'];
[secondkernelName,secondkernelPathName]= uigetfile(secondkernelFolderSpec,'select a secondkernel path');
secondkernelStr = [secondkernelPathName,secondkernelName];

if secondkernelName == 0
    secondkernelStr = 'NA';
end

secondnoiseFolderSpec = [folderPath,'secondnoise*.mat'];
[secondnoiseName,secondnoisePathName]= uigetfile(secondnoiseFolderSpec,'select a secondnoise path');
secondnoiseStr = [secondnoisePathName,secondnoiseName];

if secondnoiseName == 0
    secondnoiseStr = 'NA';
end

% firstOLSMatFolderSpec = [folderPath,'OLSMat_first*.mat'];
% [firstOLSMatName,firstOLSMatPathName]= uigetfile(firstOLSMatFolderSpec,'select a first OLSMat path');
% firstOLSMatStr = [firstOLSMatPathName,firstOLSMatName];
% 
% if firstOLSMatName == 0
%     firstOLSMatStr = 'NA';
% end
% 
% firstkernelNewFolderSpec = [folderPath,'firstOLS*.mat'];
% [firstkernelNewName,firstkernelNewPathName]= uigetfile(firstkernelNewFolderSpec,'select a firstkernelNew path');
% firstkernelNewStr = [firstkernelNewPathName,firstkernelNewName];
% 
% if firstkernelNewName == 0
%     firstkernelNewStr = 'NA';
% end
% 
% secondOLSMatFolderSpec = [folderPath,'OLSMat_second*.mat'];
% [secondOLSMatName,secondOLSMatPathName]= uigetfile(secondOLSMatFolderSpec,'select a second OLSMat path');
% secondOLSMatStr = [secondOLSMatPathName,secondOLSMatName];
% 
% if secondOLSMatName == 0
%     secondOLSMatStr = 'NA';
% end
% 
% secondkernelNewFolderSpec = [folderPath,'secondOLS*.mat'];
% [secondkernelNewName,secondkernelNewPathName]= uigetfile(secondkernelNewFolderSpec,'select a secondkernelNew path');
% secondkernelNewStr = [secondkernelNewPathName,secondkernelNewName];
% 
% if secondkernelNewName == 0
%     secondkernelNewStr = 'NA';
% end

path.flickpath = flickStr;
path.firstkernelpath = firstkernelStr;
path.firstnoisepath = firstnoiseStr;
path.secondkernelpath = secondkernelStr;
path.secondnoisepath = secondnoiseStr;
% path.firstOLSMatpath = firstOLSMatStr;
% path.firstkernelpathNew = firstkernelNewStr;
% path.secondOLSMatpath = secondOLSMatStr;
% path.secondkernelpathNew = secondkernelNewStr;
% add a little more things in the future;
end
