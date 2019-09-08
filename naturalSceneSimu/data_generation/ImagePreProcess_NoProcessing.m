function ImagePreProcess_NoProcessing(param)
path = param.path;
imageDataInfo  = dir(fullfile(path.raw , '*.mat'));
nfile = length(imageDataInfo);
for imageID = 1:1:nfile;   
    rawPicture = LoadImage(imageID, imageDataInfo,path.raw);
    SaveImage(imageID,rawPicture,path);

end

end

% MakeFigure;
%  subplot(3,2,1); imagesc(rawPicture);title('luminance picture');colormap(gray); set(gca, 'XTick', []); set(gca, 'YTick', []);    ConfAxis
%     SemilogyHistogram(rawPicture(:),[3,2,2]);
%     MySaveFig_Juyue(gcf, 'image1','raw','nFigSave',2,'fileType',{'png','fig'})
%  MySaveFig_Juyue(gcf, 'image1','process','nFigSave',2,'fileType',{'png','fig'})