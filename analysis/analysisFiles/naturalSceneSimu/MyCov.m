function xyCov = MyCov()
xSum = 0;
ySum = 0;
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
    xySqSum = xySqSum + sum(x.*y);
    n = n + length(x);
    
end

xyCov = 1/(n-1)*(xySqSum - 1/n * xSum * ySum);