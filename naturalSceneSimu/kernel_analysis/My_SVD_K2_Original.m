function My_SVD_K2_Original(k2)
[U,S,V] = svd(k2);
MakeFigure;
subplot(3, 3, 1);
scatter(1: length(diag(S)),diag(S), 'filled');
title('S');
subplot(3, 3, 4);
quickViewOneKernel(k2(:), 2);
title('original k2');
k2_sym_left = k2;
maxVal = max(abs(k2(:)));
for ii = 1:1:2
    u = U(:,ii);
    v = V(:,ii); % what is left.
    k_comopnent = u * S(ii,ii) * v';
    
    subplot(6, 3, ii+ 1);
    plot(u);
    title(sprintf('U%d', ii));
    subplot(6, 3, ii + 1 + 3);
    plot(v);
    title(sprintf('V%d', ii));
    
    subplot(3, 3, ii + 1 + 3);
    quickViewOneKernel( k_comopnent(:), 2,'set_clim_flag', true, ' clim',maxVal)
    title('kernel recovered from svd');
    
    subplot(3, 3, ii + 1 + 6);
    k2_sym_left = k2_sym_left - k_comopnent;
    quickViewOneKernel( k2_sym_left(:), 2,'set_clim_flag', true, ' clim',maxVal)
    title('residual k2');
end
end