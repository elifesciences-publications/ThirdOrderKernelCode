% run 5T data.

% roiMethod = 'watershed';
% stimulusType = '5B';
% analyzeAll_Juyue(roiMethod,stimulusType);
% stimulusType = '5T';
% analyzeAll_Juyue(roiMethod,stimulusType);
% 
% %%
% roiMethod = 'edgeTypeRoi';
% stimulusType = '5B';
% analyzeAll_Juyue(roiMethod,stimulusType);
% stimulusType = '5T';
% analyzeAll_Juyue(roiMethod,stimulusType);
% 
% %%
% 
% roiMethod = 'waterShed_NNMF';
% stimulusType = '5B';
% analyzeAll_Juyue(roiMethod,stimulusType);
% stimulusType = '5T';
% analyzeAll_Juyue(roiMethod,stimulusType);
% 
% %%
% clear
% clc
% roiMethod = 'ICA_NNMF';
% stimulusType = '5B';
% analyzeAll_Juyue(roiMethod,stimulusType);
% stimulusType = '5T';
% analyzeAll_Juyue(roiMethod,stimulusType);

%%
roiMethod = 'waterShed_NNMF';
stimulusType = '5B';
analyzeAllFly(roiMethod,stimulusType);
stimulusType = '5T';
analyzeAllFly(roiMethod,stimulusType);

%%
clear
clc
roiMethod = 'ICA_NNMF';
stimulusType = '5T';
analyzeAllFly(roiMethod,stimulusType,5);
stimulusType = '10';
analyzeAllFly(roiMethod,stimulusType,10);
stimulusType = '5B';
analyzeAllFly(roiMethod,stimulusType,5);
%%
stimulusType = '5T';
roiAnalysis_KernelSelectionAndClassfication_AllFly_CalcuAndSave(roiMethod, stimulusType);
stimulusType = '10';
roiAnalysis_KernelSelectionAndClassfication_AllFly_CalcuAndSave(roiMethod, stimulusType);
stimulusType = '5B';
roiAnalysis_KernelSelectionAndClassfication_AllFly_CalcuAndSave(roiMethod, stimulusType);
% %%
% clear
% clc
% roiMethod = 'ICA_NNMF';
% stimulusType = '5T';
% analyzeAllFly(roiMethod,stimulusType,);
% stimulusType = '5';
% roiMethod = 'ICA';
% roiAnalysis_KernelSelectionAndClassfication_AllFly_CalcuAndSave(roiMethod, stimulusType);


%%
