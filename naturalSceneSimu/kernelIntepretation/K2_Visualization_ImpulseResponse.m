function [K2_visualization_impulse,K2_visualization_glider] = K2_Visualization_ImpulseResponse(K2, varargin)
dtxy_bank = -16:1:16;
tMax = 64;
tMaxShow = 61;
maxTau = 64;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% change the plot to the most recent tau.
K2_visualization_impulse = zeros(tMax, length(dtxy_bank));
K2_visualization_glider = zeros(length(dtxy_bank), 1);
    for jj = 1:1:length(dtxy_bank)
        dtxy = dtxy_bank(jj);
        wind = K2ToGlider_Untils_ConstructWindMask(dtxy, tMax, maxTau);
        K2_visualization_impulse(1:sum(wind(:)),jj) = K2(wind(:) == 1);
    end
K2_visualization_impulse = K2_visualization_impulse(1:tMaxShow, :,:);
for ii = 1:1:1
    K2_visualization_glider(:,ii) = sum(K2_visualization_impulse, 1);
end

end
