function SupplementaryFigure_3_1B_FWHM_Demo()

clear
clc
PCSetup;

FWHMBank = 25;
histeqMode = 0;
onlyLum = 0;
velCalMode = 'inst';
velSampMode = 'Uniform';
contrast_form = 'dynamic';
%%
FWHMBank = [15, 25, 35, 45, 55, 65, 75];
% get example line at various FWHM.
n_scenes = length(FWHMBank);
contrPictureLocal = cell(n_scenes, 1);
for ii = 1:1:length(FWHMBank)
    param = ParameterFile(OSMode,ii, histeqMode,onlyLum,velCalMode,velSampMode,'FWHMBank', FWHMBank, 'contrast_form',contrast_form);
    path = param.path;
    photoreceptor = param.photoreceptor;
    image = param.image;
    Gaussian =  photoreceptor.spatial.filter;
    filter = image.lcf.filter;
    
    imageDataInfo  = dir(fullfile(path.raw , '*.mat'));
    nfile = length(imageDataInfo);
    imageID = 50;
    
    
    rawPicture = LoadImage(imageID, imageDataInfo,path.raw);
    flyPicture = MyConv2(rawPicture,Gaussian);
    [contrPictureLocal{ii},meanLumImage] = LumToContrastLocal(flyPicture,filter);
end
%% plot the full range 360 horizontally. 90 vertically.
line_plot = 100;
color_bank = brewermap(n_scenes, 'BuPu');
ylabel_bank = {'contrast'}; % what is the luminance unit?
color_bank(2,:) = [1,0,0];
MakeFigure;
subplot(2,1,1);
for ii = 1:1:n_scenes
    line_this = contrPictureLocal{ii}(line_plot,:);
    hold on
    plot(line_this,'color',color_bank(ii,:));
    set(gca,'XTick',[1,927/2,927],'XTickLabel',{'-180\circ','0\circ','180\circ'});
    if ii == 3
        set(gca,'Xlim',[1, 927],'YLim',[-1, 1]);
    end
    ConfAxis
end
legend('15\circ','25\circ','35\circ','45\circ','55\circ','65\circ','75\circ');
end
% MySaveFig_Juyue(gcf,'Natural_Scene_Preprocessing','id50_row100_differentContrast','nFigSave',2,'fileType',{'eps','fig'})