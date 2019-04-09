%% calculate the power of second / third order kernel
k2power = K2.k2_xy.^2;
k2power = sum(k2power(:));

k3power.xxy = K3.k3_xxy.^2;
k3power.xxy = sum(k3power.xxy(:));

k3power.yyx = K3.k3_yyx.^2;
k3power.yyx = sum(k3power.yyx(:));

k3power.sym = K3.k3_sym.^2;
k3power.sym = sum(k3power.sym(:));

%% calculate the sum of second/third order kernel
k2sum = sum(K2.k2_xy(:));
k3sum.xxy = sum(K3.k3_xxy(:));
k3sum.yyx = sum(K3.k3_yyx(:));