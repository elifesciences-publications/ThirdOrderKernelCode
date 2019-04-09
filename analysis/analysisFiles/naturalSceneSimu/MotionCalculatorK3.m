function [v_xxy,v_yyx,v_sym] = MotionCalculatorK3(K3,data,time)


tf = K3.param.t;
tS = time.t;

% sampling frequency when the filter is calculated.
% make sure that the s1 is a vertical vector.
s1 = data.s1;
% V1 = interp1(tS,s1,tf,'linear');
V1 = MyInterp1(tS,s1,tf);
V1 = reshape(V1,[length(V1),1]);
V1flip = flipud(V1);

s2 = data.s2;
% V2 = interp1(tS,s2,tf,'linear');
V2 = MyInterp1(tS,s2,tf);
V2 = reshape(V2,[length(V2),1]);
V2flip = flipud(V2);

% for second order kernel, the sampling rate should be considered.
% % normalize the filter


%% k3_sym = (k3_xxy - k3_yyx)/2; 
k3_xxy = K3.k3_xxy;
k3_yyx = K3.k3_yyx;
k3_sym = K3.k3_sym;

% compute velocity using third order kernel
[mesha,meshb,meshc] = ndgrid(V1flip,V1flip,V2flip);
Sxxy = mesha.* meshb.* meshc;
v_xxy = Sxxy.* k3_xxy;
v_xxy = sum(v_xxy(:));

[mesha,meshb,meshc] = ndgrid(V2flip,V2flip,V1flip);
Syyx = mesha.* meshb.* meshc;
v_yyx = Syyx.* k3_yyx;
v_yyx = sum(v_yyx(:));

% it might be wrong to calculate this way...
% it might be the reason I got such a wired result...
% I am destroy symmetry here...
v_sym = k3_sym.*(Sxxy - Syyx);
v_sym = sum(v_sym(:));

end