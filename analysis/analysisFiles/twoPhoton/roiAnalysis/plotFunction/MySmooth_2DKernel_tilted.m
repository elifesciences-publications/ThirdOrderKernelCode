function k_ = MySmooth_2DKernel_tilted(k)

        % k = kernels(:,14,2);
        maxTau = round(sqrt(length(k)));
        k = reshape(k,[maxTau,maxTau]);
        % h_smooth = fspecial('disk', 1);
%         h_smooth = fspecial('gaussian',3);
        a = 0.2;
        h_smooth = [a/2,a/4,0,0;a/4,a,a/2,0;0,a/2,a,a/4;0,0,a/4,a/2];
        % gaussian might not be a very good idea...
        k_ = imfilter(k,h_smooth,'replicate');
        k_ = k_(:);
end