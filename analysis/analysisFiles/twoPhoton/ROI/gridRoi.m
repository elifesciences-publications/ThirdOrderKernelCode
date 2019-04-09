function ROI = gridRoi( Z )
% Creates one foreground ROI that is the difference between the direction
% selectivities of the left and right epochs

    loadFlexibleInputs 
    
    gridRatX = 5;
    gridRatY = 5;
    numGridX = ceil(imgSize(2)/gridRatX);
    numGridY = ceil(imgSize(1)/gridRatY);
    
    xGrid = [1:numGridX]; 
    yGrid = [0:numGridY-1]*numGridX;
    ROI.xMeshLocs = xGrid;
    ROI.yMeshLocs = yGrid;
    
    xGrid = repmat(xGrid,[gridRatX 1]);
    xGrid = reshape(xGrid,[numGridX*gridRatX, 1]);
    xGrid = xGrid(1:imgSize(2));
    
    yGrid = repmat(yGrid,[gridRatY 1]);
    yGrid = reshape(yGrid,[numGridY*gridRatY, 1]);
    yGrid = yGrid(1:imgSize(1));
    [xMesh yMesh] = meshgrid(xGrid,yGrid);
    seg = xMesh + yMesh;
    
    for q = 1:max(seg);
        ROI.roiMasks(:,:,q) = double(seg == q);
    end
    
    ROI.xMesh = xMesh;
    ROI.yMesh = yMesh;

end

