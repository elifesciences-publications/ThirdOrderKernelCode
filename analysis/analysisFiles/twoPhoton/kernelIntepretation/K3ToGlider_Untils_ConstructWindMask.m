function [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx,dtxy,tMax,maxTau, varargin)
% nan_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
wind = zeros(maxTau,maxTau,maxTau);
ind = zeros(tMax, 1);
for tt = 1:1:tMax
        if tt + dtxx > 0 && tt + dtxx <= maxTau && tt + dtxy > 0 && tt + dtxy <= maxTau
            wind(tt,tt + dtxx,tt + dtxy) = true;
            ind(tt) = 1;
        else
            ind(tt) = nan;
        end
end
%     a = find(wind);
%     [subI,subJ,subK] = ind2sub([maxTau,maxTau,maxTau],a)
end