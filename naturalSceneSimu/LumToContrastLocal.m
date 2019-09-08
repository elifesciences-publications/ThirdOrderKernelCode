function [contrastImage,meanLum] = LumToContrastLocal(xLum,filter)
plotFlag = 0;
% x should be one image. % 20 degree.
meanLum = MyConv2(xLum,filter);
% do I store the meanLum of the picture, it might be an interesting
% thing...
% not yet...
contrastImage = xLum./meanLum - 1;

if plotFlag
    makeFigure;
    subplot(3,2,1); imagesc(xLum);title('after photoreceptor');colormap(gray); set(gca, 'XTick', []); set(gca, 'YTick', []);    ConfAxis
    SemilogyHistogram(xLum(:),[3,2,2]);
    subplot(3,2,3);imagesc(meanLum);title('mean luminance');colormap(gray);  set(gca, 'XTick', []); set(gca, 'YTick', []);  ConfAxis
    SemilogyHistogram(meanLum(:),[3,2,4]);
    subplot(3,2,5);imagesc(contrastImage);title('contrast map');colormap(gray);  set(gca, 'XTick', []); set(gca, 'YTick', []); ConfAxis
    SemilogyHistogram(contrastImage(:),[3,2,6]);
    MySaveFig_Juyue(gcf, 'imag_','process','nFigSave',2,'fileType',{'png','fig'})
end
end