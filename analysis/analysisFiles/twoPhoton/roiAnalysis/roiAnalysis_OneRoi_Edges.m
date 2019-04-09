function roi = roiAnalysis_OneRoi_Edges(roi,varargin)

grayStartFlag = true;
nLNType = 2;
LNType = {'nonp','softRectification'};

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


edgeTypeVC = [-30,1;30,1;-30,-1; 30,-1]; % left light, right light; left dark, right dark;
barWidth = roi.stimInfo.barWidth;


%%
firstFilter = roi.filterInfo.firstKernelOriginal;
% only the selected bar is non zero.
% barSelected = roi.filterInfo.firstBarSelected; % you have to shift to right for at least two.
% firstFilter(:,~barSelected) = 0;
barCenter = roiAnalysis_FindFirstKernelCenter(roi,'method','prob');
firstFilter = roiAnalysis_AverageFirstKernel_AlignOneFilter(firstFilter,barCenter);
flyEye = roi.flyInfo.flyEye;
%% coefficient.


doLN = 1;
for jj = 1:1:nLNType
    LNTypeThis = LNType{jj};
    poly2Coe = roi.LN.fit_Poly2;
    lookUpTable = roi.LN.lookUpTable;
    softRecCoe = roi.LN.fit_SoftRectification;
    [respNonLinear,respFirstLinear,stimMat]= EdgesFirst(firstFilter,doLN,poly2Coe,lookUpTable,softRecCoe, LNTypeThis ,edgeTypeVC,20,barWidth,grayStartFlag);
    timeSlot = roiAnalysis_OneRoi_Edge_CalRelavantTime(respFirstLinear);
    peakResp = zeros(4,1);
    threshP = 0.99;
    % only care about transient acitivity? how do you define transient?
    for ii = 1:1:4
        peakResp(ii) =  percentileThresh(respNonLinear(timeSlot,ii),threshP);
    end
    [SI] = EdgePrediction_RespToSI(peakResp,flyEye);
    
    eval(['edgeResp.f.',LNTypeThis,'.peak = peakResp;']);
    eval(['edgeResp.f.',LNTypeThis,'.resp = respNonLinear;']);
    eval(['edgeResp.f.',LNTypeThis,'.SI = SI;']);
end
edgeResp.fL = respFirstLinear;
edgeResp.stim = stimMat;


%%  non- parametric method.
% doLN = 1;
% coe = roi.LN.coe;
% lookUpTable = roi.LN.lookUpTable;
% [respFirstNonPara,respFirstLinear,stimMat]= EdgesFirst(firstFilter,doLN,coe,lookUpTable,'lookUpTable',edgeTypeVC,20,barWidth,grayStartFlag);
% % respDiffNonPara = roiAnalysis_OneRoi_Edges_LeftMinusRight(respFirstNonPara);
% 
% peakResp = zeros(4,1);
% threshP = 1;
% timeSlot = roiAnalysis_OneRoi_Edge_CalRelavantTime(respFirstLinear);
% for ii = 1:1:4
%     peakResp(ii) =  percentileThresh(respFirstNonPara(timeSlot ,ii),threshP);
% end
% [SI] = EdgePrediction_RespToSI(peakResp,flyEye);
% 
% edgeResp.fnonp.resp = respFirstNonPara;
% % edgeResp.fnonp.respDiff = respDiffNonPara;
% edgeResp.fnonp.peak = peakResp; % there are four of them
% edgeResp.fnonp.SI = SI;

%%

% you have the traces, but now, you want to compute the number...
% secondResp = EdgesSecond(secondFilter(:,barUse),edgeTypeVC,barWidth,plotFlag);
roi.edge = edgeResp;

end