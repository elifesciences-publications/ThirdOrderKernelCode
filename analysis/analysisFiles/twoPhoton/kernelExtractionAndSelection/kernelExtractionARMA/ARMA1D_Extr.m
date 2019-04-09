function [ks,kr] = ARMA1D_Extr(stim,r,maxTau_ks,maxTau_kr)
% has gone through test
nT = length(stim);
%% OLS to find the kernel.
y = r(maxTau_ks:end);

% maxTauKs = 10;
% organize stim and r into big matrix of X;
Xs = zeros(nT - maxTau_ks + 1,maxTau_ks);
for jj = 1:1:maxTau_ks
    Xs(:,jj) = stim(maxTau_ks - jj +  1: nT -jj + 1);
end

%%
% maxTauKr =3;
if maxTau_kr >0
    Xy = zeros(nT - maxTau_ks + 1,maxTau_kr);
    for jj = 1:1:maxTau_kr
        Xy(:,jj) = r(maxTau_ks - jj:end -jj);
    end
    
    X = [Xs,Xy];
    k = X\y;
    
    ks = k(1:maxTau_ks);
    kr = k(maxTau_ks + 1:end);
else
    
    X = Xs;
    k = X\y;
    ks = k;
    kr = 0;
end
% organize
