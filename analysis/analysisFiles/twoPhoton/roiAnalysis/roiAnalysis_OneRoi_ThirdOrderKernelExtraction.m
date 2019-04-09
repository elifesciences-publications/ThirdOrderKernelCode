function roi = roiAnalysis_OneRoi_ThirdOrderKernelExtraction(roi,varargin)
% roiAnalysis_OneRoi_ThirdOrderKernelExtraction(roi,'setCorrTypeFlag',true,'dxBank',dxBank,'corrParam','corrParam','barUse');

setCorrTypeFlag = false;
corrTypeParam = {};
% could be two point correlator/three point correlator.
dxBank = {[0,1],[0,-1],[1,2],[-1,-2]}; % dx = 1, dx = 2;
% you should be able to
order = 3;
nMultiBars = 20;
barUse = 1:20;
maxTau = 20;
tMax = 15;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nMultiBarUse = length(barUse);

dtBank = cellfun(@(corrType)corrType.dt,corrParam,'UniformOutput',false);
nDtType = length(dtBank);
indUse = false(maxTau,maxTau,maxTau,nDtType);
for rr = 1:1:nDtType
    dt = dtBank{rr};
    indUse(:,:,:,rr) =  K3ToGlider_Untils_ConstructWindMask(dt(1),dt(2),tMax,maxTau);
end

S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];
roiNum = roi.stimInfo.roiNum;
[respData,stimData,stimIndexes,~,~] = GetStimResp_ReverseCorr(flickpath, roiNum);
% for each
thirdOrderKernel = cell(length(dxBank),1);
for dxx = 1:1:length(dxBank)
    [OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars',nMultiBarUse,'barUse',barUse,'dx',dxBank{dxx});
    resp = OLSMat.resp{1};
    if setCorrTypeFlag
        % from the % there are two
        % prepare for different dt.
        nDtType = length(dtBank);
        thirdOrderKernel{dxx} = zeros(tMax,nDtType,nMultiBarUse);
        for rr = 1:1:nDtType
            indUseThis = find(indUse(:,:,:,rr));
            for qq = 1:1:nMultiBarUse
                barThis = barUse(qq);
                stimMatrix = OLSMat.stim{barThis}(:,indUseThis);
                thirdOrderKernel{dxx}(:,rr,qq) = stimMatrix\resp; % should be much faster than before...
            end
        end
    else
   
        
        
        %          dxThis = dxBank{dxx};
        %     % use the full data set, do not differentiate repeat with non repeat.
        %     [OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars',nMultiBars,'barUse',barUse,'dx',dxThis);
        %
        %         kernelThis = zeros(maxTau^3,nMultiBars);
        % this dose not work at all.
        %         for qq = 1:1:nMultiBars
        %             barThis = barUse(qq);
        %             stimMatrix = OLSMat.stim{barThis};
        %             resp = OLSMat.resp{1};
        %             % instead caluculating all 8000 of them, choose part of it to
        %             % compute.
        %             corrTypeChosen
        %             kernelThis(:,qq) =stimMatrix\resp;
        %         end
        %         % several dx situation/
        %         thirdOrderKernel{dxx}.dx = dxThis;
        %         thirdOrderKernel{dxx}.barUse = barUse;
        %         thirdOrderKernel{dxx}.kernel = kernelThis;
    end
end

roi.filterInfo.thirdKernel.Original = thirdOrderKernel;
roi.filterInfo.thirdKernel.dxBank = dxBank;
roi.filterInfo.thirdKernel.dtBank = dtBank;
end