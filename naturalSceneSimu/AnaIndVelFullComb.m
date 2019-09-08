function [theo,exp,vValue] = AnaIndVelFullComb(res)
nv = length(res.exp);
%%
vValue = zeros(nv,1);

%%
exp.r.k2 = zeros(nv,1);
exp.r.k3 = zeros(nv,1);
exp.r.k2plusk3 = zeros(nv,1);
exp.r.best = zeros(nv,1);
exp.weight =  zeros(2,nv);
exp.mut.r = zeros(nv,3);
%% there could still be several other correlation could be done.
theo.r.HRC = zeros(nv,1);
theo.r.ConvK3 = zeros(nv,2);
theo.r.bestConvK3 = zeros(nv,1);
theo.weight.ConvK3 = zeros(2,nv);
theo.r.PSK3 = zeros(nv,2);
theo.r.bestPSK3 = zeros(nv,1);
theo.weight.PSK3 = zeros(2,nv);
theo.r.AutoK2 = zeros(nv,4);
theo.r.bestAutoK2 = zeros(nv,1);
theo.weight.AutoK2 = zeros(4,nv);
theo.r.HRCConvK3 = zeros(nv,1);
theo.weight.HRCConvK3 = zeros(3,nv);
theo.r.HRCPSK3 = zeros(nv,1);
theo.weightHRCPSK3 = zeros(3,nv);
theo.r.HRCCP = zeros(nv,1);
theo.weight.HRCCP = zeros(5,nv);
theo.mut.r = zeros(nv,70,70);
theo.mut.rroi = zeros(nv,9,9);

for vv = 1:1:nv
     
    %% exeperiment one.
    exp.r.HRC(vv) = res.exp{vv}.r.HRC;
    exp.r.k2(vv) = res.exp{vv}.r.k2;
    exp.r.k3(vv) = res.exp{vv}.r.k3;
    exp.r.k2plusk3(vv) = res.exp{vv}.r.k2plusk3;
    exp.r.best(vv) = res.exp{vv}.r.best;
    exp.weight(:,vv) = res.exp{vv}.weight;
    exp.mut.r(vv,:) = res.exp{vv}.mut.r;
    
    %% theoretical one.
    theo.r.HRC(vv) = res.theo{vv}.r.HRC;
    theo.r.ConvK3(vv,:) = res.theo{vv}.r.ConvK3;
    theo.r.bestConvK3(vv) = res.theo{vv}.r.bestConvK3;
    theo.weight.ConvK3(:,vv) = res.theo{vv}.weight.ConvK3;
    theo.r.PSK3(vv,:) = res.theo{vv}.r.PSK3;
    theo.r.bestPSK3(vv) = res.theo{vv}.r.bestPSK3;
    theo.weight.PSK3(:,vv) = res.theo{vv}.weight.PSK3;
    theo.r.AutoK2(vv,:) = res.theo{vv}.r.AutoK2;
    theo.r.bestAutoK2(vv) = res.theo{vv}.r.bestAutoK2;
    theo.weight.AutoK2(:,vv) = res.theo{vv}.weight.AutoK2;
    theo.r.HRCConvK3(vv) = res.theo{vv}.r.HRCConvK3;
    theo.weight.HRCConvK3(:,vv) =res.theo{vv}.weight.HRCConvK3;
    theo.r.HRCPSK3(vv) = res.theo{vv}.r.HRCPSK3;
    theo.weight.HRCPSK3(:,vv) = res.theo{vv}.weight.HRCPSK3;
    theo.r.HRCCP(vv) = res.theo{vv}.r.HRCCP;
    theo.weight.HRCCP(:,vv) = res.theo{vv}.weight.HRCCP;
  %  theo.mut.r(vv,:,:) = res.theo{vv}.mut.r;
    theo.mut.rROI(vv,:,:) = res.theo{vv}.mut.rROI;
    
    %%
    vValue(vv) = res.exp{vv}.vreal;
end

end