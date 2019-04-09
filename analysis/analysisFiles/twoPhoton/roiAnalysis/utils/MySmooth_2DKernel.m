function k_ = MySmooth_2DKernel(k,varargin)
smooth_Level = 5;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% k = kernels(:,14,2);
maxTau = round(sqrt(length(k)));
k = reshape(k,[maxTau,maxTau]);
% h_smooth = fspecial('disk', 1);
%         h_smooth = fspecial('gaussian',3);
h_smooth = zeros(smooth_Level,smooth_Level);
fil = (smooth_Level:-1:1); fil = fil./sum(fil); 
h_smooth(eye(smooth_Level) == 1) = fil;
% gaussian might not be a very good idea...
k_ = imfilter(k,h_smooth,'replicate');
k_ = k_(:);
% 
% MakeFigure;
% subplot(221);quickViewOneKernel(k(:),2);
% subplot(222);quickViewOneKernel(k_,2);
end
