function dx_full = STC_Utils_CovMatToSecondKernel(cov_mat,varargin)
% you have to change the covmat into secondorder kernel, so that you can
% alignthem together.

% you can double check your idea
% first, check how should you
nMultiBars = 20;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
maxTau = size(cov_mat,1)/nMultiBars;
cov_mat_cell_ori = mat2cell(cov_mat,ones(nMultiBars,1)*maxTau, ones(nMultiBars,1)*maxTau);
dxBank = 0:nMultiBars - 1;
dx_full = cell(nMultiBars,1);
for ii = 1:1:nMultiBars
    dx_this = dxBank(ii);
    for xx = 1:1:nMultiBars
        xx_left = xx;
        xx_right = MyMode(xx_left + dx_this,nMultiBars);
        
        cov_mat_this = cov_mat_cell_ori{xx_left, xx_right};
        dx_full{ii}(:,xx_left) = cov_mat_this(:);
    end
    
end
end