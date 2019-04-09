function [stimMean,vValue] = AnaDataVStimScatter(param, result)
nv = length(result);
stimMean.std.mean = zeros(nv,1);
stimMean.max.mean = zeros(nv,1);
stimMean.max.max = zeros(nv,1);
vValue = zeros(nv,1);


% %
% makeFigure;
for vv = 1:1:nv
    v = result{vv}.v;
    stimc = result{vv}.stimc;
    imageID = result{vv}.imageID;
    
    vValue(vv) = abs(v(1));
    stimMean.std.mean(vv) = mean(stimc.std);
    stimMean.max.mean(vv) = mean(stimc.max);
    stimMean.max.max(vv) = max(stimc.max);
%     
%     subplot(2,1,1)
%     scatter(abs(v),stimc.max,'r.');
%     title('max');
%     xlabel('velocity');
%     hold on
%     
%     subplot(2,1,2)
%     scatter(abs(v), stimc.std,'r.');
%     title('std');
%     xlabel('velocity');
%     hold on
    
    
    %
end
% figTitle = ['VS_FWHM',num2str(round(param.image.lcf.FWHM)),'.jpg'];
% saveas(gcf,figTitle);
%
% subplot(5,1,2)
% scatter(vValue,stimMean.max.max,'r+');
% title('max of max');
% xlabel('velocity [degree/second]');
% ylabel('contrast');
%
% subplot(5,1,3)
% scatter(vValue,stimMean.max.max,'r+');
% title('mean of max');
% xlabel('velocity [degree/second]');
% ylabel('contrast');
%
%
% subplot(5,1,5)
% scatter(vValue,stimMean.std.mean,'r+');
% title('mean of std');
% xlabel('velocity [degree/second]');
% ylabel('contrast');
end