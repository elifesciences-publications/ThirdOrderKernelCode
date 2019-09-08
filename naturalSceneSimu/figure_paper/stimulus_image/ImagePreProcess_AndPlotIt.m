function [rawPicture,flyPicture, contrPictureLocal] = ImagePreProcess_AndPlotIt(param)
path = param.path;
photoreceptor = param.photoreceptor;
image = param.image;
Gaussian =  photoreceptor.spatial.filter;
filter = image.lcf.filter;

imageDataInfo  = dir(fullfile(path.raw , '*.mat'));
nfile = length(imageDataInfo);
for imageID = 50;
    
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
        [contrPictureLocal,meanLumImage] = LumToContrastLocal(flyPicture,filter);
    end
    %%
end

end