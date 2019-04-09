function [ vectors, hitInds ] = dezeroVect( vectors,val,thresh )
% Replaces all zeros with a nonzero val, returns de-zerod vector and vector
% of indices where this occurred. Assumes that these spots will be the same
% for all columns (goes based on first vector);

if nargin < 3
    thresh = 0;
end

for m = 1:size(vectors,1)
    if abs(vectors(m)) <= thresh
        vectors(m,:) = val;
        hitInds(m) = 1;
    else
        hitInds(m) = 0;
    end
end

numHits = sum(hitInds);
fprintf('%i entries were hit in dezeroing\n',numHits)

end

