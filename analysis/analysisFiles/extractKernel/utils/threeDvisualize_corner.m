function [ output_args ] = threeDvisualize_corner( kernel,zThresh,theTitle,subplotInd)
% View integrals of diagonals is if from a corner

zScale = 1;
if nargin < 2
    zScale = 0;
end

if nargin < 3
    theTitle = '';
end

isSubplot = 1;
if nargin < 4
    isSubplot = 0;
end

maxTau = length(kernel);

seqInd =  0;
for i = 1:maxTau
    for j = 1:i
        for k = 1
            seqInd = seqInd + 1;
            initialPoints(seqInd,:) = [i j k];            
        end
    end
end

for i = 1:maxTau 
    for j = 1
        for k = 1:maxTau
            seqInd = seqInd + 1;
            initialPoints(seqInd,:) = [i j k];
        end
    end
end

numPoints = size(initialPoints,1);

for qq = 1:numPoints
    
    stepBack = [ 1 1 1 ];
    numSteps = 0;
    
    x1 = initialPoints(qq,1);
    x2 = initialPoints(qq,2);
    y = initialPoints(qq,3);
    loc = [x1 x2 y];
    
    while all(loc + numSteps * stepBack <= maxTau)
        diag{qq}(numSteps+1,:) = loc + numSteps * stepBack;
        numSteps = numSteps + 1;
    end
    
end

int = zeros(numPoints,maxTau);
for qq = 1:numPoints
    for rr = 1:size(diag{qq},1)
        x1 = diag{qq}(rr,1);
        x2 = diag{qq}(rr,2);
        y = diag{qq}(rr,3);
        int(qq,rr) = kernel(x1,x2,y);
    end
end

for qq = 1:numPoints
    intSum(qq) = sum(int(qq,:)) / size(diag{qq},1);
end

if zScale
    std_dev = std(intSum);
    intSum = intSum / std_dev;
    intSum = intSum .* ( abs(intSum) > zThresh );
end

gridView = zeros(maxTau*4-1,maxTau);
gridViewMask = zeros(maxTau*4-1,maxTau);
backDrop = ones(maxTau*4-1,maxTau);

ei = [ 1 1 ];
ej = [ 1 -1 ];
ek = [ -2 0 ];
startPoint = [ 2*maxTau , 1 ];

for qq = 1:numPoints
    x1 = initialPoints(qq,1);
    x2 = initialPoints(qq,2);
    y = initialPoints(qq,3);
    shiftLoc = startPoint + x1 * ei + x2 * ej + y * ek;
    gridView(shiftLoc(1),shiftLoc(2)) = intSum(qq);
    gridViewMask(shiftLoc(1),shiftLoc(2)) = 1;
    backDrop(shiftLoc(1),shiftLoc(2)) = 0;
end

meanGridView = mean(gridView(:));
% gridView_ms = gridView - meanGridView;
gridView_ms = gridView; % don't mean subtract! Want 0 to be 0.
maxDev = max([ abs(min(gridView_ms(:))), abs(max(gridView_ms(:))) ]);
gridView_ms = [ fliplr(gridView_ms(:,2:end)) gridView_ms(:,1:end) ];
gridViewMask = [ fliplr(gridViewMask(:,2:end)) gridViewMask(:,1:end) ];
backDrop = [ fliplr(backDrop(:,2:end)) backDrop(:,1:end) ];

% gridView_ms = [ fliplr(gridView_ms(:,2:end)) gridView_ms(:,1:end) ];
% figure; imagesc(gridView); colormap_gen; colormap(mymap); set(gca,'CLim',[ -maxDev maxDev ]);

backDrop = backDrop * .95;
bChannel = (1 - (abs(gridView_ms) .* (gridView_ms > 0))/maxDev) .* gridViewMask + ... 
    backDrop;
rChannel = (1 - (abs(gridView_ms) .* (gridView_ms < 0))/maxDev) .* gridViewMask + ... 
    backDrop;
gChannel = (1 - (abs(gridView_ms))/maxDev) .* gridViewMask + ...
    backDrop;
bitMapOut = cat(3,rChannel,gChannel,bChannel);
bitMapOut(2*maxTau,maxTau,:) = 0;

if isSubplot
    subplot(subplotInd(1),subplotInd(2),subplotInd(3));
else
    figure;
end

image(bitMapOut); title(theTitle);

end

