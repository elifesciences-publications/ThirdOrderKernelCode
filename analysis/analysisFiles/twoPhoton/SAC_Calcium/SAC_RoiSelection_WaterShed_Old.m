function SAC_RoiSelection_WaterShed(movie)

% use water shed to get rois.
% first, calculate the mean movie
mean_f = mean(movie(1:127, :, :), 3); % averaged over time. hopefully, not much movement.

mean_f_smoothed = imtophat(mean_f , strel('disk', 20));

% second,
mean_f_smoothed = mean_f_smoothed/max(mean_f_smoothed(:));
level = graythresh(mean_f_smoothed);
BW = imbinarize(mean_f_smoothed, level);

% third
D = -bwdist(~BW);
D(~BW) = -Inf;
L = watershed(D);

% fourth. connect large together and throw out small.


%% over segmentation...
MakeFigure;
subplot(2,3,1);
imagesc(mean_f); colormap(gray); axis image off; daspect([1,1,1]);

subplot(2,3,2);
imagesc(mean_f_smoothed);colormap(gray); axis image off; daspect([1,1,1]);

subplot(2,3,3);
imagesc(BW );colormap(gray); axis image off; daspect([1,1,1]);

subplot(2,3,4);
imagesc(D);colormap(gray); axis image off; daspect([1,1,1]);

subplot(2,3,5);
imagesc(mean_f); colormap(gray);hold on;daspect([1,1,1]);
imagesc(label2rgb(L,'jet','w'))
end