function [ A,B,sA,sB ] =weighted_best_fit( x,y,sY )
% Taylor "An Introduction to Error Analysis," pg. 198

    w = 1./(sY.^2);
    delta = sum(w)*(w'*x.^2) - (w'*x)^2;
    A = ((w'*x.^2)*(w'*y) - (w'*x)*(w'*(x.*y))) / delta;
    B = (sum(w)*(w'*(x.*y) - (w'*x)*(w'*y))) / delta;
    sA = sqrt(w'*x.^2/delta);
    sB = sqrt(sum(w)/delta);

end

