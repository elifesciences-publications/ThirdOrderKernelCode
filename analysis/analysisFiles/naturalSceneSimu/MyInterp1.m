function y = MyInterp1(x0,y0,x)

dxPic = mean(abs(diff(x0)));
%dxPic = 0.3883; % degree.
% if the distance between two x is less than dxPic, then use interp1
% directly. other wise use the dxPic as the smallest interpolation point
% and calculate the avarage of the value in dx, as the interpolation value.

dxMax = max(abs(diff(x)));

% for dt = 5ms, the velocity have to be larger than 100 degree/s to use the
% averaging interpolation.
if dxMax < 1.3 * dxPic
    y = interp1(x0,y0,x,'linear');
else
    
    % insert some point into x....
    % the number of point should be larger than 1;
    % fisrt, turn x into column
    
    % calculate how many points needed to be insect in to x.
    nIncert = floor(dxMax/dxPic);
    n = nIncert + 1;
    
    % 
    x = reshape(x,[length(x),1]);
   
    dx = diff(x); % dx(1), dx(2),dx(3)... might have different values.
    dx = reshape(dx,[length(dx),1]);
    dx = [dx;0];
    dx = dx /(n+1);
    nMesh = 0:1:n;
    [dxMesh,nMesh] = ndgrid(dx,nMesh);
    xOffSet = dxMesh.*nMesh;
    
    xMesh = repmat(x,[1,n+1]);
    xMesh = xOffSet + xMesh;
    xMesh = xMesh';
    
    xEffect = xMesh(:);
    
    ySample = interp1(x0,y0,xEffect,'linear');
    
    ySampleMesh = reshape(ySample,n+1,[]);
    y = mean(ySampleMesh);
    
    y = reshape(y, [length(y),1]);
    % s = interp1(xlong,C,xi,'linear');
end
end