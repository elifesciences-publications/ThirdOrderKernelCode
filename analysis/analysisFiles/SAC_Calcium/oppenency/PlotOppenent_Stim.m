load('D:\data_sac_calcium\stim_info\C4_sinusoid_opponent.mat');
MakeFigure; 
for ii = 1:1:12
subplot(3, 4, ii)
imagesc(p.cont(:,:,ii)); colormap(gray);
end
MakeFigure; 
for ii = 1:1:12
subplot(3, 4, ii)
imagesc(p.cont(:,:,ii + 12)); colormap(gray);
end