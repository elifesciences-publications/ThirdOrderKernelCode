function [v,stimc,imageIDarray] = AnaDelData_Perc(p,v,stimc,imageIDarray)
% point is to find the index which the value was included.
[~,indHRC] = PerV(p,v.HRC);
[~,indk2] = PerV(p,v.k2);
[~,indk3] = PerV(p,v.k3);
[~,indConvK31] = PerV(p,v.ConvK3(:,1));
[~,indConvK32] = PerV(p,v.ConvK3(:,2));
[~,indPSK31] = PerV(p,v.PSK3(:,1));
[~,indPSK32] = PerV(p,v.PSK3(:,2));

ind = indHRC & indk2 & indk3 & indConvK31 & indConvK32...
    & indPSK31 & indPSK32;

indDel = ~ind;


v.HRC(indDel) = [];
v.k2(indDel) = [];
v.k3(indDel) = [];
v.real(indDel) = [];

%v.MC(indDel,:) = [];
v.ConvK3(indDel,:) = [];
v.PSK3(indDel,:) = [];
v.AutoK2(indDel,:) = [];

stimc.std(indDel) = [];
stimc.max(indDel) = [];
imageIDarray(indDel) = [];

end

