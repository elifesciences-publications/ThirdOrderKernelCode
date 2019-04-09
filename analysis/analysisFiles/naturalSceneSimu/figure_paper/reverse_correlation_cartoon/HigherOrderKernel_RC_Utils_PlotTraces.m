function HigherOrderKernel_RC_Utils_PlotTraces(x, color, varargin)
mode = 'vertical';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
N = length(x);
for nn = 1:1:N
    % four lines.
    % if the previous points have the same value, do not plot the first
    % stroke
    % if the next point have the same value, do not plot the last.
    % do not plot the first stroke and last stroke.
    
    if nn > 1
        plot([nn-0.5,nn-0.5],[x(nn-1),x(nn)],'color',color); hold on;
        %     else
        %         plot([nn-0.5,nn-0.5],[0,x(nn)],'color',color); hold on;
    end
    plot([nn - 0.5,nn + 0.5],[x(nn),x(nn)],'color',color); hold on;
    if nn < N
        plot([nn+0.5, nn+0.5], [x(nn), x(nn + 1)],'color',color); hold on;
        %     else
        %         plot([nn+0.5, nn+0.5], [x(nn), 0],'color',color); hold on;
    end
end
set(gca,'XAxisLocation','origin');
set(gca,'YAxisLocation','origin');
ylim_max = max(abs(get(gca, 'yLim')));
set(gca, 'XTick',[],'YTick',[]);
set(gca,'XLim',[0.5,N+0.5]);
set(gca, 'YLim',[-ylim_max, ylim_max]);
if strcmp(mode, 'vertical')
    view(90,90)
end

box off

end