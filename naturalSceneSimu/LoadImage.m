function rawPicture = LoadImage(imageID, imageDataInfo,pathname)

% given the name and path of the image, 
% return the lumninance of the picture

filename = imageDataInfo(imageID).name;
image = load(fullfile(pathname,filename));
rawPicture = image.projection;

%this is where raw data would be stored
end