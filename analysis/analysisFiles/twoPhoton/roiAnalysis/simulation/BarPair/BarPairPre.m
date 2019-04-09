function [resp,stimMat] = BarPairPre(kernel,doLN,coe,LNType,nBarUse)
%% kernel : is the key 
% roiInfo : what is the prefered direction of this roi? instead of
% progressive/regressive, tell if it is right or left, so that the prefered
% direction could be drawn ....
% nBarUse = 5;
T = 2;
nT = T * 60;


signBank = [1,1;1,-1;-1,1;-1,-1];
dBank = [1,-1];
phaseBank = 1:nBarUse;

nSign = length(signBank);
nD = length(dBank);
nPhaseBank = length(phaseBank);

% response for the first order kernel.
firstResp = zeros(nT,nBarUse,nPhaseBank,nSign,nD);
firstRespSum = zeros(nT,1,nPhaseBank,nSign,nD);

stimMat = zeros(nT,nBarUse,nPhaseBank,nSign,nD);
for ii = 1:1:nD
    for jj = 1:1:nSign
        for pp = 1:1:nPhaseBank
            
            sign = signBank(jj,:);
            d = dBank(ii);
            phase = phaseBank(pp);
            
            stim = ReversePhiGeneration_Juyue(sign,d,phase,T,nBarUse);
            
            for qq = 1:1:nBarUse
                firstResp(:,qq,pp,jj,ii) = filter(kernel(:,qq),1,stim(:,qq));
            end
            stimMat(:,:,pp,jj,ii) = stim;
            firstRespSum(:,1,pp,jj,ii) = sum(firstResp(:,:,pp,jj,ii),2);
        end
    end
end

resp = firstRespSum;
if doLN
    % there are three ways to do this nonlinearity.
    switch LNType            
        case 'rectification'
             respRec = MyRectification(firstRespSum);
            resp = respRec;            
        case 'square'
            
           respSqu = firstRespSum.^2;
            resp = respSqu;
        case 'coe'
            firstRespSumLN = MyLN(firstRespSum,coe);
            respLN = firstRespSumLN;
            resp = respLN;
    end
else
    resp = firstRespSum;  
end

end