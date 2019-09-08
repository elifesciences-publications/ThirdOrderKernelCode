function D = MySortD(D)
% sort D, so that the D(1) has the smallest real velocity.
nv = length(D);
vValue = zeros(nv,1);
for vv = 1:1:nv
    vValue(vv) = abs(D{vv}.v.real(1));
end
[~,I] = sort(vValue);
D = D(I);
end