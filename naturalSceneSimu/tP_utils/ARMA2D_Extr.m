function [ks,kr] = ARMA2D_Extr(stim1,stim2,r,maxTau_ks,maxTau_kr)

nT = length(stim1);
% the maxTauKs would be the total potential length of the second order
% kernel.
maxTau = round(sqrt(maxTau_ks));
maxTau_ks = maxTau^2;

y = r(maxTau:end);

tic
Xs = zeros(nT - maxTau + 1,maxTau_ks);
for jj = 1:1:maxTau
    for ii = 1:1:maxTau
        qq = sub2ind([maxTau,maxTau],ii,jj); 
        Xs(:,qq) = stim1(maxTau - ii +  1: nT -ii + 1) .* stim2(maxTau - jj +  1: nT -jj + 1);
    end
end
toc

%%
% maxTauKr =3;
if maxTau_kr >0
    Xy = zeros(nT - maxTau + 1,maxTau);
    for jj = 1:1:maxTau_kr
        Xy(:,jj) = r(maxTau - jj:end -jj);
    end
    tic
    X = [Xs,Xy];
    k = X\y;
    prinf('time for compute this X\y')
    toc
    ks = k(1:maxTau_ks);
    kr = k(maxTau_ks + 1:end);
else
    
    X = Xs;
    k = X\y;
    ks = k;
    kr = 0;
end
% organize