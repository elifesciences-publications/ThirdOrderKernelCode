function y = MyEqu(X,timeMat)
    % X will be a vector, timeMat will be a matrix.
   
    [rowX,colX] = ndgrid(X,X);
    XTriu  = triu(colX - rowX);
    timeMatTriu = triu(timeMat);
    y = sum(sum((XTriu - timeMatTriu).^2));

end