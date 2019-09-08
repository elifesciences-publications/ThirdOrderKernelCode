function [xyCorr,xyCov,xVar,yVar] = MyCorr()
xSum = 0;
ySum = 0;
xSqSum = 0;
ySqSum = 0;
xySqSum = 0;
n = 0;

load('testingdata');

for i = 1:1:10
    % this part should be changed into more proper form.
    filename = ['testingData',num2str(i),'.mat'];
    load(filename);
    x = c;
    y = d;
    
    xSum = xSum + sum(x);    
    ySum = ySum + sum(y);
    xSqSum = xSqSum + sum(x.^2);
    ySqSum = ySqSum + sum(y.^2);
    xySqSum = xySqSum + sum(x.*y);
    n = n + length(x);
    
end

xVar = 1/(n-1) * (xSqSum - 1/n * xSum^2);
yVar = 1/(n-1) * (ySqSum - 1/n * ySum^2);
xyCov = 1/(n-1)*(xySqSum - 1/n * xSum * ySum);
xyCorr = xyCov/(sqrt(xVar)*sqrt(yVar));
