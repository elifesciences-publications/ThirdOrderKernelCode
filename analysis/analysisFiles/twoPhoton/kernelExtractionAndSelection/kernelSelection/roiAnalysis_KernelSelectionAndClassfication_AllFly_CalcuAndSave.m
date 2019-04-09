function roiAnalysis_KernelSelectionAndClassfication_AllFly_CalcuAndSave(roiMethodType,stimulusType,varargin)
selectionMethod_second = 'fullKernel'; %%% 'onlyDirectionSelective'; %
otherConditionFlag = false;
addCond = '';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% load one fly, deal with that fly, and store the data back...
% sounds like a bad idea...

% just do it!.
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
if otherConditionFlag
    dataLoadPath = [kernelFolder,'\T4T5_Imaging_Paper\raw\',[roiMethodType,'_',addCond],'\',stimulusType,'\'];
else
    dataLoadPath = [kernelFolder,'\T4T5_Imaging_Paper\raw\',roiMethodType,'\',stimulusType,'\'];
end
switch selectionMethod_second
    case 'fullKernel';
        if otherConditionFlag
            dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\processed\',[roiMethodType,'_',addCond],'\',stimulusType,'\'];
        else
            dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\processed\',roiMethodType,'\',stimulusType,'\'];
        end
    case 'onlyDirectionSelective'
        dataStorePath = ['C:\Users\Clark Lab\Documents\Holly_log\roiData_Latest\kernelSelected_DirectionSelective\',roiMethodType,'\',stimulusType,'\'];
end
% dataStorePath = ['C:\Users\Clark Lab\Documents\Holly_log\11_27_2015\ICA\'];
dataStoreInfo = dir([dataLoadPath,'*.mat']);
nDataFile = length(dataStoreInfo);
D = [];
for ii = 1:1:nDataFile
    filename = dataStoreInfo(ii).name;
    filefullpath = [dataLoadPath,filename];
    load(filefullpath);
    
    % get onefly....
    roiData = roiAnalysis_kernelSelectionPerFly(roiData,'selectionMethod_second',selectionMethod_second);
    savefullpath = [dataStorePath,filename];
    cd(dataStorePath);
    save(savefullpath,'roiData');
end

end