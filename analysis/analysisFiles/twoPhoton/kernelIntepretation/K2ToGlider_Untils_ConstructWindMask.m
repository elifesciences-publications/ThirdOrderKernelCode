function wind = K2ToGlider_Untils_ConstructWindMask(dt,tMax,maxTau)
wind = true(maxTau,maxTau);
B = tril(wind,dt) .* triu(wind,dt); % how do you only choose part of it?
b = find(B == 1);
tMaxUse = min([length(b),tMax]);
b = b(1:tMaxUse);
wind = false(maxTau,maxTau);
wind(b) = 1;
wind = reshape(wind,maxTau,maxTau);
MakeFigure;
imagesc(wind);
end