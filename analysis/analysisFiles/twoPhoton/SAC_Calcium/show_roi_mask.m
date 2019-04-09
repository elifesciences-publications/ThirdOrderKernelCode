function show_roi_mask(I, L)

MakeFigure; 
imshow(I);
hold on;

%% plot labels on it.
n_roi = max(L(:));
color_bank = jet(n_roi);
roi_center = SAC_utils_cal_roi_center(L);
for rr = 1:1:n_roi
    % get boundary.
    boundary = MyBWBoundaries(L == rr);
    boundary = boundary{1};
    plot(boundary(:,2), boundary(:,1), 'LineWidth',3 ,'color', color_bank(rr,:));
    text(roi_center(rr, 2), roi_center(rr, 1), num2str(rr),'FontSize', 25);
end
title('Roi Mask on Original Mean Movie');
ConfAxis
end