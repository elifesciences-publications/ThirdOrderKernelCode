function roiData = roiAnalysis_OneFly_ExtractSecondOrderKernel_FirstSub(roiData)
roi = roiData{1};
filepath_std = roi.stimInfo.filepath;
% first, make sure that all the fly comes from the same file.
for rr = 1:1:length(roiData)
    filepath = roiData{rr}.stimInfo.filepath;
    if ~strcmp(filepath,filepath_std)
        error('this roi contains data coming from different flies!');
    end
end

roiNum = cellfun(@(roi) roi.stimInfo.roiNum, roiData);
firstOrderKernel = cellfun(@(roi) roi.filterInfo.firstKernel.Original,roiData,'UniformOutput',false);


flickPath = roi.stimInfo.flickPath;
S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;

flickPath = [kernelPath, flickPath];

load(flickPath);
respData = flickSave.respData(roiNum);
stimIndexes = flickSave.stimIndexed(roiNum);
stimData = flickSave.stimData;
repStimAll = (1:size(stimData,1))';


cov_mat_all = tp_Compute_CovarianceMatrix_FristOrderKernelSub(respData, stimIndexes,stimData,firstOrderKernel, repStimAll);

% do you have to change the format? look at the old one? It takes super
% long to load...
for rr = 1:1:length(roiData)    
    dx_full = STC_Utils_CovMatToSecondKernel(cov_mat_all{rr});
    roiData{rr}.filterInfo.secondKernel.dx_full = dx_full;
end

end