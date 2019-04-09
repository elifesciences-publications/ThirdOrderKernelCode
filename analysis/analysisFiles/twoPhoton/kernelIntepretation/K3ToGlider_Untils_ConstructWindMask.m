function wind = K3ToGlider_Untils_ConstructWindMask(dtxx,dtxy,tMax,maxTau)

wind = false(maxTau,maxTau,maxTau);
for tt = 1:1:tMax
    if tt + dtxx > 0 && tt + dtxx <= maxTau && tt + dtxy > 0 && tt + dtxy <= maxTau
        wind(tt,tt + dtxx,tt + dtxy) = true;
    end
end
%     a = find(wind);
%     [subI,subJ,subK] = ind2sub([maxTau,maxTau,maxTau],a)
end