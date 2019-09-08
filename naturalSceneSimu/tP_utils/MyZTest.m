function [h,p,ci] = MyZTest(x,m,s,alpha)
%MyTTtest modified to calculate the matrix/Vec h,p,ci,tval in a tight
%format. x, m, std,n,are in the same demension.
% x, value,
% m,mean, meanvalue, 
% s, standard distribution.
% n, sampling size

%TTEST  One-sample and paired-sample t-test.
%   H = TTEST(X) performs a t-test of the hypothesis that the data in the
%   vector X come from a distribution with mean zero, and returns the
%   result of the test in H.  H=0 indicates that the null hypothesis
%   ("mean is zero") cannot be rejected at the 5% significance level.  H=1
%   indicates that the null hypothesis can be rejected at the 5% level.
%   The data are assumed to come from a normal distribution with unknown
%   variance.
%
%   X can also be a matrix or an N-D array.   For matrices, TTEST performs
%   separate t-tests along each column of X, and returns a vector of
%   results.  For N-D arrays, TTEST works along the first non-singleton
%   dimension of X.
%
%   TTEST treats NaNs as missing values, and ignores them.
%
%   H = TTEST(X,M) performs a t-test of the hypothesis that the data in
%   X come from a distribution with mean M.  M must be a scalar.
%
%   H = TTEST(X,Y) performs a paired t-test of the hypothesis that two
%   matched samples, in the vectors X and Y, come from distributions with
%   equal means. The difference X-Y is assumed to come from a normal
%   distribution with unknown variance.  X and Y must have the same length.
%   X and Y can also be matrices or N-D arrays of the same size.
%
%   [H,P] = TTEST(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,CI] = TTEST(...) returns a 100*(1-ALPHA)% confidence interval for
%   the true mean of X, or of X-Y for a paired test.
%
%   [H,P,CI,STATS] = TTEST(...) returns a structure with the following fields:
%      'tstat' -- the value of the test statistic
%      'df'    -- the degrees of freedom of the test
%      'sd'    -- the estimated population standard deviation.  For a
%                 paired test, this is the std. dev. of X-Y.
%
%   [...] = TTEST(X,Y,'PARAM1',val1,'PARAM2',val2,...) specifies one or
%   more of the following name/value pairs:
%
%       Parameter       Value
%       'alpha'         A value ALPHA between 0 and 1 specifying the
%                       significance level as (100*ALPHA)%. Default is
%                       0.05 for 5% significance.
%       'dim'           Dimension DIM to work along. For example, specifying
%                       'dim' as 1 tests the column means. Default is the
%                       first non-singleton dimension.
%       'tail'          A string specifying the alternative hypothesis:
%           'both'  -- "mean is not M" (two-tailed test)
%           'right' -- "mean is greater than M" (right-tailed test)
%           'left'  -- "mean is less than M" (left-tailed test)
%
%   See also TTEST2, ZTEST, SIGNTEST, SIGNRANK, VARTEST.

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, page 206.

%   Copyright 1993-2012 The MathWorks, Inc.




% Process remaining arguments
tail = 0;    % code for two-sided
% 
% ser = s./ sqrt(n);
% tval = (x - m) ./ ser;
zval = (x - m)./s;

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
     p = 2 * normcdf(-abs(zval),0,1);
%         crit = tinv((1 - alpha / 2), df) .* ser;
% % last dimension of everything,depends on the input and output;
%         ci = cat(dim,m - crit, m + crit);
% elseif tail == 1 % right one-tailed test
%     p = tcdf(-tval, df);
%     if nargout > 2
%         crit = tinv(1 - alpha, df) .* ser;
%         ci = cat(dim, xmean - crit, Inf(size(p)));
%     end
% elseif tail == -1 % left one-tailed test
%     p = tcdf(tval, df);
%     if nargout > 2
%         crit = tinv(1 - alpha, df) .* ser;
%         ci = cat(dim, -Inf(size(p)), xmean + crit);
%     end
end
% 
% MakeFigure;
% subplot(2,2,1);histogram(x);
% subplot(2,2,2);histogram(m);
% subplot(2,2,3);histogram(s);
% subplot(2,2,4);histogram(p(p<alpha));

% Determine if the actual significance exceeds the desired significance
h = cast(p <= alpha, class(p));