function k_smooth = MySmooth_2DImpulseKernel(kernel,varargin)
smoothDim = 1; % 1 or 2. nearby points...
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
switch smoothDim
    case 1
        smoothLevel = 3;
        h_smooth = zeros(smoothLevel,smoothLevel); % odd number
        h_smooth(:,ceil(smoothLevel/2)) = ones(smoothLevel,1)/smoothLevel;
    case 2
        a = 0.4;
        h_smooth = [0,a/4,0;a/2,a,a/2;0,a/4,0]';
end
k_smooth  = imfilter(kernel,h_smooth,'replicate');

% MakeFigure;
% subplot(221);quickViewOneKernel(kernel,1);
% subplot(222);quickViewOneKernel(k_lowess,1);