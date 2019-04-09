function L = SAC_RoiSelection_WaterShed(I)
plot_flag = 0;
% nlines = 128; % last line is not recorded.
thresh =0.75;  % give more BW.
size_thresh = 20;
DS_OPEN = 10;
DS_FGM_DILATE = 5;
DS_FGM_ERODE = 3;
%% contrast adjusted.
I_cd = imadjust(I);

%% opening by construction.
se = strel('disk', DS_OPEN);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);

%% TopHat filtered. Get rid of uneven luminance
Iobrtf = I - Iobr;
Iobrtf_cd = imadjust(Iobrtf);

%% closing by reconstruction.
Iobrd = imdilate(Iobrtf_cd,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobrtf_cd));
Iobrcbr = imcomplement(Iobrcbr);

%% binarize the Iobrtf_cd
level = graythresh(Iobrcbr);
level = level * thresh; %
BW = imbinarize(Iobrcbr, level* thresh);

%% use the BW to mask Iobrtf_cd
Iobrtf_cleaned = Iobrcbr;
Iobrtf_cleaned(~BW) = 0;

%% Compute the Forground marker.
fgm = imregionalmax(Iobrtf_cleaned);
% grow fgm a bit
fgm1 = imdilate(fgm, ones(DS_FGM_DILATE));
fgm2 = imerode(fgm1, ones(DS_FGM_ERODE));

%% Compute Background Markers
D = bwdist(BW);
DL = watershed(D);
bgm = DL == 0;

%% Compute the Watershed Transform of the Segmentation Function
gmag2 = imimposemin(imcomplement(I_cd), bgm | fgm2 );
L_ori = watershed(gmag2);

%% last constrain the roi with BW and clean up small rois.
L = L_ori;
L(~BW) = 0;

% MakeFigure;
% Lrgb = label2rgb(L,'jet','w','shuffle');
% imshow(I_cd);
% hold on
% himage = imshow(Lrgb);
% himage.AlphaData = 0.3;
% title('Colored Labels Superimposed Transparently on Original Image')
% ConfAxis

L = clean_small_rois(L, size_thresh);

%% Plot Roi.
show_roi_mask(I_cd, L);
%% save the rois figure;
if plot_flag
    % first, original image and its contrast enhanced version.
    MakeFigure;
    subplot(2,2,1);
    imshow(I);
    title('original mean movie');
    ConfAxis
    
    subplot(2,2,2)
    imshow(I_cd)
    title('contrast enhanced');
    ConfAxis
    
    %% processing procedure.
    MakeFigure;
    % original image, and opening-closing by construction.
    subplot(2,3,1);
    imshow(I_cd);
    title('constrast enhanced ');
    ConfAxis
    
    subplot(2,3,4);
    imshow(Iobrcbr);
    title('opening-closing by construction');
    ConfAxis
    
    % foreground
    subplot(2,3,2);
    imshow(Iobrtf_cleaned);
    title('image for foreground')
    ConfAxis
    
    subplot(2,3,5);
    imshow(fgm2 );
    title('foreground');
    ConfAxis
    
    % background
    subplot(2,3,3);
    imshow(D);
    title('image for background');
    ConfAxis
    
    subplot(2,3,6);
    imshow(bgm);
    title('image for background');
    ConfAxis
    
    %% final result.
    MakeFigure;
    subplot(2,2,1);
    imshow(gmag2);
    title('processed image for watershed');
    ConfAxis
    
    subplot(2,2,2);
    L_ori_rgb = label2rgb(L_ori,'jet','w','shuffle');
    imshow(L_ori_rgb);
    title('watershed result');
    ConfAxis
end
end

function L_eff = clean_small_rois(L, size_thresh)
%% Clean small rois.
L_eff = zeros(size(L));
n = max(L(:));
n_eff = 0;
for ii = 1:1:n
    npixel = sum(sum(L == ii));
    if npixel >= size_thresh
        n_eff = n_eff + 1;
        L_eff(L == ii) = n_eff;
    end
end
end