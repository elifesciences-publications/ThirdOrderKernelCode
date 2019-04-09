function roiDataAna = roiAnalysis_AllRoi_analyzeRepSegAndModelPred_RevCorr(roiData,varargin)
nRoi = length(roiData);

roiDataAna = roiData;
% for rr = 1:1:nRoi
%     roiDataAna{rr} =  roiAnalysis_OneRoi_VarRepSeg(roiDataAna{rr});
% end


%% analysis...
% you might have to change this.... do not want to change...
for rr = 1:1:nRoi
    roi = roiDataAna{rr};
    maxTauRange = [30];
    dtMaxRange = 1;
    barNumRange = [3];
    param.maxTauRange = maxTauRange;
    param.dtMaxRange = dtMaxRange;
    param.barNumRange = barNumRange;
    firstParam = param;
    % this part is really really wrong, you had better reextract kernels...
    roi = roiAnalysis_OneRoi_RevCorr_LN_And_Second(roi,param,'order',1);
    maxTauRange = [20];
    dtMaxRange = [8];
    barNumRange = [1];
    param.maxTauRange = maxTauRange;
    param.dtMaxRange = dtMaxRange;
    param.barNumRange = barNumRange;
    secondParam = param;
    roi = roiAnalysis_OneRoi_RevCorr_LN_And_Second(roi,param,'order',2);
    roi = roiAnalysis_OneRoi_RevCorr_R_1o2o_Combine(roi); % have not change it yet...
    % do you want to do it now? yes... for figures. you can draw it
    % later...
%     roi = roiAnalysis_OneRoi_RevCorr_LN_And_Second(roi,param,varargin)
%     roi =  roiAnalysis_OneRoi_VarRepSeg(roi);
%     roi = roiAnalysis_OneRoi_RepSegAnalysis_Power(roi);
    roiDataAna{rr} = roi;
end

end