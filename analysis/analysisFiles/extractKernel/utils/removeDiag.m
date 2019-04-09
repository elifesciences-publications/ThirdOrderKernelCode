function [ outfilt ] = removeDiag( infilt )
% Removes the diagonal in the 1-2 plane 

maxTau = length(infilt);

for q = 1:maxTau
    diagless(:,:,q) = ones(maxTau) - eye(maxTau);
end

outfilt = infilt .* diagless;

end

