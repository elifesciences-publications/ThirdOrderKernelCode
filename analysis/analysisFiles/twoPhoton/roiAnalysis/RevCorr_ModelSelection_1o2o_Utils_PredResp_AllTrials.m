function [r,kernelUse,predRespForCorr,respForCorr] = RevCorr_ModelSelection_1o2o_Utils_PredResp_AllTrials(resp,stim,kernel,barUsed,windMask,order,dx)
nSeg = length(resp);
nMultiBars = length(barUsed);
predResp = cell(nSeg,1);
predRespForCorr = cell(nSeg,1);
respForCorr = cell(nSeg,1);
kernelUse = zeros(sum(windMask),nMultiBars);
for ss = 1:1:nSeg
    stimThis = stim{ss};
    nT = size(stimThis,1);
    
    
    switch order
        
        case 1
            maxTau1o = size(kernel,1);
            predResp{ss} = zeros(nT,nMultiBars);
            for qq = 1:1:nMultiBars
                barNum = barUsed(qq);
                kernelUse(:,qq)  = kernel(windMask,barNum); % interesting! % 300 predictors 0.3 seconds, 4000 predictors 30 seconds. pretty linear.
                predResp{ss}(:,qq) = filter(kernelUse(:,qq) ,1,stimThis(:,barNum));
            end
            predResp{ss} = sum(predResp{ss},2);
            
            predRespForCorr{ss} = predResp{ss}(maxTau1o:end);
            respForCorr{ss} = resp{ss}(maxTau1o:end);
        case 2
            maxTau2o = round(sqrt(size(kernel,1)));
            
            predResp{ss} = zeros(nT - maxTau2o + 1,nMultiBars);
            
            for qq = 1:1:nMultiBars
                barNum = barUsed(qq);
                bar1 = barNum;
                bar2 = MyMode(barNum + dx,size(stimThis,2));
                kernelUse(:,qq) = kernel(windMask,barNum);
                s1 = stimThis(:,bar1);
                s2 = stimThis(:,bar2);                
                stimIndStart = int32((maxTau2o:1:length(s1))');
                stimMatrix = tp_Compute_OLSMat_FromStimIndStartToStimSS([s1,s2], stimIndStart ,64,0,0,2,2,1,'barUse',[1,2],'setBarUseFlag',true);
                SS = stimMatrix{1};
                SS = SS(:,windMask);
                predResp{ss}(:,qq) =  SS * kernelUse(:,qq);
            end
            predResp{ss} = sum(predResp{ss},2);
            predRespForCorr{ss} = predResp{ss};
            respForCorr{ss} = resp{ss}(maxTau2o:end);
    end
    
    
    
end
% predRespForCorr = cell2mat(predRespForCorr);
% respForCorr = cell2mat(respForCorr);
r = corr(cell2mat(predRespForCorr),cell2mat(respForCorr));

end