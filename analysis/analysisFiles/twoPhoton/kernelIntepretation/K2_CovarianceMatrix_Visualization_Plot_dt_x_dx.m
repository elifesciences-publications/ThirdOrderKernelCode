function K2_CovarianceMatrix_Visualization_Plot_dt_x_dx(gliderRespPred, varargin)
saveFigFlag = false;
MainName = 'SecondOrder';
typeStr = [];

dt = [-12:1:12]; % is this dt long enough? should be. should be good enought. dt 200 ms.
xBank = [6:15]; % has to been aligned...
dxBank = [0:5]; % dxBank? this has to be second order kernel, instead of covariance matrix...
same_color_scale_flag = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

dt_x_dx_plot = zeros(length(dt),length(xBank),length(dxBank));
if same_color_scale_flag
    max_value = max(abs(gliderRespPred(:)));
else
    max_value = [];
end

MakeFigure;
for dxx = 1:1:length(dxBank)
    dx_this = dxBank(dxx);
    for xx = 1:1:length(xBank)
        x_this = xBank(xx);
        dt_x_dx_plot(:,xx,dxx) = gliderRespPred(:,x_this,x_this + dx_this);
    end
    subplot(2,3,dxx)
    quickViewOneKernel( squeeze(dt_x_dx_plot(:,:,dxx)),1,'labelFlag',false);
    if dxx == 1
        title([typeStr, ' dx = ', num2str(dx_this)],'FontSize',30);
    else
        title(['dx = ', num2str(dx_this)],'FontSize',30);
    end
    ylabel('dt');
    xlabel('bar #');
    set(gca, 'YTick',1:length(dt), 'YTickLabel', strsplit(num2str(dt)));
    set(gca, 'XTick', 1:length(xBank), 'XTickLabel', strsplit(num2str(xBank)));
    hold on
    plot([0,length(xBank) + 1],[find(dt == 0), find(dt == 0)],'k--');
    
    
    ax.LineWidth = 2;
    set(gca,'FontSize',10,'box','off','FontName','Arial');
    ax = gca;
    ax.YLabel.FontSize = 20;
    ax.XLabel.FontSize = 20;
    ax.Title.FontSize = 20;
    
    if same_color_scale_flag
        set(gca,'CLim',[-max_value,max_value]);
    end
end

set(gcf,'NumberTitle','off');
set(gcf,'Name',[[MainName,'_dt_x_dx_plot'],typeStr]);
if saveFigFlag
    MySaveFig_Juyue(gcf,[MainName,'_dt_x_dx_plot'],typeStr ,'nFigSave',2,'fileType',{'fig','png'});
end

end