function path = FindFlickKernelPath_ReadLog(fullLogName)
% because it is writing, so you would definitely over write that.
if exist(fullLogName,'file')
    
    % open and write.
    fileID = fopen(fullLogName,'r');
    % content = textscan(fileID,'%s','delimiter','\n');
    % content = content{1};
    
    content = textscan(fileID,'%s');
    pathName = content{1};
    path.flickpath = pathName{1};
    path.firstkernelpath = pathName{2};
    path.firstnoisepath = pathName{3};
    path.secondkernelpathNearest = pathName{4};
    path.secondnoisepath = pathName{5};
    path.secondkernelpathNextNearest = pathName{6};
    % should be next nearest one in the future;;
%     path.firstOLSMatpath = pathName{6};
%     path.firstkernelpathNew = pathName{7};
%     path.secondOLSMatpath = pathName{8};
%     path.secondkernelpathNew = pathName{9};
    fclose(fileID);
else
    warning(['log does not exist, log : ' fullLogName])
end

end