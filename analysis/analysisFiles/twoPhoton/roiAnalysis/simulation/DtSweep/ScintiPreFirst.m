function [meanResp,respNonLinear,respLinear,stimMat] = ScintiPreFirst(kernel,doLN,poly2Coe,lookUpTable,softRectificationCoe,LNType,nBarUse,dtNumBank,signBank)
% only have two variables.

T = 10000;
nT = T * 60;
nT_transient = size(kernel,1) + 1;
r0 = 0.1;
dxNum = 1;

nSign = length(signBank);
nDtNum = length(dtNumBank);

% response;
firstResp = zeros(nT,nBarUse,nDtNum,nSign);
firstRespSum = zeros(nT,1,nDtNum,nSign);
stimMat = zeros(nT,nBarUse,nDtNum,nSign);

% compute the correlation of the stimulus to test the code.
for jj = 1:1:nSign
    for pp = 1:1:nDtNum
        sign = signBank(jj);
        dtNum = dtNumBank(pp);
        stim = SCGeneration_DtDx_Juyue(dtNum,dxNum,nT,sign,nBarUse);

%         stim = SCGeneration_DtDx_Juyue(dtNum,dxNum,nT,d,sign,nBarUse);
        for qq = 1:1:nBarUse
            firstResp(:,qq,pp,jj) = filter(kernel(:,qq),1,stim(:,qq));
            firstResp(1:nT_transient,qq,pp,jj) = 0;
        end
        stimMat(:,:,pp,jj) = stim;
        firstRespSum(:,1,pp,jj) = sum(firstResp(:,:,pp,jj),2);
        
    end
end
if doLN
    % there are three ways to do this nonlinearity.
    switch LNType
        case 'rectification'
            respRec = MyRectification(firstRespSum);
            respNonLinear = squeeze(respRec);
        case 'square'
            respSqu = firstRespSum.^2;
            respNonLinear = squeeze(respSqu);
        case 'coe'
            respCoe = MyLN_Coe(firstRespSum,poly2Coe,lookUpTable);
            respNonLinear = squeeze(respCoe);
        case 'nonp'
            respNonParametric = MyLN_LookUpTable(firstRespSum,lookUpTable);
            respNonLinear = squeeze(respNonParametric);
        case 'softRectification'
            respSoftRec = MyLN_SoftRectification(firstRespSum,softRectificationCoe);
            respNonLinear =  squeeze(respSoftRec);
    end
else
        respNonLinear = squeeze(firstRespSum);
end

meanResp = squeeze(mean(respNonLinear));
respLinear = squeeze(firstRespSum);
stimMat = squeeze(stimMat);

end