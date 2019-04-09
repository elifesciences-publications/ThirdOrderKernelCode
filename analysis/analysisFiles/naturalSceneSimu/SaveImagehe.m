function SaveImagehe(imageID, I, pathname)
% only save the image.
% do not contain the descriptive signal into it.
filename = ['Image', num2str(imageID)];
fullname = [pathname,filename];
save(fullname,'I');

end