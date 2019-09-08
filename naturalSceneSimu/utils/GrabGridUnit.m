switch p.gridType
    case 0
        gridUnit = ones(sizeY,sizeX);
    case 1
        gridUnit = [1 0 0];
    case 2
        gridUnit = [1 1 0 0];
    case 3
        gridUnit = [1 1 1 0 0];
    case 4
        gridUnit = [1 0 1 0 0];
    case 5
        gridUnit = [1 0];
    case 6
        gridUnit = [1 0 0];
    case 7
        gridUnit = [1 0 0 0];
    case 8
        gridUnit = [1 0 0 0 0];
    case 9
        gridUnit = [1 1 0 0 0];
    case 10
        gridUnit = [1 1 1 0 0 0];
    case 11
        gridUnit = [1 1 1 1 0 0 0 0];
    case 12
        gridUnit = [1 1 1 0 0 0 0 0];
    case 13
        gridUnit = [1 1 0 0 0 0 0 0];
    case 14
        gridUnit = [1 0 0 1 0 0 0];
    case 15
        gridUnit = [1 0 1 0 0 0];
    case 16
        gridUnit = [1 1 1 1 1];
    case 17
        gridUnit = [1 1 1 0 0 0 0];
    case 18
        gridUnit = [zeros(1,floor(sizeX/2+p.numOffset-p.maskSize/2)) ones(1,p.maskSize) zeros(1,ceil(sizeX/2-p.numOffset-p.maskSize/2))];
    case 19
        gridUnit = [1 1 0 0 0 0];
    case 20
        gridUnit = [ones(1,5) zeros(1,15)];
    case 21
        gridUnit = [ones(1,20) zeros(1,20)];
    case 22
        gridUnit = [zeros(floor(sizeY/2+p.numOffset-p.maskSize/2),1); ones(p.maskSize,1); zeros(ceil(sizeY/2-p.numOffset-p.maskSize/2),1)];
end