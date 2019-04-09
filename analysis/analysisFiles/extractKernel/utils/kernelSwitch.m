function [ filterOut ] = kernelSwitch( x, y, resp, maxTau, order, inVar )
% Quickly switch between different kernel extraction methods: the two mex
% files and oneD_filter. 

    if nargin < 6
        inVar = 1;
    end

    switch order
        case 1
            filterOut = oneD_filter(x,resp,maxTau);
        case 2
            filterOut = twod_fast(maxTau,inVar,x,y,resp);           
        case 3
            filterOut = threed_fast(maxTau,inVar,x,x,y,resp); 
    end

end

