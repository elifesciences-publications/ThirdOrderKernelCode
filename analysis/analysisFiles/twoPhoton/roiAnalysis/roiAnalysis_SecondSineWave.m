function roiData = roiAnalysis_SecondSineWave(roiData,varargin)
nRoi = length(roiData);
normFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

for rr = 1:1:nRoi
    roiData{rr} = roiAnalysis_OneRoi_SecondSineWave(roiData{rr},'normKernelFlag',normFlag);
end
end