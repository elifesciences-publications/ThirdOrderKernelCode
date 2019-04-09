function roiAnalysis_PunctaSize(roiData)

nRoi = length(roiData);
roiSize = zeros(nRoi,1);
for rr = 1:1:nRoi
    roiSize(rr) = sum(roiData{rr}.stimInfo.roiMasks(:));
end

MakeFigure;
subplot(2,2,1)
h = histogram(roiSize);
h.BinWidth = 5;
% calculate the median, 25 percentile and 75 percentile.
A25 = prctile(roiSize,25)
A50 = prctile(roiSize,50)
A75 = prctile(roiSize,75)
titleStr = ['puncta area',' 25th:',num2str(A25),'  50th:',num2str(A50),'  75th:',num2str(A75)];
title(titleStr);

subplot(2,2,3)
[n,level] = hist(roiSize,100);
p = n/nRoi;
plot(cumsum(p));
xlabel('punta size by pixel');


% estimated diameter round
roiDiameter = sqrt(roiSize * 4/pi);
subplot(2,2,2)
h = histogram(roiDiameter);
h.BinWidth = 0.5;
D25 = prctile(roiDiameter ,25);
D50 = prctile(roiDiameter ,50);
D75 = prctile(roiDiameter ,75);
titleStr = ['puncta diameter',' 25th:',num2str(D25),'  50th:',num2str(D50),'  75th:',num2str(D75)];
title(titleStr);

subplot(2,2,4)
[n,level] = hist(roiDiameter,100);
p = n/nRoi;
plot(cumsum(p));
xlabel('punta diameter by pixel');
end