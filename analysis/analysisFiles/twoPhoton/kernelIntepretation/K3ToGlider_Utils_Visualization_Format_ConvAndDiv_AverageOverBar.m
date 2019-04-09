function K3ToGlider_Utils_Visualization_Format_ConvAndDiv_AverageOverBar(firstKernel,secondKernel,thirdKernelCorrType,corrParam_Third,barUse, barUseAverage,edgeType)
% this is only one format.
% barUse = 7:12; % not correct...
% for ii = 1:2:length(varargin)
%     eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
% end
% this have a lot of rois...

[~,~,nRoi] = size(thirdKernelCorrType{1});
nDxBank = 4;
corrDiv =  cellfun(@(corrType) corrType.dt(2) == 0 & corrType.dt(1) ~= 0 ,corrParam_Third);
corrConv =  cellfun(@(corrType) corrType.dt(1) == corrType.dt(2) & corrType.dt(1) ~= 0 ,corrParam_Third);

% prefered direction... pos or neg...
% do the calculation first, and then decide which to draw...
nBar = length(barUse); % should be 3/
glider.value = cell(nDxBank,nBar);
glider.meanOverTime = zeros(nDxBank,nBar,nRoi);
glider.meanOverBar = cell(nDxBank,1);
glider.meanOverTimeBar = zeros(nDxBank,nRoi);
glider.nameStr = {'Reg/Div','Pro/Conv','Pro/Div','Reg/Conv'};
for qq = 1:1:length(barUse)
    % value..%
    % it determines whether to plot positive or negative.
    glider.value{1,qq} = squeeze(thirdKernelCorrType{1}(corrDiv,barUse(qq),:));
    glider.value{2,qq} = squeeze(thirdKernelCorrType{1}(corrConv,barUse(qq),:));
    glider.value{3,qq} = squeeze(thirdKernelCorrType{2}(corrDiv,barUse(qq),:));
    glider.value{4,qq} = squeeze(thirdKernelCorrType{2}(corrConv,barUse(qq),:));
    
    glider.meanOverTime(:,qq,:) = cell2mat(cellfun(@(value) mean(value),glider.value(:,qq),'UniformOutput',false)); % first dimesion is time.
end
for tt = 1:1:nDxBank
    glider.meanOverBar{tt} = mean(reshape(cell2mat(glider.value(tt,ismember(barUse,barUseAverage),:)),[],nRoi,length(barUseAverage)),3); % average over bars.
end
glider.meanOverTimeBar = cellfun(@(meanOverBar)mean(meanOverBar),glider.meanOverBar,'UniformOutput',false); %

%% your would get the mean value and the error bar!
% For T4, plot the converging one. For T5, plot the diverging one.
edgeTypeToPreferGlider_lookup = [4,2,3,1]; % T4 Progressive -  neg Converging. T4 Regressive = pos Converging. % T5 Progressive, neg diverging, T5 Regressive, pos diverging.
preferedCorrType = edgeTypeToPreferGlider_lookup(edgeType);

MakeFigure;
subplot(2,2,1);
quickViewOneKernel(flipud(firstKernel),1,'colorbarFlag',false);

timeUnit = 1/60;
subplot(4,6,4:5);
meanOverBar =  mean(glider.meanOverBar{preferedCorrType},2);
stdOverBar = std(glider.meanOverBar{preferedCorrType},0,2);
semOverBar = stdOverBar/sqrt(nRoi);
timePlot = (1:5)'*timeUnit; % second
PlotXY_Juyue(timePlot,meanOverBar,'errorBarFlag',true,'sem',semOverBar,'limPreSetFlag',true,'maxValue',max(abs(meanOverBar)+2 * abs(semOverBar)));
xlabel('time [seconds]')
title([glider.nameStr{preferedCorrType}, sprintf('\naveraged over bars '),num2str(barUseAverage)]);
% plot that bar with error bar on that.
subplot(4,6,10:11);
meanOverTimeBar = mean(cell2mat(glider.meanOverTimeBar),2);
stdOverTimeBar = std(cell2mat(glider.meanOverTimeBar),0,2);
semOverTimeBar = stdOverTimeBar/sqrt(nRoi);

bar(1:4,meanOverTimeBar); hold on
errorbar(1:4,meanOverTimeBar,semOverTimeBar,'k.');
set(gca,'XTick',[1:nDxBank],'XTickLabel', glider.nameStr);
% plot the individual one...
subplotNumGlider = [13,14,15,16,17,18];
subplotNumMean = [19,20,21,22,23,24];

% the average is much smaller... 
A = mean(glider.meanOverTime,3);
maxValueBar = max(1.5 * abs(A(:)));
for qq = 1:1:nBar
    subplot(4,6,subplotNumGlider(qq));
    % get the average for individual bars.
    meanOverBar =  mean( glider.value{preferedCorrType,qq},2);
    stdOverBar = std( glider.value{preferedCorrType,qq},0,2);
    semOverBar = stdOverBar/sqrt(nRoi);
    timePlot = (1:5)'*timeUnit; % second
    PlotXY_Juyue(timePlot,meanOverBar,'errorBarFlag',true,'sem',semOverBar,'limPreSetFlag',true,'maxValue',max(abs(meanOverBar)+abs(semOverBar)));
    xlabel('time [seconds]')
    title([glider.nameStr{preferedCorrType},sprintf('\nbar %d', barUse(qq))]);

    % bar plot for each bar.
    subplot(4,6,subplotNumMean(qq));
    meanOverTimeBar = mean( glider.meanOverTime(:,qq,:),3);
    stdOverTimeBar = std(glider.meanOverTime(:,qq,:),0,3);
    semOverTimeBar = stdOverTimeBar/sqrt(nRoi);
    
    bar(1:4,meanOverTimeBar); hold on
    errorbar(1:4,meanOverTimeBar,semOverTimeBar,'k.');
    set(gca,'XTick',[1:nDxBank],'XTickLabel', glider.nameStr);
    set(gca,'YLim',[-maxValueBar,maxValueBar]);

end


