function roiData = roiAnalysis_MendPathName(roiData)
% get the path from data 1.
stimInfo = roiData{1}.stimInfo;
filepath = stimInfo.filepath;
flickpath = stimInfo.flickPath;
firstkernelpath = stimInfo.firstKernelPath;
firstnoisepath = stimInfo.firstNoisePath;
secondkernelpathNearest = stimInfo.secondKernelPathNearest;
secondnoisepath = stimInfo.secondNoisePath;
secondkernelpathNextNearest = stimInfo.secondKernelPathNextNearest;


nRoi = length(roiData);
for rr = 2:1:nRoi
    % for anly new roi
    roiData{rr}.stimInfo.filepath = filepath ;
    roiData{rr}.stimInfo.flickPath = flickpath;
    roiData{rr}.stimInfo.firstKernelPath  = firstkernelpath;
    roiData{rr}.stimInfo.firstNoisePath  = firstnoisepath;
    roiData{rr}.stimInfo.secondKernelPathNearest  = secondkernelpathNearest;
    roiData{rr}.stimInfo.secondNoisePath  = secondnoisepath;
    roiData{rr}.stimInfo.secondKernelPathNextNearest = secondkernelpathNextNearest;
end


end