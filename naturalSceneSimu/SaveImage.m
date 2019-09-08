function SaveImage(imageID, I, path)
% only save the image.
% do not contain the descriptive signal into it.
pathname = path.image;

if ~exist(pathname,'dir');
    mkdir(pathname);
end

filename = ['Image', num2str(imageID)];
fullname = fullfile(pathname,filename);
save(fullname,'I');

end