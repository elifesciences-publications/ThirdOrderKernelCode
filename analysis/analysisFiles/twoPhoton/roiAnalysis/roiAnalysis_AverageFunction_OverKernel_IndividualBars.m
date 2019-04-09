function [value,nPerType] = roiAnalysis_AverageFunction_OverKernel_IndividualBars(roiData,varargin)
% [value,nType] = roiAnalyis_AverageFuncion_OverKernel(roiData,whichValue)
% only used for second order kernel.
% for four different types.
% whichValue = 'secondKernel',dx, glider sineWave, secondKernelSize,...
whichValue = 'secondKernel';
dx = 1;
normKernelFlag = false;
normRoiFlag = true;
kernelTypeUse = [1,2,3];
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
    % change it a little bit...
    roiSelectedType = edgeType == tt;
    roiSelectedKernelType = false(length(kernelType),1);
    for kk = 1:1:length(kernelTypeUse)
        roiSelectedKernelType  = roiSelectedKernelType | kernelType == kernelTypeUse(kk);
    end
    roiUse = find(roiSelectedType &  roiSelectedKernelType);
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
                            [secondKernel,barUse] = roiAnalysis_OneRoi_GetSecondKernel(roi,1,'Aligned',normKernelFlag,normRoiFlag);
                            
                        case 2
                            [secondKernel,barUse] = roiAnalysis_OneRoi_GetSecondKernel(roi,2,'Aligned',normKernelFlag,normRoiFlag);
                            
                        case 0
                            [secondKernel1,barUse1] = roiAnalysis_OneRoi_GetSecondKernel(roi,1,'Aligned',normKernelFlag,normRoiFlag);
                            [secondKernel2,barUse2] = roiAnalysis_OneRoi_GetSecondKernel(roi,2,'Aligned',normKernelFlag,normRoiFlag);
                            secondKernel = [secondKernel1,secondKernel2];
                            barUse = [barUse1;barUse2 + 20];
                    end
                    % the valueThisType would become three dimensional.
                    % first dimension; second dimension(20 bars); third
                    % dimesion(instances);
                    valueThisType = cat(3,valueThisType,secondKernel);
                    count = count + 1;
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
                    valueThisType = cat(3,valueThisType,resp);
                    count = count + 1;
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
                    valueThisType = cat(3,valueThisType,skQuant);
                    count = count + 1;
                case 'firstKernel'
                    firstKernel = roiAnalysis_OneRoi_GetFirstKernel(roi,'Adjusted',normRoiFlag);
                    valueThisType = cat(3,valueThisType,firstKernel);
                    count = count + 1;
                case 'r1o' % first order kernel
                    r = roi.LM.firstOrder.r.overall;
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'r2o'
                    r = roi.LM.secondOrder.r.overall;
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'r1o+2o'
                    r = roi.LM.firstPlusSecond.r.overall;
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'rLN-Rec'
                    r = roi.LM.nonLinearity.r_SoftRectification.overall;
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'rLN-Poly'
                    r = roi.LM.nonLinearity.r_Poly.overall;
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'VarExplainedInterp'
                    r = mean(roi.repSegInfo.varExplainedByMeanInterp);
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'VarExplainedNonInterp'
                    r = mean(roi.repSegInfo.varExplainedByMeanNonInterp);
                    valueThisType = cat(3,valueThisType,r);
                    count = count + 1;
                case 'signalPower'
                    signalPower = roi.repSegInfo.power.estSignal;
                    valueThisType = cat(3,valueThisType, signalPower);
                    count = count + 1;
                case 'noisePower'
                    noisePower = roi.repSegInfo.power.noise;
                    valueThisType = cat(3,valueThisType, noisePower);
                    count = count + 1;
                case 'predPower1o'
                    predictivePower = roi.LM.firstOrder.predPower.predictivePower;
                    valueThisType = cat(3,valueThisType, predictivePower);
                    count = count + 1;
                case 'predPower2o'
                    predictivePower = roi.LM.secondOrder.predPower.predictivePower;
                    valueThisType = cat(3,valueThisType, predictivePower);
                    count = count + 1;
                case 'predPower1o+2o'
                    predictivePower = roi.LM.firstPlusSecond.predPower1o2o.predictivePower;
                    valueThisType = cat(3,valueThisType, predictivePower);
                    count = count + 1;
                case 'predPower-Poly'
                    predictivePower = roi.LM.nonLinearity.power_Poly.predictivePower;
                    valueThisType = cat(3,valueThisType, predictivePower);
                    count = count + 1;
                case 'predPower-Rec'
                    predictivePower = roi.LM.nonLinearity.power_SoftRectification.predictivePower;
                    valueThisType = cat(3,valueThisType, predictivePower);
                    count = count + 1;
                case 'pred2o'
                    switch dx
                        case 1
                            [secondKernel] = roi.filterInfo.firstKernel.pred2o.dx1.kernel;
                            
                        case 2
                            [secondKernel] = roi.filterInfo.firstKernel.pred2o.dx2.kernel;
                            
                        case 0
                            [secondKernel1] = roi.filterInfo.firstKernel.pred2o.dx1.kernel;
                            [secondKernel2] = roi.filterInfo.firstKernel.pred2o.dx2.kernel;
                            secondKernel = [secondKernel1,secondKernel2];
                    end
                    valueThisType = cat(3,valueThisType,secondKernel);
                    count = count + 1;
                case 'predGlider'
                    switch dx
                        case 1
                            glider = roi.filterInfo.firstKernel.pred2o.dx1.glider;
                            
                        case 2
                            glider = roi.filterInfo.firstKernel.pred2o.dx2.glider;
                            
                        case 0
                            glider1 = roi.filterInfo.firstKernel.pred2o.dx1.glider;
                            glider2 = roi.filterInfo.firstKernel.pred2o.dx2.glider;
                            glider = [glider1,glider2];
                    end
                    valueThisType = cat(3,valueThisType,glider);
                    count = count + 1;
                case 'shuffleGlider'
                    shuffleGlider = roi.filterInfo.secondKernel.shuffle.gliderResp.resp;
                    valueThisType = cat(3,valueThisType, shuffleGlider);
                    count = count + 1;
            end
            
        end
    end
    nPerType(tt) = count;
    value{tt} = valueThisType;
end



end
% if the function is interested in averaging over kernels...


% if the functino is interested in averaging over rois.

% if the function is interestd in averaging over flies.