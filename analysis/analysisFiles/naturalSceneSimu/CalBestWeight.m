function [weight,r] = CalBestWeight(x,y)
% the key point is to construct correct functino form.

weight = (y'/x')';
yhat = (weight'*x')';
r = corr(yhat,y);

end
