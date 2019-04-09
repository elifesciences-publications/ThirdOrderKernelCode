function [v_xy,v_sym ]= MotionCalculatorK2(K2,data,time)

tf = K2.param.t;
tS = time.t;
% sampling frequency when the filter is calculated.
% make sure that the s1 is a vertical vector.
s1 = data.s1;
% V1 = interp1(tS,s1,tf,'linear');
V1 = MyInterp1(tS,s1,tf);
V1 = reshape(V1,[length(V1),1]);
V1flip = flipud(V1);
% s1 = reshape(s1,[length(s1),1]);
% s1flip = flipud(s1);
% V1 = interp1(tS,s1flip,tf,'linear');

s2 = data.s2;
%V2 = interp1(tS,s2,tf,'linear');
V2 = MyInterp1(tS,s2,tf);
V2 = reshape(V2,[length(V2),1]);
V2flip = flipud(V2);
% s2 = reshape(s2,[length(s1),1]);
% s2flip = flipud(s2);
% V2 = interp1(tS,s2flip,tf,'linear');

% for second order kernel, the sampling rate should be considered.
% k2_sym = K2.k2_sym /(K2.param.dt)^2;
% % k2_xy = K2.k2_xy/(K2.param.dt)^2;
% 
% k2_sym = K2.k2_sym * (K2.param.dt)^2;
% k2_xy = K2.k2_xy * (K2.param.dt)^2;


k2_sym = K2.k2_sym;
k2_xy = K2.k2_xy;

% set the diagonal elements to zero.

v_sym = V1flip' * k2_sym * V2flip;
v_xy = V1flip' * k2_xy * V2flip;

end