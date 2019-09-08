function [ outVect ] = CutPermute( inVect,cutVect )
% Takes a subset of a random permutation of N elements, cuts out elements
% in cutVect, and returns an even smaller subset of a random permutation of
% N elements.

% There /has/ to be a less ugly way to do this...

qq = 1;
while qq <= length(inVect)
    for rr = 1:length(cutVect)
        if inVect(qq) == cutVect(rr)
            inVect(qq) = [];
            qq = qq-1;
            break
        end
    end
    qq = qq+1;
end

newLen = length(inVect);
outVect = inVect(randperm(newLen));

end

