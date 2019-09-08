function folderInfo = GetFolderInfo(path)

foldername = SearchBabyFile(path,[]);

nfolder = size(foldername,1);
folderInfo = cell(1,nfolder);
% go through these folders and collect data from there.

%% first, calculate the number of data inside all interested folder.
for i = 1:1:nfolder
    folderInfo{i}.name = foldername(i,:);
    d = dir([folderInfo{i}.name,'*.mat']);
    folderInfo{i}.nfile = length(d);
end

end
