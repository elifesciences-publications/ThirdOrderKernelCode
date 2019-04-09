function [value,nPerType] = roiAnalysis_AverageFuncion_OverKernel(roiData,varargin)
% [value,nType] = roiAnalyis_AverageFuncion_OverKernel(roiData,whichValue)
% only used for second order kernel.
% for four different types.
% whichValue = 'secondKernel',dx, glider sineWave, secondKernelSize,...
whichValue = 'secondKernel';
dx = 1;
normKernelFlag = false;
normRoiFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nRoi = length(roiData);
nType = 4;
% if there is nothing in this type, put the value to nan.
% there might be just only one roi in this kernel
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end
value = cell(nType,1);
nPerType = zeros(nType,1);

for tt = 1:1:4
    
    roiUse = find(edgeType == tt & kernelType > 1);
    nRoiUse = length(roiUse);
    valueThisType = [];
    count = 0;
    if nRoiUse > 0
        % get the value you want .
        for ii = 1:1:nRoiUse
            roi = roiData{roiUse(ii)};
            switch whichValue
                case 'secondKernel'
                    switch dx
                        case 1
                            [secondKernel,barUse] = roiAnalysis_OneRoi_GetSecondKernel(roi,1,'Adjusted',normKernelFlag,normRoiFlag);
                            
                        case 2
                            [secondKernel,barUse] = roiAnalysis_OneRoi_GetSecondKernel(roi,2,'Adjusted',normKernelFlag,normRoiFlag);
                            
                        case 0
                            [secondKernel1,barUse1] = roiAnalysis_OneRoi_GetSecondKernel(roi,1,'Adjusted',normKernelFlag,normRoiFlag);
                            [secondKernel2,barUse2] = roiAnalysis_OneRoi_GetSecondKernel(roi,2,'Adjusted',normKernelFlag,normRoiFlag);
                            secondKernel = [secondKernel1,secondKernel2];
                            barUse = [barUse1;barUse2 + 20];
                    end
                    valueThisType = cat(2,valueThisType,secondKernel(:,barUse));
                    count = count + length(barUse);
                    
                case 'glider'
                    switch dx
                        case 1
                            [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,1,'glider');
                        case 2
                            [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,2,'glider');
                        case 0
                            [resp1,barUse1] = roiAnalysis_OneRoi_GetSimuResult(roi,1,'glider');
                            [resp2,barUse2] = roiAnalysis_OneRoi_GetSimuResult(roi,2,'glider');
                            resp = [resp1,resp2];
                            barUse = [barUse1;barUse2 + 20];
                    end
                    valueThisType = cat(2,valueThisType,resp(:,barUse));
                    count = count + length(barUse);
                case 'sinewave'
                    switch dx
                        case 1
                            [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,1,'sinewave');
                        case 2
                            [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,2,'sinewave');
                        case 0
                            [resp1,barUse1] = roiAnalysis_OneRoi_GetSimuResult(roi,1,'sinewave');
                            [resp2,barUse2] = roiAnalysis_OneRoi_GetSimuResult(roi,2,'sinewave');
                            resp = [resp1,resp2];
                            barUse = [barUse1;barUse2 + 20];
                    end
                    valueThisType = cat(2,valueThisType,resp(:,barUse));
                    count = count + length(barUse);
                case 'quantification'
                    switch dx
                        case 1
                            [skQuant,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,1,'mean');
                        case 2
                            [skQuant,barUse] = roiAnalysis_OneRoi_GetQuantificationResult(roi,2,'mean');
                        case 0
                            [skQuant1,barUse1] = roiAnalysis_OneRoi_GetQuantificationResult(roi,1,'mean');
                            [skQuant2,barUse2] = roiAnalysis_OneRoi_GetQuantificationResult(roi,2,'mean');
                            skQuant = [skQuant1,skQuant2];
                            barUse = [barUse1;barUse2 + 20];
                    end
                    valueThisType = cat(2,valueThisType,skQuant(:,barUse));
                    count = count + length(barUse);
            end
            
        end
    end
    nPerType(tt) = count;
    value{tt} = valueThisType;
end
end