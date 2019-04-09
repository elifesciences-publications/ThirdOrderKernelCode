function [rERev, pcVar] = BarPairPCAAnalysis(covarMat, respMat, numRois, numPhases, figName)

[u, s, v] = svd(covarMat);
[rE, D, lE] = eig(covarMat);

respMat = bsxfun(@minus, respMat, mean(respMat, 2));

pcVar = cumsum(diag(s))./sum(diag(s));
pcVarFig = MakeFigure;plot(pcVar);xlabel('Principal Component');ylabel('Variance');
rERev = rE(:, end:-1:1);
numPCs = 7;
eigsInt = rERev(:, 1:numPCs);
pcVarFig.Name = ['princComps ' figName];

pcas = MakeFigure;
rotCoord = MakeFigure;
subPs = {size(eigsInt, 2),size(eigsInt, 2)};
colors = 'rgbm';
cellTypeRoiBounds = [0 cumsum(numRois)] ;
for i = 1:size(eigsInt, 2)^2
    [c, r] = ind2sub([subPs{:}], i);
    if c>r
        continue
    end
        
    figure(pcas);
    subplot(subPs{:}, i);
    hold on
    if r == subPs{1}
        xlabel(sprintf('PC %d', c));
    end
    if c == 1
        ylabel(sprintf('PC %d', r));
    end
    p1 = respMat * eigsInt(:, c);
    p2 = respMat * eigsInt(:, r);
    for cellType = 1:length(numRois)
        cellTypeBound = cellTypeRoiBounds(cellType)+1:cellTypeRoiBounds(cellType+1);
        scatter(p1(cellTypeBound), p2(cellTypeBound), 5, colors(cellType));
    end
    
    figure(rotCoord);
    subplot(subPs{:}, i);
    hold on
    if r == subPs{1}
        xlabel(sprintf('\theta PC %d - PC%d', c, r));
    end
    if c == 1
        ylabel(sprintf('r PC %d - PC%d', r, c));
    end
    angles = atan2(p2, p1);
    radii = sqrt(p2.^2 + p1.^2);
    for cellType = 1:length(numRois)
        cellTypeBound = cellTypeRoiBounds(cellType)+1:cellTypeRoiBounds(cellType+1);
        scatter(angles(cellTypeBound), radii(cellTypeBound), 5, colors(cellType));
    end
    
end

pcas.Name = ['pca proj ', figName];
rotCoord.Name = ['pca proj rot ', figName];

% From looking at the plots, PC1 & PC2 separate out T4 from T5 and PC2 &
% PC3 separate out regressive from progressive. I'm plotting the projection
% of the points into this 3-space
pc3dProj = MakeFigure;
if any(strfind(figName, 'allData'))
    pcInt = [1 2 5]; % For all data
elseif any(strfind(figName, 'appMotOnly'))
    pcInt = [1 2 4]; % For just app motion
elseif any(strfind(figName, 'posCorrOnly'))
    pcInt = [1 2 7]; % For just app motion positive phi
elseif any(strfind(figName, 'negCorrOnly'))
    pcInt = [1 2 3]; % For just app motion negative phi
end
cube1 = respMat*eigsInt(:, pcInt(1));
cube2 = respMat*eigsInt(:, pcInt(2));
cube3 = respMat*eigsInt(:, pcInt(3));
for cellType = 1:length(numRois)
    cellTypeBound = cellTypeRoiBounds(cellType)+1:cellTypeRoiBounds(cellType+1);
    scatter3(cube1(cellTypeBound), cube2(cellTypeBound), cube3(cellTypeBound), 35, colors(cellType), 'filled');
    hold on
end
axis square;
xlabel(sprintf('PC%d', pcInt(1)));
ylabel(sprintf('PC%d', pcInt(2)));
zlabel(sprintf('PC%d', pcInt(3)));
pc3dProj.Name = ['by eye 3 PC proj ' figName];

pcVect = MakeFigure;
subplot(2, 1, 2);
if size(eigsInt, 1)< numPhases*8
    spanLen = size(eigsInt, 1);
else
    spanLen = numPhases*8;
end
plot([eigsInt(1:spanLen, pcInt(1)) eigsInt(1:spanLen, pcInt(2)) eigsInt(1:spanLen, pcInt(3))])
legend(sprintf('PC%d', pcInt(1)), sprintf('PC%d', pcInt(2)), sprintf('PC%d', pcInt(3)));
axis tight
ConfAxis
pcVect.Name = ['by eye 3 PCs ' figName];

ind = 1;
secondBarDelay = 0.15;
barsOff = 1;
barToCenter = 2;
barColors = [1 1 1; 0 0 0];
barColorOrderOne = [1 2 1 2];
barColorOrderTwo = [1 2 2 1];
for i = 1:4
    barsPlot = subplot(2, 8, i*2-1); cla
    
    progMot = true;
    BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
    
    barsPlot = subplot(2, 8, i*2); cla
    
    progMot = false;
    BarPairPlotSideBySideBarsXT(barsPlot, barsOff, secondBarDelay, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot)
    ind = ind+1;
    
end

% Check variance explained by 4th phase
expVar = zeros(1, numPhases);
for phaseStart = 1:numPhases
    phase4Inds = phaseStart:numPhases:size(covarMat, 1);
    phase4 = zeros(1, size(covarMat, 1));
    phase4(phase4Inds) = 1;
    phase4 = phase4/sum(phase4);
    varAssocPhase4 = phase4*covarMat*phase4';
    expVar(phaseStart) = varAssocPhase4/trace(covarMat);
end
expVarPerPhase = MakeFigure;
plot(expVar);
xlabel('Phase')
ylabel('Variance Explained');
expVarPerPhase.Name = ['var exp per phase ' figName];