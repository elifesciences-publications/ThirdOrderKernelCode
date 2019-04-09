function xt_filters = VelocityEstimation_Utils_GenerateSTE()
pars = shPars;
filters = shMkV1Filter(pars, [0,1;pi,1]); % right and left.
xt_filters = squeeze(filters(1,:,:,:)); % first dimention is y. useless
% subplot(2,2,1)
% quickViewOneKernel(xt_filters(:,:,1), 1);
% title('f1');
% subplot(2,2,2)
% quickViewOneKernel(xt_filters(:,:,2), 1);
% title('f2');

end