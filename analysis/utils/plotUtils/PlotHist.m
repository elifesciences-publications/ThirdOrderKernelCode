function plotTitle = PlotHist(data,nameData,varargin)
    %set defaults for variables that can later be modified by varargin.
    %modfy with the input plotHist(...,'nameVar','valueToSet')
    bins = 21;
    fit = [];
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    hist(data,bins);
    if ~isempty(fit)
        try
            if isscalar(bins)
                [~,stat] = histfit(data,bins,fit);
            else
                [~,stat] = histfit(data,length(bins),fit);
            end
        catch err
            disp(['error "' err.message '" when fitting ' nameData ' so no fit']);
            fit = 'nofit';
        end
    end
    
    legend(sprintf(['mean=' num2str(mean(data)) '\nmedian=' num2str(median(data)) '\nstd=' num2str(std(data)) '\nNumData=' num2str(size(data(:),1))]));
    
    if strcmp(fit,'lognormal');
        legend(sprintf(['mean=' num2str(mean(data)) '\nmedian=' num2str(median(data)) '\nstd=' num2str(std(data)) '\nLognorm Fit mu=' num2str(stat.mu) ' sig=' num2str(stat.sigma) '\nNumData=' num2str(size(data(:),1))]));
    end
    
    plotTitle = [nameData ' Distribution'];
    title(plotTitle,'FontSize',16);
    xlabel(nameData,'FontSize',16);
    ylabel('# of Counts','FontSize',16);
end