function [filepath,stimulusFunction,flyEye] = getDataPath(dataType)

if strcmp(dataType,'behavior')
    %    filepath = 'I:\BehaviorData\twoBarFlicker_binary_var1_180hz';
    % you are going to get into the file and get all the file path for this fly
    % out.
    data = {'I:\BehaviorData\twoBarFlicker_binary_var1_180hz\2014\06_20','I:\BehaviorData\twoBarFlicker_binary_var1_180hz\2014\06_27'};
    ndata = length(data);
    filepath = cell(10,1);
    count = 1;
    for ii = 1:1:ndata
        d = dir(data{ii});
        d(1:2) = [];
        nfile = length(d);
        for jj = 1:1:nfile
            filepath{count} = [data{ii},'\',d(jj).name];
            count = count + 1;
        end
    end
    filepath(count:end) = [];
    stimulusFunction = [];
    flyEye = [];
    return
end


connDb = connectToDatabase;
% fetch the data set from
switch dataType
    case '10'
        dataReturn = fetch(connDb,'select stimulusFunction, relativeDataPath, eye from stimulusPresentation as sP join fly as f on f.flyId=sP.fly where stimulusFunction="multiBarFlicker_20_60hz_10dWidth" and (sP.dataQuality>0 or sP.dataQuality is NULL)');
        
    case '5B'
        dataReturn = fetch(connDb,'select stimulusFunction, relativeDataPath, eye from stimulusPresentation as sP join fly as f on f.flyId=sP.fly where stimulusFunction="multiBarFlicker_20_60hz" and (sP.dataQuality>0 or sP.dataQuality is NULL)');
        dataReturnNew = fetch(connDb,'select stimulusFunction, relativeDataPath, eye from stimulusPresentation as sP join fly as f on f.flyId=sP.fly where stimulusFunction="multiBarFlicker_20_repBlock_60hz" and (sP.dataQuality>0 or sP.dataQuality is NULL)');
        dataReturn = [dataReturn;dataReturnNew];
    case '5T'
        dataReturn = fetch(connDb,'select stimulusFunction, relativeDataPath, eye from stimulusPresentation as sP join fly as f on f.flyId=sP.fly where stimulusFunction="multiBarFlickerTernary_20_repBlock_60hz" and (sP.dataQuality>0 or sP.dataQuality is NULL)');
end

stimulusFunction = dataReturn(:, 1);
relativeDataPath = dataReturn(:, 2);
flyEye = dataReturn(:, 3);
% fetch(connDb,'select distinct
% change it =====================================================
absolutePath = 'H:\2pData\2p_microscope_data\';
nfile = size(relativeDataPath,1);
filepath = cell(nfile,1);
for ff = 1:1:nfile;
    filepath{ff} = strcat(absolutePath,relativeDataPath{ff});
end

% for the old five degree data set...
% ignore the old one?
% badFor5 =[1,4,5,9];
if strcmp(dataType,'5B')
    filepath(1:6) = [];
    flyEye(1:6) = [];
    % the 9th one is also wired. no windows for that guy.
    %     filepath(9) = [];
    %     flyEye(9) = []
end

