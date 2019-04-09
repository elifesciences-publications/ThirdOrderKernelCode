function [gliderPreResp,dt] = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(kernel,varargin)
% maxTauUse = 30;
dtMax = 30;
dt = [-dtMax:1:dtMax]; % dt could be quite different...
tMax = 30;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

maxTauSquared = size(kernel,1);
maxTau = round(sqrt(maxTauSquared));

% calculate the mean along each diagnol.
ind = 1:1:maxTau^2;
ind = reshape(ind,[maxTau,maxTau]);

nDt = length(dt);
indOffDia = zeros(tMax,nDt);
for ii = 1:1:nDt
    temp = diag(ind,dt(ii));
    indOffDia(:,ii) = temp(1:tMax);
end
% 
% MakeFigure;
% for ii = 1:1:30
%     subplot(5,6,ii);
%     A = zeros(maxTau,maxTau);
%     A(indOffDia(:,ii)) = 1;
%     imagesc(A)
% end
gliderPreResp = zeros(nDt,1);
for ii = 1:1:nDt
    gliderPreResp(ii) = mean(kernel(indOffDia(:,ii)));
end
end
