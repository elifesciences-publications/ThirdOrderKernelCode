function [babyfilename] = SearchBabyFile(parentfoldername,babyfilename)

% test... whether there are data in this current file.
d = dir([parentfoldername,'*.mat']);
if isempty(d)
    d = dir(parentfoldername);
    
    nfile = length(d);
    remove = [];
    for i = 1:1:nfile
        if strcmp(d(i).name,'.') || strcmp(d(i).name,'..')
            remove = [remove,i];
        end
    end
    d(remove) = [];
    nfile = length(d);
    for i = 1:1:nfile
        parentfoldernameTemp = [parentfoldername,d(i).name,'\'];
        babyfilename = SearchBabyFile(parentfoldernameTemp,babyfilename);
    end
else
    % current folder is a good folder name....
    babyfilename = [babyfilename;parentfoldername];
end
end