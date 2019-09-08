function DistrHistPlotContr(allPixel, save_fig_flag, FWHM_bank, varargin)
% % strInfo contains title/xlabel/ylabel.legend is included.
title_str = 'histogram of contrast';

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% FWHM_bank = [10,15,20,25,35,40,45, 50,55,60, 75, 100, 360];
makeFigure
ndata  =length(allPixel);
h = cell(ndata,1);
centers = cell(ndata,1);
p = cell(ndata,1);
for ii = 1:1:ndata
    h{ii} = histogram(allPixel{ii}(:));
    hold on;
end

binWidthMin  = 1000000000;

for ii = 1:1:ndata
    if h{ii}.BinWidth < binWidthMin
        binWidthMin = h{ii}.BinWidth;
    end
    h{ii}.Normalization = 'probability';
end

for ii = 1:1:ndata
    h{ii}.BinWidth = binWidthMin;
end

for ii = 1:1:ndata
    centers{ii,1} = h{ii}.BinEdges(1:end-1) + 1/2 * h{ii}.BinWidth;
    p{ii,1} = h{ii}.Values;
end
close(gcf);

makeFigure;
% use color brewer.
color = brewermap(ndata, 'YlOrRd');
for ii = 1:1:ndata
    semilogy(centers{ii,1},p{ii,1},'lineWidth',1.5,'color',color(ii,:));
    hold on
end

% generate_legend_str
legend_str = cell(ndata, 1);
for ii = 1:1:ndata
    legend_str{ii} = num2str(FWHM_bank(ii));
end
legend(legend_str);
title(title_str)
xlabel('contrast');
ylabel('log probability');
figurePretty;
% plot only half of them. before using
if save_fig_flag
    MySaveFig_Juyue(gcf,'contrast','all_log_p','nFigSave',2,'fileType',{'png','fig'});
end
% makeFigure;
% for ii = 1:1:ndata
%     plot(centers{ii,1},p{ii,1},'lineWidth',1.5);
%     hold on
% end
% legend(legend_str);
% xlabel('contrast');
% ylabel('probability(frequency)');
% figurePretty;
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'contrast','all_p','nFigSave',2,'fileType',{'png','fig'});
% end
% makeFigure
% title_str = legend_str;
% for ii = 1:1:ndata
%     subplot(5,2,ii);
%     semilogy(centers{ii,1},p{ii,1},'lineWidth',1.5);
% 
%     title(title_str {ii});
%     xlabel('contrast');
%     ylabel('log probability');
%     figurePretty;
% end
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'contrast','ind_logp','nFigSave',2,'fileType',{'png','fig'});
% end
% makeFigure
% for ii = 1:1:ndata
%     subplot(5,2,ii);
%     plot(centers{ii,1},p{ii,1},'lineWidth',1.5);
%     title(title_str {ii});
%     xlabel('contrast');
%     ylabel('probability');
%     figurePretty;
% end
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'contrast','ind_p','nFigSave',2,'fileType',{'png','fig'});
% end
end