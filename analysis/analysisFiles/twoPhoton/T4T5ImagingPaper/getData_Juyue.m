function roiData = getData_Juyue(stimulusType,roiMethodType,varargin)
selectionMethod_second = 'fullKernel'; %
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% dataStorePath = 'C:\Users\Clark Lab\Documents\Holly_log\11_10_2015\';
% dataStoreInfo = dir([dataStorePath,'*.mat']);
% nDataFile = length(dataStoreInfo);
% D = [];
% for ii = 1:1:nDataFile
%     filename = dataStoreInfo(ii).name;
%     filefullpath = [dataStorePath,filename];
%     load(filefullpath);
%     D = [D;roiData];
% end
%
% load('C:\Users\Clark Lab\Documents\Holly_log\11_12_2015\CorrectError\roiDataFinal');
% roiData = roiData_New;
% switch roiMethodType
%     case 'waterShed_NNMF'
%         dataStorePath = 'C:\Users\Clark Lab\Documents\Holly_log\11_15_2015\waterShed_NNMF\';
%     case 'ICA_NNMF'
%         dataStorePath = 'C:\Users\Clark Lab\Documents\Holly_log\11_15_2015\ICA_NNMF\';
% end
% you need to create a path here so that your data is stored at
% somewhere...


S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;

if strcmp(stimulusType,'simu')
    if strcmp(simuType,'LN');
        dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\simulation\processed\',simuType,'\',LNType,'\'];
        
    else
        dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\simulation\processed\',simuType,'\'];
    end
    dataStoreInfo = dir([dataStorePath,'*.mat']);
    nDataFile = length(dataStoreInfo);
    D = [];
    for ii = 1:1:nDataFile
        filename = dataStoreInfo(ii).name;
        filefullpath = [dataStorePath,filename]; % whaere is you last data? oh... do you still store it? what is going on here?
        load(filefullpath);
        D = [D; roiDataSimu_LM(1:end -1)];
    end
    roiData = D;
else
    %%flyLargeMovement = {'I:\2pData\2p_microscope_data\2015_08_11\+;UASGC6f_+;T4T5_+ - 1\multiBarFlicker_20_60hz_-64.6down005'};
    
    % 'multiBarFlicker_20_repBlock_60hz_-74' for newest data set, ff 22 is
    % the one with a lot movement and we want to move them away.
    dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\processed\',roiMethodType,'\',stimulusType,'\'];
    % dataStorePath = ['C:\Users\Clark Lab\Documents\Holly_log\11_27_2015\ICA\'];
    dataStoreInfo = dir([dataStorePath,'*.mat']);
    nDataFile = length(dataStoreInfo);
    D = [];
    for ii = 1:1:nDataFile
        filename = dataStoreInfo(ii).name;
        filefullpath = [dataStorePath,filename];
        load(filefullpath);
        %         D = [D;roiDataCV_LM];
        if exist('roiData','var')
            length(roiData)
            D = [D;roiData];
            length(D)
            clear roiData
        elseif exist('roiDataCV_LM','var')
            
            length(roiDataCV_LM)
            D = [D;roiDataCV_LM];
            length(D)
            clear roiDataCV_LM
        end
    end
    roiData = D;
end
end