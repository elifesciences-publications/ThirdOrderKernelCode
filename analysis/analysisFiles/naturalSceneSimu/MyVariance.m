% this script helps to calculate the variance and covariance for large
% vectors and 
function xVar = MyVariance()
% complex path way could be sent into...
% might be large vector, might be large matrix.
% think it as a lot of vector, stores in different files.

xSum = 0;
xSqSum =0;
n = 0;

load('testingdata');

for i = 1:1:10
    % this part should be changed into more proper form.
    filename = ['testingData',num2str(i),'.mat'];
    load(filename);
    x = c;
    
    x = reshape(x,[length(x),1]);
    xSum = xSum + sum(x);
    xSqSum = xSqSum + x'*x;
    n = n + length(x);
    
end
xVar = 1/(n-1) * (xSqSum - 1/n * xSum^2);