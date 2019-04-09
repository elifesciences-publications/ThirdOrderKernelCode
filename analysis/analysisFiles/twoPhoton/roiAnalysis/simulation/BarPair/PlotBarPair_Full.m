function PlotBarPair_Full(respBP,roiType,roiName)
% to plot the barpair response, a lot of things need to be stored...

% response
% when does the first stimulus is turned on, and turned off.
% when does the second bar is turned on and turned off.
% how many bars are used. sometimes five, sometimes 20... dependent on the
% width of your bar... why do you average over space?? do not do that..
% use the response to prected the nBarUsel
resp = respBP.resp;
stimMat = respBP.stim;
phaseUse = 1:size(resp,3);
temp = find(stimMat(:,1,1,1,1) == 1);
firstOn = temp(1);
firstOff = temp(end);
temp = find(stimMat(:,2,1,1,1) == 1);
secondOn = temp(1);



roiDirection = TypeDecipher(roiType,'d');
% there will be eight plot. first one would be the prefered direction, and + +, d = 1,1
if roiDirection == 1
    % prefered direction first.
    plotSequence.d = [1,1,1,1,2,2,2,2,];
else
    % null direction second.
    plotSequence.d = [2,2,2,2,1,1,1,1,];
end
% ++, --, +-, -+
plotSequence.sign = [1,4,2,3,1,4,2,3];
subR = [1:4; 11:14; 21:24; 31:34; 7:10; 17:20; 27:30; 37:40];
titleStr = {'Preferred ++','Preferred --','Preferred +-','Preferred -+','Null ++','Null --','Null +-','Null -+'};

%%
% debug on whether I got the right plot here...
MakeFigure;
thisMaxVal = max(abs(resp(:)));
colormap_gen;
colormap(mymap);
for ii = 1:1:8
    
    subplot(4,10,subR(ii,:));
    
    A = squeeze(resp(:,1, phaseUse,plotSequence.sign(ii),plotSequence.d(ii)));
    A = A'; %A = fliplr(A); % time goes from left to right, phase goes fromup to down.
    imagesc(A);
    set(gca,'Clim',[-thisMaxVal thisMaxVal]);
    
    % draw a veertical line
    hold on
    plot(firstOn * ones(1,size(A,1)),1:size(A,1),'k--');
    plot(secondOn * ones(1,size(A,1)),1:size(A,1),'k--');
    plot(firstOff * ones(1,size(A,1)),1:size(A,1),'k.--');
    xlabel('Time (s)');
    ylabel('phase');
    %     title(['direction',num2str(dBank(plotSequence.d(ii))),' sign', num2str(signBank(plotSequence.sign(ii),:))]);
    title(titleStr(ii));
    % draw three lines... on set of the stimulus, off set, and
    set(gca,'XTick',[],'YTick',[]);
    
    if (ii == 1)
        if roiType < 5
            text(0.75, 0, roiName);
        elseif roiType >=5 && roiType <= 20
            text(0.75, 0, [roiName{1},roiName{2}]);
        else
            text(0.75, 0, ['Type is unclear']);
        end
    end
    % the A will be time, over 20 phase, do you want to keep all the phase?
    %
end
%%
barToCenter = 1; %%  for emilio, there is only eight phase, for me, there are 20 places... I have to change it...
% if it is right motion, I regCheck will be 1
if roiDirection == 1
    regCheck = 1; %% regressive or progressive.... to accommondate the prefered direction or null direction. prefered direction is always on the left...
elseif roiDirection == -1
    regCheck = 0;
end
barColors = [1 1 1; 0 0 0];
barColorOrderOne = [1 2 1 2];
barColorOrderTwo = [1 2 2 1];
% Plotting the actual bar alignment
if barToCenter == 0
    barShift = 0;
elseif barToCenter == 1;
    barShift = 1;
else
    barShift = -1;
end

ind = 1;
for i = 5:10:40
    if regCheck
        p1 = i+1;
        p2 = i;
    else
        p1 = i;
        p2 = i+1;
    end
    barsPlot = subplot(4, 10, p1);
    axis([0 0.45 -0.5 3.5])
    patch([0 0 0.45 0.45], [1.5 2.5 2.5 1.5], barColors(barColorOrderOne(ind), :))
    patch([0.15 0.15 0.45 0.45], [0.5 1.5 1.5 0.5], barColors(barColorOrderTwo(ind), :))
    
    barsPlot.Color = get(gcf,'color');
    barsPlot.YColor = get(gcf,'color');
    barsPlot.XTick = [0 0.15 0.45];
    barsPlot.XTickLabel = [0 0.15 0.45];
    xlabel('Time (s)');
    
    barsPlot = subplot(4, 10, p2);
    axis([0 0.45 -0.5 3.5])
    axis([0 0.45 -0.5 3.5])
    patch([0 0 0.45 0.45], [0.5 1.5 1.5 0.5] + barShift, barColors(barColorOrderOne(ind), :))
    patch([0.15 0.15 0.45 0.45], [1.5 2.5 2.5 1.5] + barShift, barColors(barColorOrderTwo(ind), :))
    
    ind = ind + 1;
    barsPlot.Color = get(gcf,'color');
    barsPlot.YColor = get(gcf,'color');
    barsPlot.XTick = [0 0.15 0.45];
    barsPlot.XTickLabel = [0 0.15 0.45];
    xlabel('Time (s)');
end
end