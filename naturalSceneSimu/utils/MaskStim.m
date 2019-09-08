grabGridUnit

if f == 1 && leftEye
    stimData.gridMem = [floor(size(gridUnit,1)*rand) floor(size(gridUnit,2)*rand)]';
%     stimData.gridMemR = [floor(size(gridUnit,1)*rand) floor(size(gridUnit,2)*rand)]';
    
    if p.gridType == 18 || p.gridType == 22
        stimData.gridMem = [0 0]';
%         stimData.gridMemR = [0 0]';
    end
end

% tile the gridUnit over the entire size of the stimulus, go over the edges
% to make sure you cover the whole thing
gridMatL = repmat(gridUnit,[ceil(sizeY/size(gridUnit,1)) ceil(sizeX/size(gridUnit,2)) framesPerUp]);

% crop the grid mat to the size of the bitmap
gridMatL = gridMatL(1:sizeY,1:sizeX,:);
% gridMatL = gridMatL(1:end-mod(size(gridUnit,1)-mod(sizeY,size(gridUnit,1)),size(gridUnit,1)),:,:);
% gridMatL = gridMatL(:,1:end-mod(size(gridUnit,2)-mod(sizeX,size(gridUnit,2)),size(gridUnit,2)),:);

% tile the gridUnit over the entire size of the stimulus, go over the edges
% to make sure you cover the whole thing
if p.twoEyes
    gridMatR = repmat(gridUnit(:,end:-1:1),[ceil(sizeY/size(gridUnit,1)) ceil(sizeX/size(gridUnit,2)) framesPerUp]);

    % crop to the size of the bitmap
    gridMatR = gridMatR((end-sizeY+1):end,(end-sizeX+1):end,:);
end

if leftEye
    bitMap = bitMap.*gridMatL;
    bitMap = circshift(bitMap,stimData.gridMem);
else
    rightEye = rightEye.*gridMatR;
    rightEye = circshift(rightEye,-stimData.gridMem);
end