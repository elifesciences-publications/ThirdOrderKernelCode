function flatKernel = My_SVD_K2_Flattened(kernel, varargin)
% first, get the relevant point out.
timeUnit = 1/60;
dtxy_bank = [-5:-1,1:5];
tMax = 48;
plot_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

maxTauSquared = length(kernel);
maxTau = round(sqrt(maxTauSquared));

ind = 1:1:maxTau^2;
ind = reshape(ind,[maxTau,maxTau]);

nDt = length(dtxy_bank);
indOffDia = zeros(tMax,nDt);
for ii = 1:1:nDt
    temp = diag(ind,dtxy_bank(ii));
    indOffDia(:,ii) = temp(1:tMax);
end

flatKernel = zeros(tMax,nDt);
for ii = 1:1:nDt
    flatKernel(:,ii) = kernel(indOffDia(:,ii));
end

if plot_flag
    
    [U,S,V] = svd(flatKernel);
    U = U;
    V = V;
    kernel1Component = U(:,1) * S(1, 1) *  V(:,1)';
    % predicted 2 second order by svd;
    kernelFromSVD = zeros(size(kernel));
    for ii = 1:1:nDt
        kernelFromSVD((indOffDia(:,ii))) =  kernel1Component(:,ii);
    end

    maxVal = max(abs(kernel(:)));
    MakeFigure;
    subplot(3,3,1);
    quickViewOneKernel(kernel,2);
    title('original kernel');
    % title(titleStr);
    subplot(3,3,2);
    quickViewOneKernel(flatKernel,1,'labelFlag',false, 'set_clim_flag', true, ' clim',maxVal);
    title('flattened kernel');
    subplot(3,3,3);
    scatter(1:size(S, 2), diag(S), 'k.');
    title('S')
    
    subplot(3,3,4);
    quickViewOneKernel(kernelFromSVD,2,'set_clim_flag', true, ' clim',maxVal);
    title('kernel recovered from svd');
    
    subplot(3,3,5);
    quickViewOneKernel(kernel1Component,1,'labelFlag',false, 'set_clim_flag', true, ' clim',maxVal);
    title('flattened kernel recovered from svd');
    
    subplot(3,3,7);
    quickViewOneKernel(kernel - kernelFromSVD,2,'set_clim_flag', true, ' clim',maxVal);
    title('residual kernel');
    
    subplot(3,3,8);
    quickViewOneKernel(flatKernel - kernel1Component, 1,'labelFlag',false, 'set_clim_flag', true, ' clim',maxVal);
    title('residual flattened kernel');
    
    
    subplot(6,3,9);
    plot(timeUnit * (1:tMax),U(:,1)/norm(U(:,1)));
    xLim = get(gca,'XLim'); yLim = get(gca,'YLim'); hold on;
    plot(xLim,[0,0],'k--');plot([0,0],yLim,'k--');
    title('along diagonal kinetics')
    subplot(6,3,12);
    plot(dtxy_bank * timeUnit,V(:,1)/norm(V(:,1)));
    xlabel('time[s]');
    xLim = get(gca,'XLim'); yLim = get(gca,'YLim'); hold on;
    plot(xLim,[0,0],'k--');plot([0,0],yLim,'k--');
    xlabel('time[s]');
    title('dt response');
    %% look at the middle one, whether it is diagnal...
    % MakeFigure;
    % A = zeros(maxTauSquared,1);
    % A(indOffDia(:,31)) = 1;
    % quickViewKernelsSecond(A)
end
end

