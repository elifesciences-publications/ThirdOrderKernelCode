% you should separate glider response calculation and plot making...
function gliderRespPred = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat,varargin)
nMultiBars = 20;

dt = [-12:1:12]; % is this dt long enough? should be. should be good enought. dt 200 ms.
tMax = 20; % you have to find a better interval to integral. change this later on.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
maxTau = size(cov_mat,1)/nMultiBars;


gliderRespPred = zeros(length(dt),nMultiBars,nMultiBars);
for ii = 1:1:nMultiBars
    for jj = 1:1:nMultiBars
        indi = (ii - 1) * maxTau + 1: ii * maxTau;
        indj = (jj - 1) * maxTau + 1: jj * maxTau;
        kernel2o = cov_mat(indi,indj);
        gliderRespPred(:,ii,jj) = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(kernel2o(:),'dt',dt,'tMax',tMax);
    end
end
