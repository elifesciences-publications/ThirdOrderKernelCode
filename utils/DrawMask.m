function bitMap = DrawMask(radiusFactor)
    sizeX = 100;
    sizeY = sizeX;
    
    
    [x,y] = meshgrid(1:sizeX,1:sizeY);
    center = [sizeX/2 sizeY/2];
    pixRadius = sqrt(((x-center(1))).^2 + ((y-center(2))/2).^2);
    
    bitMap = zeros(sizeX,sizeY,4);
    alpha = 255*(pixRadius > (radiusFactor*sizeX));
    bitMap(:,:,4) = alpha;
end