function AnaVStimR(v,stimc)


% first, plot the second order kernel and stimc.

% try different ways to bin the data
% % first, use the velocity....
% [bink2,binstimc.max] = BinXY(abs(v.k2),stimc.max);
% [bink2,binstimc.mean] = BinXY(abs(v.k2),stimc.mean);
% [bink2,binstimc.std] = BinXY(abs(v.k2),stimc.std);
% 
% MyScatterstimcV(binstimc,log(bink2),strInfo);
% 
% strInfo.title = 'K3';
% % try different ways to bin the data
% % first, use the velocity....
% [bink3,binstimc.max] = BinXY(abs(v.k3),stimc.max);
% [bink3,binstimc.mean] = BinXY(abs(v.k3),stimc.mean);
% [bink3,binstimc.std] = BinXY(abs(v.k3), stimc.std);
% 
% MyScatterstimcV(binstimc,log(bink3),strInfo);
% MyScatterstimcLogV(binstimc,bink3,strInfo);
%% use the constrast to bin the data.
binStandard = 'y';
strInfo.title = 'K2';
[bink2.max,binstimc.max] = BinXY(abs(v.k2),stimc.max,binStandard);
%[bink2.mean,binstimc.mean] = BinXY(abs(v.k2),stimc.mean,binStandard);
[bink2.std,binstimc.std] = BinXY(abs(v.k2),stimc.std,binStandard);

MyScatterStimLogV(binstimc,bink2,strInfo);

strInfo.title = 'K3';
% try different ways to bin the data
% first, use the velocity....
[bink3.max,binstimc.max] = BinXY(abs(v.k3),stimc.max,binStandard);
%[bink3.mean,binstimc.mean] = BinXY(abs(v.k3),stimc.mean,binStandard);
[bink3.std,binstimc.std] = BinXY(abs(v.k3), stimc.std,binStandard);

MyScatterStimLogV(binstimc,bink3,strInfo);

%% try to understand whether the extreme values are comining from save data point.
binStandard = 'y';
strInfo.title = 'K2';
[bink2.max,binstimc.max] = BinXY(v.k2,stimc.max,binStandard);
%[bink2.mean,binstimc.mean] = BinXY(abs(v.k2),stimc.mean,binStandard);
[bink2.std,binstimc.std] = BinXY(v.k2,stimc.std,binStandard);
MyScatterStimV(binstimc,bink2,strInfo);

strInfo.title = 'K3';
% try different ways to bin the data
% first, use the velocity....
[bink3.max,binstimc.max] = BinXY(v.k3,stimc.max,binStandard);
%[bink3.mean,binstimc.mean] = BinXY(abs(v.k3),stimc.mean,binStandard);
[bink3.std,binstimc.std] = BinXY(v.k3, stimc.std,binStandard);
MyScatterStimV(binstimc,bink3,strInfo);

%% delete some data and see the result.
% 
% check how many data would be lost ?  
% check the effect of the data deletion.

% check how many 
% calcuate the absolute value of the 
% first, anlyze the stimc/v.

% p = [0.05,0.5,1,2,5];
% np = length(p);
% 
% for i = 1:1:np
%     [~,indHRC] = PerV(p(i),v.HRC);
%     [~,indk2] = PerV(p(i),v.k2);
%     [~,indk3] = PerV(p(i),v.k3);
%     ind = indHRC & indk2 & indk3;
%     
% %     % find the image, not promising.
% %     indImageExt = ~ind;
% %     imageExt = imageID(indImageExt);
% %     makeFigure;
% %     h = histogram(imageExt);
% %     h.BinWidth = 1;
%     % store the number of outliers of each image.
%     % compute the contrast of that particular stimculus used by these
%     % stimculs.
%    % title( [num2str(2 * p(i)),'% extremes are coming from these images']);
%     
%     %% plot the stimculus properties.
end


