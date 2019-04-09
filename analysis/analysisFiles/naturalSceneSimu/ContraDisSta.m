function desI = ContraDisSta(I)
% calculate the descriptive statistics of the image;
% skewness : negative -> more value at the left of the mean. positive ->
% more value at the right of the mean.

% kurtosis: larger than three : outlier prone/sparse. smaller than three :
% less outlier prone, uniform. 
% 
% makeFigure;
% hist(I(:),100);

maxI = max(I(:));
minI = min(I(:));
stdI = std(I(:));
meanI = mean(I(:));
skewI = skewness(I(:),0);
kurtI = kurtosis(I(:));

desI.max = maxI;
desI.min = minI;
desI.std = stdI;
desI.mean = meanI;
desI.skew = skewI;
desI.kurt = kurtI;

end