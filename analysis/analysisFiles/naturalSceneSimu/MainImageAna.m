function  MainImageAna(param)
path = param.path;
%%
contrSpacialWinBank = [10,25,50];
nw = length(contrSpacialWinBank);
%% create folder to store the data...
foldername = cell(nw,1);
allPixel = cell(nw + 1,1);
nhor = param.image.origin.hor.nPixel;
nver = param.image.origin.ver.nPixel;

%%
for ww = 1:1:nw
    swSize = contrSpacialWinBank(ww);
    foldername{ww} = [path.image_ana,'SW_',num2str(swSize),'\'];
end

imageInfo = dir([foldername{1},'*.mat']);
nimage = length(imageInfo);
for ww = 1:1:nw
    allPixel{ww} = zeros(nver,nhor,nimage);
end
allPixel{end} = zeros(nver,nhor,nimage);
for ww = 1:1:nw
    for imageID = 1:1:nimage
        % get new data to analyze the histogram of first 100 images.
        I = load([foldername{ww}, imageInfo(imageID).name]);
        I = I.I;
        allPixel{ww}(:,:,imageID) = I;      
    end
    D = allPixel{ww};
    filenameD = [foldername{ww},'allPixel'];
    mkdir(filenameD);
    filenameD = [filenameD,'\D'];
    save(filenameD,'D');
end

% load the global picture;

folderglobal = path.image_cg;
imageInfo = dir([folderglobal,'*.mat']);
for imageID = 1:1:nimage
    I = load([folderglobal,imageInfo(imageID).name]);
    I = I.I;
    allPixel{end}(:,:,imageID) = I;
end
D = allPixel{end};
filenameD = [folderglobal,'allPixel\'];
mkdir(filenameD);
filenameD = [filenameD,'\D'];
save(filenameD,'D')

%% given all the data, get the relationsho between 
%% given all the data, plot picture and go home. finish todays' working...
% load('ContraLocalData.mat');
% DistrHistPlotContr(allPixel);
% makeFigure;
% for ww = 1:1:nw
%     swSize = contrSpacialWinBank(ww);
%     subplot(2,2,ww)
%     histogram(allPixel{ww}(:));
%     title(['histogram of contrast, local: ',num2str(swSize),'degree']);
%     xlabel('contrast');
%     ylabel('counts');
%     figurePretty;
%     
% end
% 
% subplot(2,2,4)
% histogram(allPixel{end}(:));
% title(['histogram of contrast,global: ',num2str(swSize),'degree']);
% xlabel('contrast');
% ylabel('counts');
% figurePretty;

% makeFigure in another way... plot the figure together?
% no.. that might be good enough.
% no....,try to plot that 
% calculate the 
end