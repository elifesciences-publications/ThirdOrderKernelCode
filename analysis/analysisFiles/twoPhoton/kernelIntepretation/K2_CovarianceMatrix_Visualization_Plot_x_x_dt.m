function K2_CovarianceMatrix_Visualization_Plot_x_x_dt(gliderRespPred,varargin)
saveFigFlag = false;
MainName = 'SecondOrder';
nMultiBars = 20;
typeStr = [];
dt = [-12:1:12];
xBank = [7:14];
dxBank = [-5:5];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% how are you going to plot them?
MakeFigure;
% % this can only haldle dt from -8 to 8. This might not be the final. do
% not worry about it.

for ii = 1:1:(length(dt) + 1)/2
    subplot(3,3,ii)
    a = find(dt >= 0);
    % decide which to plot.
    
    x_x_dt_plot = zeros(length(xBank),nMultiBars);
    for jj = 1:1:length(xBank)
        x_this = xBank(jj);
        x_x_dt_plot(jj, x_this + dxBank) =squeeze(gliderRespPred(a(ii), x_this,x_this + dxBank)); % use zeros.
    end
    
    quickViewOneKernel(x_x_dt_plot,1,'labelFlag',false);
    hold on
    plot([xBank(1) - 1,xBank(end) + 1],[1 - 1,length(xBank) + 1],'k-');
    plot([0,nMultiBars + 1],[length(xBank)/2 + 0.5,length(xBank)/2 + 0.5],'k-');
    
    if ii == 1
        title(sprintf([typeStr, '  dt = %d'], dt(a(ii))));
        
    else
        title(sprintf('dt = %d', dt(a(ii))));
    end
    set(gca,'XTick',1:2:20,'XTickLabel',strsplit(num2str(1:2:20)));
    xlabel('spatial position');
    
    set(gca,'YTick',1:length(xBank),'YTickLabel',strsplit(num2str(xBank)));
    ylabel('spatial position');
end
set(gcf,'NumberTitle','off');
set(gcf,'Name',[MainName,'_x_x_dt_plot_',typeStr]);
if saveFigFlag
    MySaveFig_Juyue(gcf,[MainName,'_x_x_dt_plot_'],typeStr ,'nFigSave',2,'fileType',{'fig','png'});
end
end