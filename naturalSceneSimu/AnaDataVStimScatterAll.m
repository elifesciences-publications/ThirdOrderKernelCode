function [stimMean,vValue] = AnaDataVStimScatterAll(stimMean,vValue,FWHM)
ncl = length(stimMean);
makeFigure;
for cc = 1:1:ncl
    meanstd = stimMean{cc}.std.mean;
    meanmax = stimMean{cc}.max.mean;
    maxmax = stimMean{cc}.max.max;
    
    subplot(1,3,1)
    %scatter(vValue,meanstd);
    plot(vValue,meanstd);
    title('mean of std of contrast');
    xlabel('velocity [degree/second]');
    ylabel('contrast');
    figurePretty;
    hold on
    
    subplot(1,3,2)
    %scatter(vValue,meanmax);
    plot(vValue,meanmax);
    title('mean of max contrast');
    xlabel('velocity [degree/second]');
    ylabel('contrast');
    figurePretty;
    hold on
    
    subplot(1,3,3)
    %scatter(vValue,maxmax);
    plot(vValue,maxmax);
    title('max of max contrast');
    xlabel('velocity [degree/second]');
    ylabel('contrast');
    figurePretty;
    hold on
    
end

end