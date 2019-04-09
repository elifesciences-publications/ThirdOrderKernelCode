function [ outmat ] = Stretch( inmat, mfactor, nfactor )
% "Stretches" an input matrix by repeating all of its elements factor
% times.

inm = size(inmat,1);
inn = size(inmat,2);
outmat = zeros(inm*mfactor,inn*nfactor);

for ii = 1:inm
    for jj = 1:inn
        outmat(1+(ii-1)*mfactor:ii*mfactor,...
               1+(jj-1)*nfactor:jj*nfactor) = repmat(inmat(ii,jj),mfactor,nfactor);
    end
end

end

