p = 10;

VVScatter(v.Real.data,v.HRC.data,p);
VVScatter(v.Real.data,v.K2.xy,p);
VVScatter(v.Real.data,v.K2.sym,p);

VVScatter(v.Real.data,v.K3.xxy,p);
VVScatter(v.Real.data,v.K3.yyx,p);
VVScatter(v.Real.data,v.K3.sym,p);

%% calucalte the scale of the velocity estimated by K2 and K3.
p = 5;
[vk2new,indk2] = VVScatter(v.Real.data,v.K2.sym,p);
[vk3new,indk3] = VVScatter(v.Real.data,v.K3.sym,p);

stdk2.old = std(v.K2.sym);
stdk2.new = std(vk2new);
stdk3.old = std(v.K3.sym);
stdk3.new = std(vk3new);

% the extreme value comes from almost the same sets of pictures.
% kill them...
