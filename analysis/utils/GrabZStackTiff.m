function [zStack, zStackTiff] = GrabZStackTiff(zStackPath)
% Takes in the z stack path (perhaps relative) and grabs the z stack tiff

sysConfig = GetSystemConfiguration;

if zStackPath(2) ~= ':'
    dirFiles = dir(fullfile(sysConfig.twoPhotonDataPathLocal,zStackPath));
    zStackRootPath = sysConfig.twoPhotonDataPathLocal;
    if isempty(dirFiles)
        dirFiles = dir(fullfile(sysConfig.twoPhotonDataPathServer,zStackPath));
        zStackRootPath = sysConfig.twoPhotonDataPathServer;
        if isempty(dirFiles)
            warning('\nLooks like you didn''t take a z stack on this fly!\n Boooo there''s a giant sign telling you to do it');
            zStackTiff = [];
            zStack = [];
            return;
        end
    end
else
    dirFiles = dir(zStackPath);
    zStackRootPath = '';
end
fileNames = {dirFiles.name};
zStackLog = ~cellfun('isempty', strfind(lower(fileNames), 'zstack'));
if any(zStackLog)
    zStackName = fileNames{zStackLog};
else
    zStack = [];
    zStackTiff = [];
    return
end

zStackTiff = Tiff(fullfile(zStackRootPath,zStackPath, zStackName));


startSpacingVec = [1 1];
zStack = LoadTiffStack(fullfile(zStackRootPath,zStackPath, zStackName), startSpacingVec);