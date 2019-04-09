function I = LoadProcessedImage(imageID, pathname)

% given the name and path of the image, 
% return the lumninance of the picture
imageDataInfo  = dir(fullfile(pathname, '*.mat'));
filename = imageDataInfo(imageID).name;
load(fullfile(pathname,filename));

end