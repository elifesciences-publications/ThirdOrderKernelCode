function roi = roiAnalysis_OneRoi_ft(roi,varargin)
nLNType = 2;
LNType = {'nonp','rectification'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% change the omegaBank
% what is the frequence do you like the best.

omegaTemp = (1.3).^(-6:7);
omegaBank = [-fliplr(omegaTemp),omegaTemp];
lambdaBank = [30,45,60]; % might be very slow...
omegaBank(omegaBank == 0) = [];

% put the effective filter into middle.
barWidth = roi.stimInfo.barWidth;
firstFilter = roi.filterInfo.firstKernelOriginal;
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'method','prob');
firstFilter = roiAnalysis_AverageFirstKernel_AlignOneFilter(firstFilter,barCenter);

doLN = 1;
for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    lookUpTable = roi.LN.lookUpTable;
    poly2Coe = roi.LN.fit_Poly2;
    softRecCoe = roi.LN.fit_SoftRectification;
    
    
    [respMeanNonLinear,respLinear,respNonLinear,stimMat] = FrequencyTuningCurveFirst(firstFilter,doLN,poly2Coe,lookUpTable,softRecCoe, LNTypeThis ,20,omegaBank,lambdaBank,barWidth);
    
    eval(['sineWaveResp.f.',LNTypeThis,'.resp = respNonLinear;'])
    if strcmp(roi.flyInfo.flyEye,'right')|| strcmp(roi.flyInfo.flyEye,'Right')
        eval(['sineWaveResp.f.',LNTypeThis,'.mean = respMeanNonLinear;']);
    else
        eval(['sineWaveResp.f.',LNTypeThis,'.mean = flipud(respMeanNonLinear);']);
    end
end
sineWaveResp.f.respLinear = respLinear;
sineWaveResp.f.stim = stimMat;
% tuning curve....

% doLN = 1;
% coe = roi.LN.coe;
% lookUpTable = roi.LN.lookUpTable;
% [respMeanCoe,respLinear,respNonLinear,stimMat] = FrequencyTuningCurveFirst(firstFilter,doLN,coe,lookUpTable,'coe',20,omegaBank,lambdaBank,barWidth);
% fc.resp = respNonLinear;
% doLN = 1;
% [respMeanRec,respLinear,respNonLinear,stimMat] = FrequencyTuningCurveFirst(firstFilter,doLN,coe,lookUpTable,'rectification',20,omegaBank,lambdaBank,barWidth);
% fr.resp = respNonLinear;
% doLN = 1;
% [respMeanNonPara,respLinear,respNonLinear,stimMat] = FrequencyTuningCurveFirst(firstFilter,doLN,coe,lookUpTable,'lookUpTable',20,omegaBank,lambdaBank,barWidth);
% fnonp.resp = respNonLinear;
% % put the mean resp to its prefered direction.
% % calculate those trouble some things afterwards
% if strcmp(roi.flyInfo.flyEye,'left') || strcmp(roi.flyInfo.flyEye,'Left')
%     fc.mean = respMeanCoe;
%     fr.mean = respMeanRec;
%     fnonp.mean = respMeanNonPara;
% else % if it is right eye fly. the progressive direction is the right moving stimulus.
%     fc.mean = flipud(respMeanCoe);
%     fr.mean = flipud(respMeanRec);
%     fnonp.mean = flipud(respMeanNonPara);
% end
% you can turn everything into this fly's progressive regressive. that
% might be the better way to do it...

% = respMeanCoe;
%
% filterType = roi.filterInfo.kernelType;
% if filterType >= 2
%     % you can not run this with your current data...
%     secondFilter = roi.filterInfoNew.secondKernelOriginal;
%     [~,barUse] = min(roi.filterInfo.secondKernelQuality);
%     [respMeanSec] = FrequencyTuningCurveSecond(secondFilter(:,barUse),omegaBank,lambdaBank,barWidth);
%     roi.flyInfo.flyEye
%     if strcmp(roi.flyInfo.flyEye,'left') || strcmp(roi.flyInfo.flyEye,'Left')
%         s.mean = respMeanSec;
%     else % if it is right eye fly. the progressive direction is the right moving stimulus.
%         s.mean = flipud(respMeanSec);
%     end
%     sineWaveResp.s = s;
%
% end

sineWaveResp.omega = omegaBank;
sineWaveResp.lambda = lambdaBank;
roi.ft = sineWaveResp;

end