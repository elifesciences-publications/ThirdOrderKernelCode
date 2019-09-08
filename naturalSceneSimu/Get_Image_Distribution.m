function [f0,x0,I] = Get_Image_Distribution(param)

% first, load the data and put all the image together.
path = param.path;
image = param.image;
% the contrast would go from -1 to 1.
% not the raw image. but the 
% the data comes from path.image_cl, and the data will go to
% path.image_cle. I would transfer the data back to computer from cluster.
% for the data transformation, you have to generate path from here.

image_cl_path = FoldernameGenCL(path,image.lcf.FWHM, 0);
image_cle_path = FoldernameGenCL(path,image.lcf.FWHM ,1);

imageDataInfo  = dir([image_cl_path '*.mat']);
nfile = length(imageDataInfo);
%% I should create a huge matrix to store the image.
nhor = image.param.hor.nPixel;
nver = image.param.ver.nPixel;
I = zeros(nver,nhor,nfile);
for imageID = 1:1:nfile
    I(:,:,imageID) = LoadProcessedImage(imageID, imageDataInfo,image_cl_path);
    
end

%% after load all the images into the big matix, calculate the cdf.
[f0,x0] = ecdf(I(:));
% % transfer the f0 from 0 to 1 into range a and b;
% a = range(1);
% b = range(2);
% f = (b - a) * f0 + a;
% % histequ.x = x0;
% % histequ.f = f;
% % 
% % cle_hist_file = [path.paradata,'hist',num2str(round(image.lcf.FWHM)),'.mat'];
% % save(cle_hist_file,'histequ');
% 
% % %%
% for imageID = 1:1:nfile
%     [~,ind] = ismember(I(:,:,imageID),x0);
%     Ihist = f(ind);
%     SaveImagehe(imageID, Ihist,image_cle_path);
% end


end