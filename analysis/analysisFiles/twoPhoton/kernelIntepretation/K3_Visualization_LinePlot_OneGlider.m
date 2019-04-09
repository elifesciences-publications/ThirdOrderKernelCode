function K3_Visualization_LinePlot_OneGlider(dt_bank, resp_mean, resp_sem, p_val, maxValue, varargin)
label_flag = true;
dx_label_flag = false;
dx = 0;
alpha  = 0.05;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

timeUnit = 1/60;
resp_mean = resp_mean / timeUnit^3;
resp_sem = resp_sem/timeUnit^3;

% this is third order kernel..
% shuffle_std = shuffle_std/timeUnit^3;
% shuffle_mean = shuffle_mean/timeUnit^3;
maxValue = maxValue/timeUnit^3;

PlotXY_Juyue(dt_bank',resp_mean,'errorBarFlag',true,'sem',resp_sem ,'limPreSetFlag',true,'maxValue',maxValue,...
    'colorMean',[1,0,0],'colorError',[1,0,0]);
% hold on; plot(dt_bank',shuffle_std + shuffle_mean,'b--'); plot(dt_bank',-shuffle_std + shuffle_mean,'b--');
FigPlot_SK_Utils_GliderSignificance(dt_bank',p_val,alpha, maxValue ,false);

XTick = get(gca, 'XTick');
XTickLabel = strsplit(num2str((dt_bank(ismember(dt_bank, XTick)) * 1/60),'%.3f '));
set(gca, 'XTick', XTick(ismember(XTick, dt_bank)), 'XTickLabel', XTickLabel);
ConfAxis


if label_flag
    xlabel('temporal interval [ms]');
    ylabel(['\deltaF /F / (contrast^3 * sec^3)'])
end

if dx_label_flag
    t = text(15, 0, [num2str(dx *  5),'degree']);
    t.FontSize = 20;

end
end