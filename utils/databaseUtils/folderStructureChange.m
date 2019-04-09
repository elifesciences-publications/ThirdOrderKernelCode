%%
sysConfig = GetSystemConfiguration;
dbpath = sysConfig.databasePath;%'/Volumes/TOSHIBA EXT/2p_microscope_data/experimentLog.db';
d = connectToDatabase(dbpath);
organizationalName = 'byCellType';
baseLocation = fullfile(sysConfig.twoPhotonDataPath,organizationalName);
baseDataLocation = sysConfig.twoPhotonDataPath;

folderStructureData = fetch(d, 'select cellType, fluorescentProtein, stimulusFunction, relativeDataPath, date from fly join stimulusPresentation as sP on sP.fly = fly.flyId');

cellTypes = folderStructureData(:, 1);
fluorescentProteins = folderStructureData(:, 2);
stimulusFunction = folderStructureData(:, 3);
relativeDataPath = folderStructureData(:, 4);
date = folderStructureData(:, 5);
dateSplit = cellfun(@(dateTime) strsplit(dateTime, ' '), date, 'UniformOutput', false);
dateTimeAlternating = [dateSplit{:}];
dateTimeArray = [cellfun(@(dates) [dates(1:4) '_' dates(6:7) '_' dates(9:end)],dateTimeAlternating(1:2:end), 'UniformOutput', false)'...
    cellfun(@(times) [times(1:2) '_' times(4:5) '_' times(7:8)],dateTimeAlternating(2:2:end), 'UniformOutput', false)'];

warning('off','MATLAB:MKDIR:DirectoryExists');
tic
for i = 1:size(folderStructureData, 1)
    finalDirPreTime = fullfile(baseLocation, fluorescentProteins{i}, cellTypes{i}, dateTimeArray{i, 1}, stimulusFunction{i});
    mkdir(finalDirPreTime);
    finalDirWithTime = fullfile(finalDirPreTime, dateTimeArray{i, 2});
    relativeDataPath{i}(relativeDataPath{i}=='\') = '/';
    dataDir = fullfile(baseDataLocation, relativeDataPath{i});
    if strcmpi(dataDir(end-3:end), '.tif')
        [dataDir, ~, ~] = fileparts(dataDir);
    end
%     os = computer;
%     if strcmp(os, 'MACI64')
%         finalBatWithTime = [finalDirWithTime, '.command'];
%     else
%         finalBatWithTime = [finalDirWithTime, '.bat'];
%     end
%     batHandle = fopen(finalBatWithTime, 'w');
%     relativePathToData = RelativePath(dataDir, finalDirPreTime);
%     if strcmp(os, 'MACI64')
%         fprintf(batHandle, 'cd "`dirname "$0"`"\n');
%         fprintf(batHandle, 'open %s', relativePathToData);
%     else
%         fprintf(batHandle, 'start "" "%s"', relativePathToData);
%     end
    
%     fclose(batHandle);
    systemCommand = sprintf('mklink /D "%s" "%s"', finalDirWithTime, dataDir);
    [resp, cmdout] = system(systemCommand);
end
toc