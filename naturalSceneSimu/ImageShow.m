function ImageShow(param,imageID)
path = param.path;
image = param.image;
image_cl_path = FoldernameGenCL(path,image.lcf.FWHM, 0);
image_cle_path = FoldernameGenCL(path,image.lcf.FWHM ,1);


makeFigure;
subplot(2,1,1);
imageDataInfo  = dir([image_cl_path '*.mat']);
I = LoadProcessedImage(imageID,imageDataInfo,image_cl_path);
imshow(I,[]);
colorbar;
titleStr = ['Image',num2str(imageID),': FWHM-', num2str(image.lcf.FWHM)];
title(titleStr);

subplot(2,1,2);
imageDataInfo  = dir([image_cle_path '*.mat']);
I = LoadProcessedImage(imageID,imageDataInfo,image_cle_path);
imshow(I,[]);
colorbar;
titleStr = ['Image',num2str(imageID),': FWHM-', num2str(image.lcf.FWHM), ': after histogram equlization'];
title(titleStr);

saveas(gcf,['FWHM_',num2str(image.lcf.FWHM),'.jpg']);
