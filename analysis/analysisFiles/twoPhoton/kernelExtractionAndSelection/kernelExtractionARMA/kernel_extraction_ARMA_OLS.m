function [ks_rois, kr_rois] = kernel_extraction_ARMA_OLS(respData,stimData,stimIndexes,varargin)
% try to change this into a for loop over rr...
maxTau = 32; % small guy.. % shuffle?
order = 2;
nMultiBars = 20; % hard coded it. use all of it.
dx = 1;
kernel_by_bar_flag = true;
arma_flag = 1;
maxTau_r = 1;
ratio_fstim_fresp = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nRoi =  length(respData);
ks_rois = cell(nRoi,1);
kr_rois = cell(nRoi,1);


for rr = 1:1:nRoi
    [OLSMat] = tp_Compute_OLSMat(respData(rr),stimData,stimIndexes(rr),'maxTau',maxTau,'order',order,'arma_flag',arma_flag,'maxTau_r',maxTau_r,'dx',dx, 'nMultiBars', nMultiBars,'ratio_fstim_fresp',ratio_fstim_fresp);
    RR = OLSMat.resp{1} ;
    % one or two point a head...
    RR_arma = OLSMat.resp_auto{1};
    switch order
        case 1
            %do you want to put them together? might be too large. do it one by one.
            % for kernel one, do you want to change the way you do it? or test
            % whether they are the same...
            if kernel_by_bar_flag % you will only use this for first order kernel.
                kernel_arma = zeros(maxTau + maxTau_r,nMultiBars);
                for qq = 1:1:nMultiBars
                    SS = OLSMat.stim{qq};
                    kernel_arma(:,qq) = [SS,RR_arma]\RR;
                    %             kernel_arma = kernel_armaGPU
                end
                ks =  kernel_arma(1:maxTau,:);
                kr =  kernel_arma(maxTau + 1:end,:);
            else
                % compute the thing together.
                [nT,maxTau] = size(OLSMat.stim{1});
                SS = zeros(nT, maxTau * nMultiBars);
                for qq = 1:1:nMultiBars
                    SS(:, (qq-1)* maxTau + 1: qq * maxTau) = OLSMat.stim{qq};
                end
                kernel_arma = [SS,RR_arma]\RR;
                ks =  reshape(kernel_arma(1:maxTau * nMultiBars),[maxTau,nMultiBars]);
                kr =  kernel_arma(maxTau * nMultiBars + 1:end); % 0.54 % smaller... what if you incorporate second order kernel? % you have to do this....
            end
            
        case 2
            kernel_arma = zeros(maxTau^2 + maxTau_r, nMultiBars);
            if kernel_by_bar_flag
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
                        kernel_arma_this_half = kernel_arma_this_sr(1:end - maxTau_r);
                        kernel_arma_this_full = zeros(maxTau,maxTau);
                        kernel_arma_this_full(A == 1) = kernel_arma_this_half;
                        kernel_arma_this_full = kernel_arma_this_full + kernel_arma_this_full';
                        kernel_arma(:,qq) = [kernel_arma_this_full(:);kernel_arma_this_sr(size(SS_lower_half, 2) + 1: end)];
                    else
                        kernel_arma(:,qq) = [SS,RR_arma]\RR;
                    end
                end
                ks =  kernel_arma(1:maxTau^2,:);
                kr =  kernel_arma(maxTau^2 + 1: end,:);
            else
                if dx == 0
                    A = tril(true(maxTau, maxTau),-1);
                    [nT, maxTau_Squared] = size(OLSMat.stim{1});
                    maxTau_use = (maxTau^2 - maxTau)/2;
                    SS = zeros(nT, maxTau_use * nMultiBars);
                    for qq = 1:1:nMultiBars
                        SS_lower_half = OLSMat.stim{qq}(:,A == 1);
                        SS(:,(qq-1)* maxTau_use + 1: qq * maxTau_use) = SS_lower_half;
                    end
                    kernel_arma = [SS,RR_arma]\RR;
                    kr =  kernel_arma(end);
                    ks = zeros(maxTau^2,nMultiBars);
                    for qq = 1:1:nMultiBars
                        kernel_arma_this_half = kernel_arma((qq-1)* maxTau_use + 1: qq * maxTau_use);
                        kernel_arma_this_full = zeros(maxTau,maxTau);
                        kernel_arma_this_full(A == 1) = kernel_arma_this_half;
                        kernel_arma_this_full = kernel_arma_this_full + kernel_arma_this_full';
                        ks(:,qq) =  kernel_arma_this_full(:);
                    end
                    
                else
                    [nT, maxTau_Squared] = size( OLSMat.stim{1});
                    SS = zeros(nT, maxTau_Squared * nMultiBars);
                    for qq = 1:1:nMultiBars
                        SS(:, (qq-1)* maxTau_Squared + 1: qq * maxTau_Squared) = OLSMat.stim{qq};
                    end
                    kernel_arma = [SS,RR_arma]\RR;
                    kr =  kernel_arma(end);
                    for qq = 1:1:nMultiBars
                        ks(:,qq) =  kernel_arma((qq-1)* maxTau_Squared + 1: qq * maxTau_Squared);
                    end
                end
            end
    end
    ks_rois{rr} = ks;
    kr_rois{rr} = kr;
end