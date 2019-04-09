% first of all, get the roi which is used to generate your data.
function Main_Simu_DataGeneration(simuType,LNType,dataName,nSample,reciprocalSNRMax,reciprocalSNRMin)
load('C:\Users\Clark Lab\Documents\Holly_log\04_04_2016\RAndExplainableVar_OneFly_New.mat')
% load('D:\Hollylog\04_04_2016\RAndExplainableVar_OneFly_New.mat')
roiNum = 110;
roiReal = roiData_CV_LM{roiNum};
% roiAnalysis_OneRoi_LN_OLS(roiReal,'plotFlag',true);
% what is your strategy. simulated non interpolated data, and from there,
% simulate the interpolated data. looks better. adjust your data structure.
roiDataSimu = tp_DataQualityEvaluation_Simulation_DataGeneration_Main(roiReal,'dataName',dataName,'nSample',nSample,...
    'reciprocalSNRMax',reciprocalSNRMax,'reciprocalSNRMin',reciprocalSNRMin,...
    'LNType',LNType,'simuType',simuType);
% store the simulated data.
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
if strcmp(simuType,'LN')
    dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\simulation\raw\',simuType,'\',LNType,'\'];
else
    dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\simulation\raw\',simuType,'\'];
end
cd(dataStorePath);
save(dataName,'roiDataSimu');

%
roiDataSimu(end) = []; % remove the last one.

% you might consider to use reverse correlation to extract full kernels
% again, which would not take you much time... let us do it!
tic %  you do not have GPU in this computer... go to emilio's computer to do this.
roiDataSimu = Simulation_ReExtractKernels_AllRoi(roiDataSimu); 
toc
disp(['finish reextract the full kernel']);
tic
roiDataSimu_LM = roiAnalysis_AllRoi_analyzeRepSegAndModelPred_OLS(roiDataSimu);
toc

% do you want to use it as way to validate your kernel selection method?
% could be. not now....

disp(['finish CV']);
roiDataSimu_LM = [roiDataSimu_LM;roiReal]; % store it back

S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
if strcmp(simuType,'LN')
    dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\simulation\processed\',simuType,'\',LNType,'\'];
else
    dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\simulation\processed\',simuType,'\'];
end


cd(dataStorePath);
save(dataName,'roiDataSimu_LM');
end
% where is our signal to noise?
% % where is the mean r^2?
%
% PlotAllRoi_Simu_VarAndRSquare(roiDataSimu_LM,'titleStr',simuType);


% plot the roi, change it, because it does not have the non interp.

