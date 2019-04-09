function fit = LN_FitToSoftRectification(predResp,resp)
% x = [A,B,r0,r1]
myFunc = @(x) sum((resp - (x(1) + x(2) * log(1 + exp((predResp - x(3))/x(4))))).^2);

searchIniti = [-0.2,1,0,0.2];
[xOut] = fminsearch(myFunc,searchIniti);
fit.A = xOut(1);
fit.B = xOut(2);
fit.r0 = xOut(3);
fit.r1 = xOut(4);

% MakeFigure;
% a = -1:0.01:1;
% y = fit.A + fit.B * log(1 + exp((a - fit.r0)/fit.r1));
% plot(a,y)
end