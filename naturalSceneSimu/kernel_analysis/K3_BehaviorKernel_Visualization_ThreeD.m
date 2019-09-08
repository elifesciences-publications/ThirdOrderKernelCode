function K3_BehaviorKernel_Visualization_ThreeD(k3_sym, dtxx_bank, dtxy_bank, varargin)
maxTauShow = 61;
lineWidth = 1;
fontSize = 8;
h.Units = 'points';
h.Position = [100,100,200,200];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%%
k3_sym = k3_sym(1:maxTauShow, 1:maxTauShow, 1:maxTauShow);
k3_sym_permute = permute(k3_sym, [3, 1, 2]); % right, left left. change
% the position of am
maxTau = size(k3_sym, 1);
x = 1:maxTau;
[meshX,meshY,meshZ] = meshgrid(x,x,x);
tMax = maxTauShow;
axes('Units', h.Units,'Position', h.Position);

for ii = 1:1:length(dtxx_bank)
    for jj = 1:1:length(dtxy_bank)
        dtxx = dtxx_bank(ii);
        dtxy = dtxy_bank(jj);
        [wind, ~] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);
        %          K3(wind(:) == 1)
        wind_permute = permute(wind, [3, 1, 2]);
        scatter3(meshX(wind_permute(:) == 1), meshY(wind_permute(:) == 1), meshZ(wind_permute(:) == 1), 5, k3_sym_permute(wind_permute(:) == 1),'MarkerFaceColor', 'flat','lineWidth',lineWidth,'MarkerEdgeColor','flat','Marker', 'o');
        hold on
        
    end
end
maxVal = max(abs(k3_sym(:)));
set(gca, 'clim',[-maxVal, maxVal]);
colormap_gen;
colormap(mymap);
% xl = xlabel('\tau1, left bar (s)');
% yl = ylabel('\tau3, left bar(s)');
% zl = zlabel('\tau2, right bar(s)');
% permute

set(gca, 'XLim',[0.5, maxTauShow], 'YLim',[0.5, maxTauShow], 'ZLim',[0.5, maxTauShow]);
%%

% view([20,8]);
view([8,11]);


set(gca,'BoxStyle','full');
% set(gca, 'XAxisLocation', 'origin');
% set(gca, 'YAxisLocation', 'right');
ax = gca;
ax.ZDir = 'reverse';
ax.Units = 'inches';
grid off
box on
colorbar_position = [h.Position(1)+ h.Position(3) + 0.2, h.Position(2), 0.2, h.Position(4)];
h_colorbar = colorbar(gca, 'Units',h(1, 1).Units, 'Position', colorbar_position);
h_colorbar.Label.String = sprintf('filter strength \n ^o/c^3/s^4');

High_Corr_PaperFig_Utils_SmallFontSize
xlim = get(gca,'XLim');ylim = get(gca,'YLim');zlim = get(gca,'ZLim');
xl = xlabel('\tau2, right bar[s]');
yl = ylabel('\tau3, left bar[s]');
zl = zlabel('\tau1, left bar[s]');

% set(xl, 'Position', [tMax/2, tMax/2, -3], 'HorizontalAlignment', 'center');
% set(yl, 'Position', [-20, 0, 0], 'Rotation', 60);

%%
time_tick = [1,16,31,46,61];
time_tick_label = strsplit(num2str([0,0.25,0.5,0.75,1.0]));
% using text to do the ticklabel.


set(gca, 'ZTick',time_tick,'ZTickLabel',time_tick_label);
set(gca, 'TickLength',[0.01,0.01]);
set(gca, 'XTick',time_tick,'XTickLabel',time_tick_label);
set(gca, 'YTick',time_tick,'YTickLabel',time_tick_label);
% set(gca, 'XTick',[],'YTick',[]);
% for xx = 1:1:length(time_tick)
%     text(time_tick(xx),0,-2,time_tick_label{xx},'FontSize',fontSize); % xtick, location 
%     text(-10,time_tick(xx),0,time_tick_label{xx},'FontSize',fontSize); % ytick, location 
% end

end