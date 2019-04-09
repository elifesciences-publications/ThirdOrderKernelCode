function [v_new,ind] = PerV(p,v)
% if p < 1
%     p = p * 100;
% end

percLow = prctile(v,p);
percHigh = prctile(v,100 - p);

ind = v > percLow & v < percHigh;
v_new = v(ind);
end