function [ getLocs ] = glidCovmat( disp2,disp3,maxTau )
% Enter X2-X1 and X3-X1. Returns locations of significant elements in
% positive covariance matrices.

gridAxis = [0:maxTau-1];
[ X1 X2 X3 ] = meshgrid(gridAxis, gridAxis, gridAxis);
% X1 = X1(:); X2 = X2(:); X3 = X3(:);
getLocs = ( X2 - X1 == disp2 ) .* ( X3 - X1 == disp3 );
% seeLocs = reshape(getLocs,[maxTau maxTau maxTau]);
% threeDvisualize_corner(seeLocs,0);
% keyboard

end

