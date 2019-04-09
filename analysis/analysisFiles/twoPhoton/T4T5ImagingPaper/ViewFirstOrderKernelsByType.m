function ViewFirstOrderKernelsByType(roiData,varargin)
% clean D a little bit..
% ViewKernelsByType(roiData,'kernelExtractionMethod','reverse','typeSelected',[1,2,3,4]);
typeSelected = [1,2,3,4];
kernelOrZ = 'kernel';
titleByRoiSequenceFlag = true;
% label them by the actual position...
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{',num2str(ii + 1),'};']);
end


roi = roiData{1};
maxTau = size(roi.filterInfo.firstKernel.Adjusted,1);
nMultiBars = size(roi.filterInfo.firstKernel.Adjusted,2);

nType = length(typeSelected);
nRoi = length(roiData);
% list all the edgeType
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
end


for ii = 1:1:nType
    tt =typeSelected (ii);
    roiUse = find(edgeType == tt & (kernelType == 1 | kernelType == 3));
    nRoiUse = length(roiUse);
    
    firstKernel = zeros(maxTau,nMultiBars,nRoiUse);
    
    for jj = 1:1:nRoiUse
        rr = roiUse(jj);
        roi = roiData{rr};
        switch kernelOrZ
            case 'kernel'
                firstKernel(:,:,jj) = roi.filterInfo.firstKernel.Adjusted;
            case 'kernelZ'
                firstKernel(:,:,jj) = roi.filterInfo.firstKernelZ.Adjusted;
        end
    end
    quickViewKernelsFirst(firstKernel,'cutFilterFlag',false,'smoothFlag',true,'titleByRoiSequenceFlag',titleByRoiSequenceFlag,'roiSequence',roiUse);
end
% you also want to show


% to help you delete bad roi, plot all of them and give me the file name.
if isempty(typeSelected)
    firstKernelAll = zeros(maxTau,nMultiBars,nRoi);
    for rr = 1:1:nRoi
        roi = roiData{rr};
        firstKernelAll(:,:,rr) = roi.filterInfo.firstKernelAdjusted;
    end
    quickViewKernelsFirst(firstKernelAll,'cutFilterFlag',true,'smoothFlag',true,'titleByRoiSequenceFlag',titleByRoiSequenceFlag,'roiSequence',roiUse);
    
end
end






