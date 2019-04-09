function ImageHistEquaPlot(param)

% first, load the data and put all the image together.
path = param.path;
image = param.image;
% the contrast would go from -1 to 1.

cle_hist_file = [path.paradata,'hist',num2str(round(image.lcf.FWHM)),'.mat'];
load(cle_hist_file,'histequ');

disp('successfully load data');

makeFigure;
set(plotH,'Visible','off');
subplot(2,1,1)
plot(histequ.x,histequ.f,'lineWidth',3);
%plot(x0,f)
title(['histogram equalization function for FWHM : ',num2str(image.lcf.FWHM)]);
xlabel('contrast')
ylabel('pixel grey value after histogram equalization');
figurePretty;

subplot(2,1,2)
histogram(histequ.x);
title(['contrast distribution for FWHM : ',num2str(image.lcf.FWHM)]);
xlabel('contrast');
ylabel('count');
figurePretty;
disp('successfully plot data');
saveas(gcf,['FWHM_',num2str(image.lcf.FWHM),'.jpg']);
disp('successfully save the data');
% %%
% for imageID = 1:1:nfile
%     [~,ind] = ismember(I(:,:,imageID),x0);
%     Ihist = f(ind);
%     SaveImagehe(imageID, Ihist,image_cle_path);
% end


end