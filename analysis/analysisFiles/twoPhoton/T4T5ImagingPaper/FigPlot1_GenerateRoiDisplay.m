function [roiDisplayImage,alph] = FigPlot1_GenerateRoiDisplay(roiMasks,roiImage,roiEdgeType,typeColorRGB,roiESI,roiDSI)

nRoi = size(roiMasks,3); 
hsvColor4 = rgb2hsv(typeColorRGB);
hsvColor4 = hsvColor4(:,1);


% MakeFigure;
% scatter(roiDSI,roiESI);

roiHSV = zeros(nRoi,3);
for rr = 1:1:nRoi
    roiHSV(rr,1) = hsvColor4(roiEdgeType(rr));
    roiHSV(rr,2) = roiESI(rr);
    roiHSV(rr,3) = roiDSI(rr);
end
% 
% roiESIHE = histeq(roiESI);
% roiDSIHE = histeq(roiDSI);
% for rr = 1:1:nRoi
%     roiHSV(rr,1) = hsvColor4(roiEdgeType(rr));
%     roiHSV(rr,2) = roiESIHE(rr);
%     roiHSV(rr,3) = roiESIHE(rr);
% end

roiRGB = hsv2rgb(roiHSV);

roiImageRoi = zeros([size(roiImage),nRoi,3]);
alph = zeros(size(roiImage));
% put the roiRGB into each roiMasks...
for rr = 1:nRoi
    roiMaskThis = logical(roiMasks(:, :, rr));
    alph = alph | roiMaskThis; 
    
    roiImageThis = roiMaskThis * roiRGB(rr,1);
    roiImageRoi(:,:,rr,1) = roiImageThis;
    roiImageThis = roiMaskThis * roiRGB(rr,2);
    roiImageRoi(:,:,rr,2) = roiImageThis;
    roiImageThis = roiMaskThis * roiRGB(rr,3);
    roiImageRoi(:,:,rr,3) = roiImageThis; 
end
roiDisplayImage = squeeze(sum(roiImageRoi,3));


