function roiData = roiAnalysis_SecondDt(roiData,varargin)
nRoi = length(roiData);
normKernelFlag = false; % normalize individual kernels within one roi, and then do any calculation from there. it should be false.
normRoiFlag = true;

dt = [-8:1:8];
tMax = 15;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

for rr = 1:1:nRoi
    roiData{rr} = roiAnalysis_OneRoi_SecondDt(roiData{rr},'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag,...
                                               'dt',dt,'tMax',tMax);
end
end