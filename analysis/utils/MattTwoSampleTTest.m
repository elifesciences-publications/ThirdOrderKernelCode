function p = MattTwoSampleTTest(meanx,stdx,nx,meany,stdy,ny)
    %% this code grabbed from ttest2
    % http://www.mathworks.com/help/stats/ttest2.html?refresh=true
    
    difference = meanx-meany;
    
    s2x = stdx^2;
    s2y = stdy^2;
    
    s2xbar = s2x ./ nx;
    s2ybar = s2y ./ ny;
    dfe = (s2xbar + s2ybar) .^2 ./ (s2xbar.^2 ./ (nx-1) + s2ybar.^2 ./ (ny-1));
    se = sqrt(s2xbar + s2ybar);
    ratio = difference ./ se;
    
    p = 2 * tcdf(-abs(ratio),dfe);
end