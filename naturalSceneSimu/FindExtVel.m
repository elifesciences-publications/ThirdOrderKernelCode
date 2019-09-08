function ind = FindExtVel(v,mode,p,next)
% v stores the velocity your are interested in.
% mode = 'percentile', find a certain percentile of the stimulus
% mode = 'number', find a certain number of extrem values.
% p, used when mode is used.

% returned value, indices of extreme predictred velocity. sorted by the value of the v.
switch mode
    case 'percentile'
        [~,ind] = PerV(p,v);
        ind = ~ind;
        % the indices of the extreme value is stored in ind;
    case 'number'
        [~,I] = sort(v);
        ind = false(length(v),1);
        ind(I(1:next)) = true;
        ind(I(end - next + 1 : 1: end)) = true;        
end
% get the velocity which is sorted by the value. and sort them...
vextr = v(ind);
indext = find(ind == 1);

[~,I] = sort(abs(vextr),'descend');
% from large to small.
ind = indext(I);
end