function shortpath = KernelPathManage_DeleteAbsolutePath(fullpath, absolutePath)

% find the part and delete it....
absolutePath(absolutePath == '\') = '/';
startIndex = strfind(fullpath,absolutePath);
if isempty(startIndex)
    absolutePath(absolutePath == '/') = '\';
startIndex = strfind(fullpath,absolutePath);
end
shortpath = fullpath(startIndex + length(absolutePath) :end);
% [~,shortpath] = strtok(fullpath,'/');
end