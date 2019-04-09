function FigPlot1_RoiOnMean(Z,roiSelected,color)


roiMasks = Z.ROI.roiMasks(:,:,1:end - 1);
roiCenterOfMass = Z.ROI.roiCenterOfMass(1:end-1,:);
movieMean = Z.rawTraces.movieMean;
windowMask = Z.grab.windowMask;
nRoi = size(roiMasks,3);

verInd = find(sum(windowMask,2) > 0);
horInd = find(sum(windowMask,1) > 0);
roiImage = movieMean(verInd(1):verInd(end),horInd(1):horInd(end));
roiMasksChop = zeros(length(verInd),length(horInd),nRoi);
for rr = 1:1:nRoi
    roiMasksChop(:,:,rr) = roiMasks(verInd(1):verInd(end),horInd(1):horInd(end),rr);
end
roiMasks = roiMasksChop;

MakeFigure
colormap(gray(256));
imagesc(roiImage);
axis off
hold on
roiUse = find(roiSelected);
nRoiUse = length(roiUse);
for ii = 1:1:nRoiUse
    rr = roiUse(ii);
    roiBoundaries = bwboundaries(roiMasks(:,:,rr),8,'noholes');
   
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',5,'color',color);
end
hold off
ConfAxis;

end