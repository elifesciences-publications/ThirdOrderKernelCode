function [kernel_order_1, kernel_order_2, kr] = kernel_extraction_ARMA_OLS_OneTwoTogether(respData,stimData,stimIndexes,varargin)
% can you have another one for all of them? what if it is shuffled one...
maxTau = 32; % small guy.. % shuffle?
nMultiBars = 20; % hard coded it. use all of it.
dx_bank = [0,1,2];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% first order kernel
[OLSMat_order_1] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'maxTau',maxTau,'order',1,'arma_flag',true,'maxTau_r',1,'dx',0);
RR = OLSMat_order_1.resp{1} ;
RR_arma = OLSMat_order_1.resp_auto{1};
[nT,maxTau] = size(OLSMat_order_1.stim{1});
SS_order_1 = zeros(nT, maxTau * nMultiBars);
for qq = 1:1:nMultiBars
    SS_order_1(:, (qq-1)* maxTau + 1: qq * maxTau) = OLSMat_order_1.stim{qq};
end

%% second order kernel
n_dx = length(dx_bank);
OLSMat_order_2 = cell(n_dx, 1);
for xx = 1:1:n_dx
    [OLSMat_order_2{xx}] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'maxTau',maxTau,'order',2,'arma_flag',true,'maxTau_r',1,'dx',dx_bank(xx));
end

SS_order_2 = cell(n_dx,1);
maxTau_use = zeros(n_dx,1);
for xx = 1:1:n_dx
    dx = dx_bank(xx);
    if dx == 0
        maxTau_half = (maxTau^2 - maxTau)/2;
        maxTau_use(xx) = maxTau_half;
        SS_order_2{xx} = zeros(nT, maxTau_half * nMultiBars);
        
        A = tril(true(maxTau, maxTau),-1);
        for qq = 1:1:nMultiBars
            SS_lower_half = OLSMat_order_2{xx}.stim{qq}(:,A == 1);
            SS_order_2{xx}(:,(qq-1)* maxTau_half + 1: qq * maxTau_half) = SS_lower_half;
        end
    else
        maxTau_Squared = maxTau^2;
        maxTau_use(xx) = maxTau_Squared;
        SS_order_2{xx} = zeros(nT, maxTau_Squared * nMultiBars);
        for qq = 1:1:nMultiBars
            SS_order_2{xx}(:, (qq-1)* maxTau_Squared + 1: qq * maxTau_Squared) = OLSMat_order_2{xx}.stim{qq};
        end
    end
end
SS = [SS_order_1, cat(2, SS_order_2{:})];
%% test whether your are using correct SS...
% kernel_order_1_self = reshape(SS_order_1\RR,[maxTau, nMultiBars]); % The thing is correct...
% kernel_order_2_arma_self = cell(n_dx,1);
% maxTau_use_order_1 = maxTau * nMultiBars;
% for xx = 1:1:n_dx
%     ind_start = maxTau_use_order_1 + sum(maxTau_use(1:(xx - 1))) * nMultiBars + 1;
%     ind_end = maxTau_use_order_1 + sum(maxTau_use(1:xx)) * nMultiBars;
%     kernel_order_2_arma_self{xx} =  SS(:,ind_start:ind_end)\RR;% for that particular one 
% end

% kernel_order_2_self = cell(n_dx, 1);
% for xx = 1:1:n_dx
%     kernel_order_2_self{xx} = zeros(maxTau^2, nMultiBars);
%     dx = dx_bank(xx);
%     if dx == 0
%         for qq = 1:1:nMultiBars
%             kernel_arma_this_half = kernel_order_2_arma_self{xx}((qq-1)* maxTau_use(xx) + 1: qq * maxTau_use(xx));
%             kernel_arma_this_full = zeros(maxTau,maxTau);
%             kernel_arma_this_full(A == 1) = kernel_arma_this_half;
%             kernel_arma_this_full = kernel_arma_this_full + kernel_arma_this_full';
%             kernel_order_2_self{xx}(:,qq) =  kernel_arma_this_full(:);
%         end
%     else
%         for qq = 1:1:nMultiBars
%             kernel_order_2_self{xx} = reshape( kernel_order_2_self{xx}, [maxTau_Squared, nMultiBars]);
%         end
%     end
% end

%%
kernel_arma = [SS,RR_arma]\RR; % you do not have the problem 
%% reorganize first and second order kernel.
kr = kernel_arma(end);
kernel_order_1_arma = kernel_arma(1:maxTau * nMultiBars);
kernel_order_1 = reshape(kernel_order_1_arma, [maxTau, nMultiBars]);

kernel_order_2_arma = cell(n_dx,1);
maxTau_use_order_1 = maxTau * nMultiBars;
for xx = 1:1:n_dx
    ind_start = maxTau_use_order_1 + sum(maxTau_use(1:(xx - 1))) * nMultiBars + 1;
    ind_end = maxTau_use_order_1 + sum(maxTau_use(1:xx)) * nMultiBars;
    kernel_order_2_arma{xx} =  kernel_arma(ind_start:  ind_end);
end

kernel_order_2 = cell(n_dx, 1);
for xx = 1:1:n_dx
    kernel_order_2{xx} = zeros(maxTau^2, nMultiBars);
    dx = dx_bank(xx);
    if dx == 0
        for qq = 1:1:nMultiBars
            kernel_arma_this_half = kernel_order_2_arma{xx}((qq-1)* maxTau_use(xx) + 1: qq * maxTau_use(xx));
            kernel_arma_this_full = zeros(maxTau,maxTau);
            kernel_arma_this_full(A == 1) = kernel_arma_this_half;
            kernel_arma_this_full = kernel_arma_this_full + kernel_arma_this_full';
            kernel_order_2{xx}(:,qq) =  kernel_arma_this_full(:);
        end
    else
        for qq = 1:1:nMultiBars
            kernel_order_2{xx}(:,qq) =  kernel_order_2_arma{xx}((qq-1)* maxTau_use(xx) + 1: qq * maxTau_use(xx));
        end
    end
end
end