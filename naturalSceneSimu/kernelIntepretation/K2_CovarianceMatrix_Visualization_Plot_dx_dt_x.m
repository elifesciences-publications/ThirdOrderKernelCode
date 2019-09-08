function K2_CovarianceMatrix_Visualization_Plot_dx_dt_x(gliderRespPred, varargin)
saveFigFlag = false;
MainName = 'SecondOrder';
typeStr = [];
dt = [-12:1:12];
xBank = [7:14];
dxBank = [-6:6];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

MakeFigure;
for xx = 1:1:length(xBank)
    x_this = xBank(xx);
    % get the dt and dx plot.
    dt_dx_x_plot = squeeze(gliderRespPred(:,x_this,x_this + dxBank));
    subplot(2,4,xx)
    quickViewOneKernel(dt_dx_x_plot,1,'labelFlag',false);
    hold on
    
    if xx == 1
        title(sprintf([typeStr, ' spatial position = %d'],  x_this));
        
    else
        title(sprintf('spatial position = %d',  x_this));
    end
    set(gca,'XTick',1:length(dxBank),'XTickLabel',strsplit(num2str(dxBank)));
    xlabel('dx');
    
    set(gca,'YTick',1:length(dt),'YTickLabel',strsplit(num2str(dt)));
    ylabel('dt');
    hold on
    plot([find(dxBank == 0),find(dxBank == 0)],[0,length(dt)+ 1],'k-');
    plot([0,length(dxBank)+ 1],[find(dt == 0),find(dt == 0)],'k-');
    
end

set(gcf,'NumberTitle','off');
set(gcf,'Name',[MainName,'_dx_dt_x_plot_',typeStr]);
if saveFigFlag
    MySaveFig_Juyue(gcf,[MainName,'_dx_dt_x_plot_'],typeStr ,'nFigSave',2,'fileType',{'fig','png'});
end

% two plots...
MakeFigure;
for xx = 1:1:length(xBank)
    x_this = xBank(xx);
    % get the dt and dx plot.
    % flip the dt > 0 size.
    dx_less_than_zero_side = squeeze(gliderRespPred(:,x_this,x_this + dxBank(dxBank <= 0)));
    dx_more_than_zero_side = squeeze(gliderRespPred(:,x_this,x_this + dxBank(dxBank > 0)));
    dx_more_than_zero_side_flip = flipud(dx_more_than_zero_side);
    dt_dx_x_plot_flip = [dx_less_than_zero_side, dx_more_than_zero_side_flip];
    
    subplot(2,4,xx)
    quickViewOneKernel(dt_dx_x_plot_flip,1,'labelFlag',false);
    hold on
    
    if xx == 1
        title(sprintf([typeStr, ' spatial position = %d'],  x_this));
        
    else
        title(sprintf('spatial position = %d',  x_this));
    end
    set(gca,'XTick',1:length(dxBank),'XTickLabel',strsplit(num2str(dxBank)));
    xlabel('dx');
    
    set(gca,'YTick',1:length(dt),'YTickLabel',strsplit(num2str(dt)));
    ylabel('dt');
    hold on
    plot([find(dxBank == 0),find(dxBank == 0)],[0,length(dt)+ 1],'k-');
    plot([0,length(dxBank)+ 1],[find(dt == 0),find(dt == 0)],'k-');
    
end

set(gcf,'NumberTitle','off');
set(gcf,'Name',[MainName,'_dx_dt_x_plot_flip',typeStr]);
if saveFigFlag
    MySaveFig_Juyue(gcf,[MainName,'_dx_dt_x_plot_flip'],typeStr ,'nFigSave',2,'fileType',{'fig','png'});
end

