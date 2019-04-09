function XYPos = scatterBar(Ys)
    if iscell(Ys)
        %Cell stuff here
    else
        [numPoints, numBars] = size(Ys);
        XYPos = zeros(numPoints,2,numBars);
        for ii = 1:numBars
            XYPos(:,:,ii) = bsxfun(@plus,scatterPoints(Ys(:,ii),range(Ys(:))),[ii,0]);
        end
    end
end

function XYPos = scatterPoints(Ys,plotRange)

    numPoints = length(Ys);
    XYPos = [zeros(numPoints,1),sort(Ys)];

    XYPos(:,1) = XYPos(:,1) + 1*randn(numPoints,1);
    for jj = 1:2
        kickMagnitude = 0.4.^jj;
        XYPos(:,1) = XYPos(:,1) + 0*kickMagnitude*randn(numPoints,1);
        scramblePick = randperm(numPoints,floor(numPoints/2));
        otherPick = find(~ismember(1:numPoints,scramblePick));
        if length(otherPick) > length(scramblePick)
            otherPick = otherPick(1:end-1);
        end
        temp = XYPos(scramblePick,1);
        XYPos(scramblePick,1) = XYPos(otherPick,1);
        XYPos(otherPick,1) = temp;
        for ii = 1:20
            forces = generateEnergies(XYPos,plotRange);
            XYPos(:,1) = XYPos(:,1) + kickMagnitude*(0.95.^ii)*(4*tanh(forces/4)+0*randn(length(XYPos),1));
        end
    end
    XYPos(:,1) = 6*XYPos(:,1);
end

function xForces = generateEnergies(XYPos,plotRange)
    numPoints = size(XYPos,1);
    centeringTerm = -XYPos(:,1);
    interactionTerm = zeros(numPoints,1);
    yModifier = 10/plotRange;
    for ii = 1:numPoints
%         testStart = max(1,ii-5);
%         testEnd = min(numPoints,ii+5);
        pairwiseVectors = bsxfun(@minus,XYPos(ii,:),XYPos(:,:));
        pairwiseVectors(:,2) = pairwiseVectors(:,2)*yModifier;
        pairwiseDistancesSquared = sum(pairwiseVectors.^2,2); 
%         xDirModifier = pairwiseVectors(:,1)./sqrt(pairwiseDistancesSquared);
%         xTermContributions = xDirModifier./(pairwiseDistancesSquared.^2);
%         xTermContributions(ii) = 0;
%         xTermContributions = tanh(xTermContributions);
%         interactionTerm(ii) = tanh(sum(xTermContributions));

%         collided = pairwiseDistancesSquared < 0.1;
%         pushDirection = tanh(sum(sign(pairwiseVectors(collided,1))));

        pushDirection = nansum(tanh(sign(pairwiseVectors(:,1))./(1000*pairwiseDistancesSquared)));
        interactionTerm(ii) = pushDirection;
    end
    xForces = 1.5*centeringTerm + 0.1*interactionTerm;
end