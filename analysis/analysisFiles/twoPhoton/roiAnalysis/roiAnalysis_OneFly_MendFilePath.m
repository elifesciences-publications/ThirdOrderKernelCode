function roiData = roiAnalysis_OneFly_MendFilePath(roiData,filepath)
roi = roiData{1};
flickpath = roi.stimInfo.flickPath;
flickpath(flickpath == '\') = '/';
fliclpathSeg = strsplit(flickpath,'/');
a = strfind(filepath,fliclpathSeg{3});
ind = cellfun(@(x) ~isempty(x),a);
filepathForThisRoi = filepath{ind};
% do this for all roi,
nRoi = length(roiData);
for rr = 1:1:nRoi
    roiData{rr}.stimInfo.filepath = filepathForThisRoi;
    roiData{rr}.filterInfo.kernelType = 3;
end
end