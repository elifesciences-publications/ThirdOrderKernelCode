function BarPairICAAnalysis(respMat, numRois)

[ica_sig, icaFiltsOut, ica_A, icSkew, numiter] = IcaGeneralized(permute(respMat, [2 3 1]), false);

filtsPlot = 10;
icaFilts = icaFiltsOut(1:filtsPlot, :)';

icas = MakeFigure;
rotCoord = MakeFigure;
subPs = {size(icaFilts, 2),size(icaFilts, 2)};
colors = 'rgbm';
cellTypeRoiBounds = [0 cumsum(numRois)] ;
for i = 1:size(icaFilts, 2)^2
    [c, r] = ind2sub([subPs{:}], i);
    if c>r
        continue
    end
        
    figure(icas);
    subplot(subPs{:}, i);
    hold on
    if r == subPs{1}
        xlabel(sprintf('PC %d', c));
    end
    if c == 1
        ylabel(sprintf('PC %d', r));
    end
    p1 = respMat * icaFilts(:, c);
    p2 = respMat * icaFilts(:, r);
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