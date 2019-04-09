function k_lowess = MySmooth_1DKernel(kernel,varargin)
smoothLevel = 3;
method = 'moving';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

k_lowess = zeros(size(kernel));
nMultiBars = size(kernel,2);
for qq = 1:1:nMultiBars
    switch method
        case 'moving'
    k_lowess(:,qq) = smooth(kernel(:,qq),smoothLevel,'moving');
        case 'decaying'
            h_smooth = smoothLevel :-1:1; h_smooth = h_smooth./sum(h_smooth);
            k_lowess(:,qq) = filter(h_smooth,1,kernel(:,qq));
    end
end
% MakeFigure; 
% subplot(221);quickViewOneKernel(kernel,1);
% subplot(222);quickViewOneKernel(k_lowess,1);