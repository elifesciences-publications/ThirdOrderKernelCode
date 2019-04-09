function [folderInfo] = SearchFolder(parentfoldername)
% just get all the folder without .. and . in front of them.

d = dir(parentfoldername);

nfile = length(d);
remove = [];
for i = 1:1:nfile
    if strcmp(d(i).name,'.') || strcmp(d(i).name,'..')
        remove = [remove,i];
    end
end
d(remove) = [];
folderInfo = d;