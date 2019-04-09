function [linDisc] = BarPairLDAAnalysis(respMat, numRois, labels, numPhases, figName)

% LDA
numObs = size(respMat, 1);
totRois = sum(numRois);
labelsExp = cellfun(@(lab, num) repmat({lab}, num*numObs/totRois, 1), labels, num2cell(numRois), 'UniformOutput', false);
labelsExp = cat(1, labelsExp{:});
labelsNum = cellfun(@(lab) find(strcmp(labels, lab)), labelsExp);
Mdl = fitcdiscr(respMat,labelsExp);
[ldaLabel,score,cost] = predict(Mdl,respMat);
newLab = cellfun(@(lab) find(strcmp(labels, lab)), ldaLabel);
figHists = MakeFigure;
binWidth = (10^floor(log(640)/log(10)))/2;
subplot(2, 2, 1)
val = 1;
TP = 100*sum(newLab==val & labelsNum==val)/sum(labelsNum==val);
TN = 100*sum(newLab==labelsNum & labelsNum ~= val)/sum(labelsNum~=val);
FP = 100*sum(newLab==val & labelsNum~=val)/sum(labelsNum~=val);
FN = 100*sum(newLab==labelsNum & labelsNum == val)/sum(labelsNum==val);
histogram(find(newLab==val), 'BinWidth', binWidth);
title(sprintf('T4 Prog; TP: %0.2f%%; FP: %0.2f%%', TP, FP));

subplot(2, 2, 2)
val = 3;
histogram(find(newLab==val), 'BinWidth', binWidth);
TP = 100*sum(newLab==val & labelsNum==val)/sum(labelsNum==val);
TN = 100*sum(newLab==labelsNum & labelsNum ~= val)/sum(labelsNum~=val);
FP = 100*sum(newLab==val & labelsNum~=val)/sum(labelsNum~=val);
FN = 100*sum(newLab==labelsNum & labelsNum == val)/sum(labelsNum==val);
histogram(find(newLab==val), 'BinWidth', binWidth);
title(sprintf('T5 Prog; TP: %0.2f%%; FP: %0.2f%%', TP, FP));

subplot(2, 2, 3)
val = 2;
histogram(find(newLab==val), 'BinWidth', binWidth);
TP = 100*sum(newLab==val & labelsNum==val)/sum(labelsNum==val);
TN = 100*sum(newLab==labelsNum & labelsNum ~= val)/sum(labelsNum~=val);
FP = 100*sum(newLab==val & labelsNum~=val)/sum(labelsNum~=val);
FN = 100*sum(newLab==labelsNum & labelsNum == val)/sum(labelsNum==val);
histogram(find(newLab==val), 'BinWidth', binWidth);
title(sprintf('T4 Reg; TP: %0.2f%%; FP: %0.2f%%', TP, FP));

subplot(2, 2, 4)
val = 4;
histogram(find(newLab==val), 'BinWidth', binWidth);
TP = 100*sum(newLab==val & labelsNum==val)/sum(labelsNum==val);
TN = 100*sum(newLab==labelsNum & labelsNum ~= val)/sum(labelsNum~=val);
FP = 100*sum(newLab==val & labelsNum~=val)/sum(labelsNum~=val);
FN = 100*sum(newLab==labelsNum & labelsNum == val)/sum(labelsNum==val);
histogram(find(newLab==val), 'BinWidth', binWidth);
title(sprintf('T5 Reg; TP: %0.2f%%; FP: %0.2f%%', TP, FP));

figHists.Name = ['hists ' figName];

linDisc = Mdl.Mu';
linDiscProj = MakeFigure;
linDiscProjRot = MakeFigure;

subPs = {size(linDisc, 2),size(linDisc, 2)};
colors = 'rgbm';
cellTypeRoiBounds = [0 cumsum(numRois)] ;
for i = 1:size(linDisc, 2)^2
    [c, r] = ind2sub([subPs{:}], i);
    if c>r
        continue
    end
        
    figure(linDiscProj);
    subplot(subPs{:}, i);
    hold on
    if r == subPs{1}
        xlabel(sprintf('LD %d', c));
    end
    if c == 1
        ylabel(sprintf('LD %d', r));
    end
    p1 = respMat * linDisc(:, c);
    p2 = respMat * linDisc(:, r);
    for cellType = 1:length(numRois)
        cellTypeBound = cellTypeRoiBounds(cellType)+1:cellTypeRoiBounds(cellType+1);
        scatter(p1(cellTypeBound), p2(cellTypeBound), 5, colors(cellType));
    end
    
    figure(linDiscProjRot);
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

linDiscProj.Name = ['proj into linear disc ' figName];
linDiscProjRot.Name = ['proj rot into linear disc ' figName];

linDirs = MakeFigure;
subplot(2, 1, 2)
if length(Mdl.Mu)<numPhases*8
    spanLen = length(Mdl.Mu);
else
    spanLen = numPhases*8;
end
plot(Mdl.Mu(:, 1:spanLen)');hold on;
plot(repmat(4:numPhases:spanLen, 2, 1), repmat([0.5 1]', 1, spanLen/numPhases), 'k');
ConfAxis;
legend('T4 Prog-like', 'T4 Reg-like', 'T5 Prog-like', 'T5 Reg-like', 'Phase 4');
axis tight

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

linDirs.Name = ['linear discriminants ' figName];