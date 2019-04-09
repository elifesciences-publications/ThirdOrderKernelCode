function kernel_smooth = MyImfilter(kernel,h_smooth,smoothRange,order)
switch order
    case 1
        nBar = size(kernel,2);
        kernel_double = repmat(kernel,[1,2]);
        kernel_double_smooth = imfilter(kernel_double,h_smooth,'replicate');
        kernel_smooth = kernel_double_smooth(:,[nBar + 1:nBar + smoothRange,smoothRange + 1:nBar]);
    case 2
        maxTauSquared = size(kernel,1);
        maxTau = round(sqrt(maxTauSquared));
        % for second order kernel, the smoothRange does not work very well.
        % for second order kernel, use your own h_smooth;
        kernel = reshape(kernel,[maxTau,maxTau]);
        kernel_smooth = imfilter(kernel, h_smooth,'replicate');
        kernel_smooth = kernel_smooth(:);
end
%     MakeFigure;
%
%     subplot(2,2,1);
%     quickViewOneKernel(kernel,1);
%     subplot(2,2,3);
%     quickViewOneKernel(kernel_smooth,1);
%     subplot(2,2,2);
%     quickViewOneKernel(kernel_double,1);
%     subplot(2,2,4);
%     quickViewOneKernel(kernel_double_smooth,1);
%     MakeFigure;
% 
%     subplot(2,2,1);
%     quickViewOneKernel(kernel(:),2);
%     subplot(2,2,3);
%     quickViewOneKernel(kernel_smooth,2);
%     subplot(2,2,2);
%     quickViewOneKernel(kernel_double,1);
%     subplot(2,2,4);
%     quickViewOneKernel(kernel_double_smooth,1);

end