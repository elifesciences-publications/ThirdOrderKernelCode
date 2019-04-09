function [f_x,coe] = MyFitPoly2(x,y)
% x is the predicted response, and y is the response. they are used to
% extract nonlinear function
f = fit(x,y,'poly2');


a2 = f.p1;
a1 = f.p2;
a0 = f.p3;

% indX = x < rangeX(2) & x > rangeX(1);
% indY = y < rangeY(2) & y > rangeY(1);
% ind  = indX;
%
% x_ = x_(ind);
% y_ = y_(ind)

f_x = a0*ones(size(x)) + a1.*x + a2.*x.^2;
% f_x2 = a2.*x_.^2;
% f_x1 = a1.*x_;
% rLFirst = corr(f_x,y_);
% rFirst = corr(x_,y_);
coe = [a2,a1,a0];

% MakeFigure;
% subplot(221)
% scatter(x,y,'b.');
% hold on
% scatter(x,f_x,'r.');
% xlabel('predicted response');
% ylabel('response');
% legend('pred-resp','pred-g(pred)');
% subplot(222)
% scatter(f_x,y,'r.')
end