function ImagePreProcess(param)
path = param.path;
photoreceptor = param.photoreceptor;
image = param.image;
Gaussian =  photoreceptor.spatial.filter;
filter = image.lcf.filter;

imageDataInfo  = dir(fullfile(path.raw , '*.mat'));
nfile = length(imageDataInfo);
for imageID = 1:1:nfile;
    
    rawPicture = LoadImage(imageID, imageDataInfo,path.raw);
    if photoreceptor.spatial.on
        flyPicture = MyConv2(rawPicture,Gaussian);
    else
        flyPicture = rawPicture;
    end
    if param.image.lcf.FWHM == 360
        mean_full_picture = mean(flyPicture(:));
        contrPictureLocal = flyPicture/mean_full_picture - 1;
    else
        contrPictureLocal = LumToContrastLocal(flyPicture,filter);
    end
    SaveImage(imageID,contrPictureLocal,path);
    
    %     keyboard;
    % third, I should only subtract the mean luminance from an image.
    %     flyPicture = MyConv2(rawPicture,Gaussian);
    %     if param.image.lcf.FWHM == 360
    %         LumZeroMeanPicture = flyPicture -  mean(flyPicture(:));
    %     else
    %         LumZeroMeanPicture = LumToZeroMeanLum(flyPicture,filter);
    %     end
    %     SaveImage(imageID,LumZeroMeanPicture,path);
end

end

% MakeFigure;
%  subplot(3,2,1); imagesc(rawPicture);title('luminance picture');colormap(gray); set(gca, 'XTick', []); set(gca, 'YTick', []);    ConfAxis
%     SemilogyHistogram(rawPicture(:),[3,2,2]);
%     MySaveFig_Juyue(gcf, 'image1','raw','nFigSave',2,'fileType',{'png','fig'})
%  MySaveFig_Juyue(gcf, 'image1','process','nFigSave',2,'fileType',{'png','fig'})