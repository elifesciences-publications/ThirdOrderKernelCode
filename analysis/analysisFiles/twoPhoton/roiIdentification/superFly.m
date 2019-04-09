% connDb = connectToDatabase;
% relativeDataPath = fetch(connDb, 'select relativeDataPath from stimulusPresentation where stimulusPresentationId in (1453, 1454)');
% flyEye = 'Left';
% absolutePath = 'I:\2pData\2p_microscope_data\';
% matt's fly to me..
absolutePath = 'I:\2pData\2p_microscope_data\';
relativeDataPath  = {'2015_08_06\+;UASGC6f_+;T4T5_+ - 2\multiBarFlicker_20_60hz_-63.3down007',...
                      '+;UASGC6f_+;T4T5\multiBarFlicker_20_repBlock_60hz\2015\11_20\15_11_33\multiBarFlicker_20_repBlock_60hz_-49.4down009'
                     '+;UASGC6f_+;T4T5_+\multiBarFlicker_20_repBlock_60hz\2015\11_07\21_11_13\multiBarFlicker_20_repBlock_60hz_-43.4down008'...
                     '+;UASGC6f_+;T4T5_+\multiBarFlicker_20_repBlock_60hz\2015\11_24\16_11_46\multiBarFlicker_20_repBlock_60hz_-62.3down003'};
% relativeDataPath{1} = '2015_08_24\+;GC6f;T4T5 - 2\sinMir_VcontFreq_rot_lam45_dur4_C05_360hz_-29544.6down001';
% relativeDataPath{2} = '2015_08_24\+;GC6f;T4T5 - 2\sinMir_VcontFreq_rot_lam45_dur4_C05_360hz_-29544.6down001';
% relativeDataPath{3} = '2015_08_24\+;GC6f;T4T5 - 2\sinMir_VcontFreq_rot_lam45_dur4_C05_360hz_-29544.6down001';
flyEye = 'left';

nfile = length(relativeDataPath);
filepath = cell(nfile,1);
for ff = 1:1:nfile;
    filepath{ff} = strcat(absolutePath,relativeDataPath{ff});
end
for ff = 1:1:nfile
    Z = twoPhotonMaster('filename',filepath{ff},...
        'ROImethod','ICA_NNMF','edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','roiCorrNew','squareCounts',0,'roiMinPixNum',10,'force_new_ROIs',false);
    cd('C:\Users\Clark Lab\Documents\Holly_log\10_22_2015\FigurePlotCode\Fig1');
    %     Z = RoiSelectionPreliminary(Z,flyEye);
    roiSelected = RoiSelectionBySize(Z.ROI.roiMasks(:,:,1:end-1),10);
    %     roiSelectedBySize = RoiSelectionBySize()
    FigPlot1(Z,flyEye,'roiSelectionFlag',true,'roiSelected',roiSelected,'fig1_b_Flag',false,'fig1_c_Flag',true,'fig1_trace_Flag',true, 'fig1_DSIESI_flag',true,'saveFigFlag',true,'metaAnalysis_flag',false);
%     FigPlot1_cosine(Z,flyEye,'roiSelectionFlag',true,'roiSelected',roiSelected,'fig1_b_Flag',true,'fig1_c_Flag',true,'fig1_trace_Flag',true, 'fig1_DSIESI_flag',true,'saveFigFlag',false,'metaAnalysis_flag',false);
end

% connDb = connectToDatabase;
% dataReturn = fetch(connDb, sprintf('select relativeDataPath, eye, date from  stimulusPresentation as sP join fly as f on f.flyId = sP.fly order by date DESC'));
% filepathAll = dataReturn(:,1);
% flyEye = dataReturn(:,2);
% date = dataReturn(:,3);
% just gone through those files and get the best one...
