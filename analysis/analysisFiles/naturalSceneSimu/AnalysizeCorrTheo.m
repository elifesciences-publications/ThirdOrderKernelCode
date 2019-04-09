function [res] = AnalysizeCorrTheo(hrc,convk3,psk3,autok2,vreal)

r.HRC = corr(hrc,vreal);

r.ConvK3 = corr(vreal,convk3(:,1) - convk3(:,2));
% should I use one minus another to calculate ConvK3? the best weight is
% not reasonable....
[weight.ConvK3,r.bestConvK3 ]= CalBestWeight(convk3,vreal);

r.PSK3 = corr(vreal,psk3(:,1) - psk3(:,2));
[weight.PSK3,r.bestPSK3] = CalBestWeight(psk3,vreal);

% because the AutoK2 could not decide motion direction. the the absolute
% value ....
r.AutoK2 = corr(abs(vreal),autok2);
[weight.AutoK2,r.bestAutoK2] = CalBestWeight(autok2,abs(vreal));

[weight.HRCConvK3,r.HRCConvK3 ]= CalBestWeight([hrc,convk3],vreal);
[weight.HRCPSK3,r.HRCPSK3] = CalBestWeight([hrc,psk3],vreal);
[weight.HRCCP,r.HRCCP] = CalBestWeight([hrc,convk3,psk3],vreal);

% in which
mut.rROI = corr([hrc,convk3,psk3,autok2]);

res.r = r;
res.weight = weight;
res.mut = mut;

end