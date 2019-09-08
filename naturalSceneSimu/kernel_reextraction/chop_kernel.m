function kernel = chop_kernel(kernel, order)
switch order
    case 2
        maxTau = round(sqrt(length(kernel)));
        wind = chop_kernel_utils_create_window_k2(maxTau);
    case 3
        maxTau = round(length(kernel)^(1/3));
        wind = chop_kernel_utils_create_window_k3(maxTau);  
end
kernel(wind ~= 1) = 0;


end

function wind_all = chop_kernel_utils_create_window_k3(maxTau)
% This function wrong for the first round.
dtxx_bank = 1:1:4;
tMax = 50;
wind_all = zeros(maxTau, maxTau, maxTau);
for ii = 1:1:length(dtxx_bank)
    dtxx = dtxx_bank(ii);
    dtxy_bank = -4:1:dtxx + 4;
    for jj = 1:1:length(dtxy_bank)
        dtxy = dtxy_bank(jj);
        [wind, ~] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag',false);
        wind_all = (wind_all == 1 | wind == 1);
    end
end

for ii = 1:1:maxTau
    wind_all(:,:,ii) = wind_all(:,:,ii) | wind_all(:,:,ii)';
end
% MakeFigure;
% %         k3_sym = reshape(kernel, [maxTau, maxTau, maxTau]);
% for ii = 1:1:20
%     k3_oneslice = wind_all(:,:,ii);
%     subplot(4, 5, ii);
%     quickViewOneKernel(k3_oneslice(:), 2);
% end
end
function wind = chop_kernel_utils_create_window_k2(maxTau)
A = true(maxTau, maxTau);
wind = triu(A, -5) & tril(A, 5);
end

%
% MakeFigure;
% k3_sym = reshape(kernel, [maxTau, maxTau, maxTau]);
% for ii = 1:1:5
%     k3_oneslice =  wind(:,:,ii);
%     subplot(3, 2, ii);
%     quickViewOneKernel(k3_oneslice(:), 2);
% end