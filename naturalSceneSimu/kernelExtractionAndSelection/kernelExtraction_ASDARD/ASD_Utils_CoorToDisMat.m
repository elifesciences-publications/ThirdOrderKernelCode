function  disMat = ASD_Utils_CoorToDisMat(x)
    % use meshgrid.
    [XA,XB] = meshgrid(x,x);
    disMat = sqrt((XA - XB).^2); % distance get!
    
end