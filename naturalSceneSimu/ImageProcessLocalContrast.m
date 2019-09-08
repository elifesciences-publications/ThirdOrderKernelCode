function ImageProcessLocalContrast(param)
path = param.path;
photoreceptor = param.photoreceptor;

%%
imageDataInfo  = dir([path.raw '*.mat']);
% imageInfo stores the name, path of those image, it is a large structure.
Gaussian =  photoreceptor.spatial.filter;
nfile = length(imageDataInfo);
%%
%%
contrSpacialWinBank = [10,25,50];
nw = length(contrSpacialWinBank);
% create folder to store the data...
foldername = cell(nw,1);

%%
for ww = 1:1:nw
    swSize = contrSpacialWinBank(ww);
    foldername{ww} = [path.image_ana,'\SW_',num2str(swSize)];
    mkdir(foldername{ww});
    foldername{ww} = [foldername{ww},'\'];

end

% create a huge vector to store the image wichi are to be processed?


% create three image here.
% how could I calculate separately
%%
for imageID = 101:1:nfile
    
    rawPicture = LoadImage(imageID, imageDataInfo,path.raw);
    flyPicture = MyConv2(rawPicture,Gaussian);
%    makeFigure
%     imshow(flyPicture)
%     set(gca,'clim',[min(flyPicture(:)) max(flyPicture(:))]);
%     title(['fly picture, ImageID :', num2str(imageID)]);

    % choose three differet size of spatial window.
    % [10,25,50,global];
    % store the three different into ImageAna.
    for ww = 1:1:nw
        swSize = contrSpacialWinBank(ww);
        contrPicture = LumToContrastLocal(flyPicture,swSize);
        % store the image.
        pathname = foldername{ww};
        SaveImagePathname(imageID,contrPicture,pathname);
        
%         makeFigure
%         imshow(contrPicture)
%         set(gca,'clim',[min(contrPicture(:)) max(contrPicture(:))]);
%         title(['contrast picture, local: ',num2str(swSize),'degree'])

    end
end

end