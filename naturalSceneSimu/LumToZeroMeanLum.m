function contrastImage = LumToZeroMeanLum(xLum,filter)
plotFlag = 0;
% x should be one image. % 20 degree.
meanLum = MyConv2(xLum,filter);
% do I store the meanLum of the picture, it might be an interesting
% thing...
% not yet...
contrastImage = xLum - meanLum;

if plotFlag
    MakeFigure;
    subplot(3,2,1); imshow(xLum,[]);title('raw picture/after photoreceptor');
    SemilogyHistogram(xLum(:),[3,2,2]);
    ConfAxis
    subplot(3,2,3);imshow(meanLum,[]);title('mean luminance');
    SemilogyHistogram(meanLum(:),[3,2,4]);
    ConfAxis
    subplot(3,2,5);imshow(contrastImage,[]);title('Lum - LumMean');
    SemilogyHistogram(contrastImage(:),[3,2,6]);
    ConfAxis
end
end