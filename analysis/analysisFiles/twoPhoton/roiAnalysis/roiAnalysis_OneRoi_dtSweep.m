function roi = roiAnalysis_OneRoi_dtSweep(roi,varargin)

nLNType = 1;
LNType = {'softRectification'};
dtNumBank = [-100,-30:1:30,100];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
signBank = [1,-1];
% dt sweep for first order filter.
% firstFilter = roiData.filterInfo.firstKernel;
firstFilter = roi.filterInfo.firstKernelOriginal; % left to right filter.

% do one trial, but long enough.
nBarUse = 20;

doLN = 1;
for jj = 1:1:nLNType
    LNTypeThis = LNType{jj};
    poly2Coe = roi.LN.fit_Poly2;
    lookUpTable = roi.LN.lookUpTable;
    softRecCoe = roi.LN.fit_SoftRectification;
    [respMeanNonLinear,respNonLinear,respLinear,stimMat] = ScintiPreFirst(firstFilter,doLN,poly2Coe,lookUpTable,softRecCoe,LNTypeThis,nBarUse,dtNumBank,signBank);
 
    eval(['dtSweep.f.',LNTypeThis,'.mean = respMeanNonLinear;']); 
    eval(['dtSweep.f.',LNTypeThis,'.resp = respNonLinear;']); 
end
dtSweep.fL = respLinear;
dtSweep.dtNumBank = dtNumBank;
dtSweep.signBank = signBank;
dtSweep.stimMat = stimMat;
filterType = roi.filterInfo.kernelType;
if filterType >= 2
%     secondFilter = roiData.filterInfo.secondKernel;
    secondFilter = roi.filterInfoNew.secondKernelOriginal;
%     barUse = find(roiData.filterInfo.barSelected);
[~,barUse] = min(roi.filterInfo.secondKernelQuality);
    if length(barUse) > 1
        barUse = barUse(1);
    end
    [secondMeanResp,secondResp] = ScintiPreSecond(secondFilter(:,barUse),dtNumBank,signBank);
%     secondDt = ScintiPreSecond(secondFilter(:,barUse));
    %     secondDt =  ScinriPre_nTrial(secondFilter(:,barUse),roiType,0,0,'0',nBarUse,nTrial,2);
    dtSweep.s.mean = secondMeanResp;
    dtSweep.s.resp = secondResp;
end
roi.dtSweep = dtSweep;
% if it works...

% PlotDtSweepResponse(respDt,roiType)
end