function SupplementaryFigure_3_1A_FWHM_Demo()
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
MakeFigure;
subplot(2,4,1);

ver_degree = param.image.origin.ver.degree;
ver_range = ver_degree(1) - ver_degree(end);
ver_range_plot = 90;
n_ver_used = abs(ceil(size(rawPicture, 1) /ver_range * ver_range_plot));

picture_show = cell(4, 1);
picture_show{2} = flyPicture(1:n_ver_used, :);

% plot a line.
line_plot = 100;
imagesc(picture_show{2});colormap(gray);
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

%% set up color scheme
FWHM_bank = [15, 25, 35, 45, 55, 65, 75];
color_bank = brewermap(length(FWHM_bank), 'BuPu');
color_bank = flipud(color_bank);
color_bank(2,:) = [1,0,0];

for ii = 1:1:length(FWHM_bank)
    [x, y] = plot_circle(100, 100, FWHM_bank(ii));
    plot(x, y, 'color',color_bank(ii,:));
end

end
% MySaveFig_Juyue(gcf,'Natural_Scene_Preprocessing_different spatial ranage','id50','nFigSave',2,'fileType',{'eps','fig'});
