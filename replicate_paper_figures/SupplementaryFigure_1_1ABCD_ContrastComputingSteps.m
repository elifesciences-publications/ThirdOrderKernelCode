function SupplementaryFigure_1_1ABCD_ContrastComputingSteps()
clear
clc
PCSetup;

FWHMBank = 25;
histeqMode = 0;
onlyLum = 0;
velCalMode = 'inst';
velSampMode = 'Uniform';
contrast_form = 'dynamic';

%% redo it...

param = ParameterFile(OSMode,1, histeqMode,onlyLum,velCalMode,velSampMode,'FWHMBank', FWHMBank, 'contrast_form',contrast_form);
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
[contrPictureLocal,meanLumImage] = LumToContrastLocal(flyPicture,filter);

%% plot the full range 360 horizontally. 90 vertically.
ver_degree = param.image.origin.ver.degree;
ver_range = ver_degree(1) - ver_degree(end);
ver_range_plot = 90;
n_ver_used = abs(ceil(size(rawPicture, 1) /ver_range * ver_range_plot));

picture_show = cell(4, 1);
picture_show{1} = rawPicture(1:n_ver_used, :); max_lum = max(abs(picture_show{1}(:)));
picture_show{2} = flyPicture(1:n_ver_used, :); 
picture_show{3} = meanLumImage(1:n_ver_used, :); max_mean = max(abs(picture_show{3}(:)));
picture_show{4} = contrPictureLocal(1:n_ver_used, :); max_contrast = max(abs(picture_show{4}(:)));

%% plot a line. 
line_plot = 100;
ylabel_bank = {'luminance','luminance','luminance','contrast'}; % what is the luminance unit?
ylim_range = {[0,max_lum], [0,max_lum], [0,max_lum],[-0.5, 0.5]};
h_line_plot = cell(4, 1);
MakeFigure;
for ii = 1:1:4
    subplot(2,4,ii);
    imagesc(picture_show{ii});colormap(gray);
    hold on
    plot(get(gca,'XLim'),[line_plot, line_plot],'r-');
    set(gca,'XTick',[1,927/2,927],'XTickLabel',{'-180\circ','0\circ','180\circ'});
    set(gca,'YTick',[1, n_ver_used],'YTickLabel',{'45\circ','-45\circ'});
    set(gca,'Xlim',[1, 927]);
%     colorbar
    daspect([1,1,1]);
    ConfAxis
    box on
    % plot a spatial scale/
    if ii == 3
       [x, y] = plot_circle(100, 100, 25);
       plot(x, y,'k');
    end
    
    
    subplot(4,4,ii + 12);
    h_line_plot = plot(picture_show{ii}(line_plot,:),'k');
    hold on; plot(get(gca, 'XLim'), [0,0], 'k--');
    set(gca,'XTick',[1,927/2,927],'XTickLabel',{'-180\circ','0\circ','180\circ'});
    if ii <4
        set(gca,'Xlim',[1, 927],'YLim',ylim_range{ii} * 1.1);
        set(gca,'YScale','log');
        set(gca,'YTick',[0.01, 0.1, 1, 2]*1e4,'YTickLabel',{'100', '1,000',' 10,000', '20,000'});
    end

    if ii == 4
       set(gca,'Xlim',[1, 927],'YLim',[-0.5, 0.5]);
    end

    ylabel(ylabel_bank{ii})
    ConfAxis
end
% MySaveFig_Juyue(gcf,'Natural_Scene_Preprocessing_with_mean','id50','nFigSave',2,'fileType',{'eps','fig'})
