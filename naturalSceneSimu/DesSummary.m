function indOut = DesSummary(desInfo,mode,plotFlag,a)
% if plotFlag == 1, plot the histogram and scatter plot.
nImage = max(size(desInfo));
maxI = zeros(nImage,1);
stdI = zeros(nImage,1);
skewI = zeros(nImage,1);
kurtI = zeros(nImage,1);

for i = 1:1:nImage
    switch mode
        case 1
            maxI(i) = desInfo{i}.g.max;
            stdI(i) = desInfo{i}.g.std;
            skewI(i) = desInfo{i}.g.skew;
            kurtI(i) = desInfo{i}.g.kurt;
        case 2
            maxI(i) = desInfo{i}.r.max;
            stdI(i) = desInfo{i}.r.std;
            skewI(i) = desInfo{i}.r.skew;
            kurtI(i) = desInfo{i}.r.kurt;
        case 3
    end
end
% 
% % plot the max distribution;
% if plotFlag
%     makeFigure;
%     subplot(2,2,1)
%     hist(maxI,30);
%     title('distribution of the max contrast');
%     figurePretty;
%     
%     subplot(2,2,2)
%     hist(stdI,30);
%     title('distribution of the standard deviation');
%     figurePretty;
%     
%     subplot(2,2,3)
%     hist(skewI,30);
%     title('distribution of the skewness');
%     figurePretty;
%     
%     subplot(2,2,4)
%     hist(kurtI,30);
%     title('distribution of the kurtosis');
%     figurePretty;
%     
%     xData = 1:1:nImage;
%     makeFigure;
%     subplot(2,2,1)
%     scatter(xData,maxI,'r.');
%     title('distribution of the max contrast');
%     figurePretty;
%     
%     subplot(2,2,2)
%     scatter(xData,stdI,'r.')
%     title('distribution of the standard deviation');
%     figurePretty;
%     
%     subplot(2,2,3)
%     scatter(xData,skewI,'r.');
%     title('distribution of the skewness');
%     figurePretty;
%     
%     subplot(2,2,4)
%     scatter(xData,kurtI,'r.');
%     title('distribution of the kurtosis');
%     figurePretty;
% end
% define outliers
% use maximun value and std. in order to eliminate some extreme values.
% exclude the constrast value that are too big...
indOut = FindOutlier(maxI,a);

%% plot the distribution with/without the outlier. for the contrast distributino and the standard deviation.
if plotFlag
    makeFigure;
    % before the outlier was removed.
    subplot(2,2,1)
    hist(maxI,30);
    title('before: distribution of the max contrast');
    figurePretty;
    
    subplot(2,2,2)
    hist(stdI,30);
    title('before: distribution of the standard deviation');
    figurePretty;
    
    indPlot = ones(1,nImage);
    indPlot(indOut) = 0;
    indPlot = indPlot > 0.5;
    
    subplot(2,2,3)
    hist(maxI(indPlot),30);
    title('after: distribution of the max contrast');
    figurePretty;
    
    subplot(2,2,4)
    hist(stdI(indPlot),30);
    title('after: distribution of the standard deviation');
    figurePretty;

end
end