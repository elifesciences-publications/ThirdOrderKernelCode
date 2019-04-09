function [ outfilt ] = removeDiag3( infilt )
% Removes the diagonal in the 1-2 plane 

maxTau = length(infilt);

for q = 1:maxTau
    removeDiag3(:,:,q) = ones(maxTau) - eye(maxTau);
    removeDiag3(1:end-1,2:end,q) = removeDiag3(1:end-1,2:end,q) - eye(maxTau-1);
    removeDiag3(2:end,1:end-1,q) = removeDiag3(2:end,1:end-1,q) - eye(maxTau-1);
end

outfilt = infilt .* removeDiag3;

end

