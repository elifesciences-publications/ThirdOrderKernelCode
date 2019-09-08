function ImagePreProcess_OnlyPhotoReceptorBlurring(param)
path.image = 'D:\Natural_Scene_Simu\image\dynamiche0';
path.raw = 'D:\Natural_Scene_Simu\image\data_001-100';
photoreceptor = param.photoreceptor;
image = param.image;
Gaussian =  photoreceptor.spatial.filter;
filter = image.lcf.filter;

imageDataInfo  = dir(fullfile( path.raw , '*.mat'));
nfile = length(imageDataInfo);
for imageID = 1:1:nfile
    
    rawPicture = LoadImage(imageID, imageDataInfo,path.raw);
    flyPicture = MyConv2(rawPicture,Gaussian);
    
    SaveImage(imageID,flyPicture,path);
    
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