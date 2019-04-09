function K3_BehaviorKernel_Visualization_ThreeD_Slice(k3_sym, dtxx_bank, varargin)
maxTauShow = 61;
lineWidth = 1;
fontSize = 8;
h = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%%
k3_sym = k3_sym(1:maxTauShow, 1:maxTauShow, 1:maxTauShow);
maxVal = max(abs(k3_sym(:)));

for ii = 1:1:3
    axes('Units', 'Inches','Position', h(ii).Position);
    dt_xx = dtxx_bank(ii);
    k3_this_page = squeeze(k3_sym(:,dt_xx, :));
    k3_sym_mean_show = k3_this_page(1:maxTauShow,1:maxTauShow);
    quickViewOneKernel(k3_sym_mean_show(:), 2, 'set_clim_flag',true, 'clim', maxVal,'colorbarFlag',false);
    set(gca, 'XAxisLocation','top');
    if ii == 1
        xlabel('\tau2, right bar [s]');
        ylabel('\tau1, left bar [s]');
    else
        set(gca, 'YTick',[],'XTick',[]);
        xlabel('');
        ylabel('');
    end
    text(30, -20, ['\tau3-\tau1 = ', num2str(dt_xx/60 *1000,2),' [ms]'], 'HorizontalAlignment', 'center');
    
    if ii == 3
        colorbar_position = [h(ii).Position(1)+ h(ii).Position(3) + 0.2, h(ii).Position(2), 0.2, h(ii).Position(4)];
        h_colorbar = colorbar(gca, 'Units',h(1, 1).Units, 'Position', colorbar_position);
        h_colorbar.Label.String = sprintf('filter strength \n ^o/c^3/s^4');
    end
    High_Corr_PaperFig_Utils_SmallFontSize()
    
end
end