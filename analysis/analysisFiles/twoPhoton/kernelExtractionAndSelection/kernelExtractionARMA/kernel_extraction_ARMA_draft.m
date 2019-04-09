function [ks, kr] = kernel_extraction_ARMA_draft(respData,stimData,stimIndexes,varargin)

maxTau = 32; % small guy.. % shuffle?
order = 2;
nMultiBars = 20; % hard coded it. use all of it.
dx = 1;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'maxTau',maxTau,'order',order,'arma_flag',true,'maxTau_r',1,'dx',dx);
nRoi = length(respData);
ks = cell(nRoi, 1);
kr = cell(nRoi, 1);
for rr = 1:1:nRoi
    RR = OLSMat.resp{rr} ;
    % one or two point a head...
    RR_arma = OLSMat.resp_auto{rr};
    switch order
        case 1
            kernel_arma = zeros(maxTau + 1,nMultiBars); %do you want to put them together? might be too large. do it one by one.
            for qq = 1:1:nMultiBars
                SS = OLSMat.stim{qq};
                kernel_arma(:,qq) = [SS,RR_arma]\RR;
                %             kernel_arma = kernel_armaGPU
            end
            ks =  kernel_arma(1:maxTau,:);
            kr =  kernel_arma(end,:);
            
        case 2
            kernel_arma = zeros(maxTau^2 + 1, nMultiBars);
            for qq = 1:1:nMultiBars
                SS = OLSMat.stim{qq};
                
                % ARMA. autoregression.
                % you will shift RR a little bit.
                if dx == 0
                    % if it is self with self, it would cause deficiency. calculate
                    % half of it.
                    A = tril(true(maxTau, maxTau),-1);
                    SS_lower_half = SS(:,A == 1);
                    RR = OLSMat.resp{1} ;
                    RR_arma = OLSMat.resp_auto{1};
                    kernel_arma_this_sr = [SS_lower_half,RR_arma]\RR;
                    kernel_arma_this_half = kernel_arma_this_sr(1:end - 1);
                    kernel_arma_this_full = zeros(maxTau,maxTau);
                    kernel_arma_this_full(A == 1) = kernel_arma_this_half;
                    kernel_arma_this_full = kernel_arma_this_full + kernel_arma_this_full';
                    kernel_arma(:,qq) = [kernel_arma_this_full(:);kernel_arma_this_sr(end)];
                else
                    tic
                    kernel_arma(:,qq) = [SS,RR_arma]\RR;
                    toc
                end
            end
            ks{rr} =  kernel_arma(1:maxTau^2,:);
            kr{rr} =  kernel_arma(end,:);
    end
end