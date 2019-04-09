% show the bad image.
clear
clc
PCSetup;
PathManagement;
ParameterFile;

% these image are outliers because they generate extrem value.
imageOutlier = param.imageOutlier;
imageOutlier = sort(imageOutlier);
nOut = length(imageOutlier);

%load the preprocessed data.
imageDataInfo  = dir([path.image '*.mat']);
for i = 1:1:nOut
    imageID = imageOutlier(i);
    I = LoadProcessedImage(imageID, imageDataInfo,path.image);
    
    makeFigure
    set(plotH,'Visible','off');
    imshow(I);
    set(gca,'clim',[-1 max(I(:))]);
    title(['ImageID : ', num2str(imageID)]);
    saveas(plotH,['ImageID', num2str(imageID),'.jpg']);
    %path image, show them and collect them.
end