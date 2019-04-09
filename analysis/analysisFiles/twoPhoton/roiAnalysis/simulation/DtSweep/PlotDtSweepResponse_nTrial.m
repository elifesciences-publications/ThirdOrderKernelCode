function PlotDtSweepResponse_nTrial(respDt,roiType,roiName)
roiDirection = TypeDecipher(roiType,'d');
dtNumBank = respDt.dtNumBank;
respMean = respDt.respMean;
respStd = respDt.respStd;
nTrial = respDt.nTrial;


% there will be eight plot. first one would be the prefered direction, and + +, d = 1,1
if roiDirection == 1
    % prefered direction first.
    plotSequence.d = [1,2];
else
    % null direction second.
    plotSequence.d = [2,1];
end
titleStr = {'Phi','Reverse Phi'};
% put the limit of two plots the same. how do you do that?
findExtremValue = respStd + respMean;
yLimMin = min(findExtremValue(:));
yLimMin = yLimMin - 0.1 * abs(yLimMin);
yLimMax = max(findExtremValue(:));
yLimMax = yLimMax + 0.1 * abs(yLimMax);
% the max Value is not soly determined by respMean anymore....
for jj = 1:1:2
    subplot(2,1,jj);
    % plot the phi.
    
    preferD = squeeze(respMean(1,1,:,jj,plotSequence.d(1)));
    preferDStd = squeeze(respStd(1,1,:,jj,plotSequence.d(1)));
    dtNumBankShow = dtNumBank * 1/60 * 1000;
    PlotErrorPatch(dtNumBankShow,preferD',preferDStd',[1,0,0]);
%     plot(dtNumBank * 1/60 * 1000, preferD ,'r');
    set(gca,'YLim',[yLimMin,yLimMax]);
    xlabel('dt [ms]');
    ylabel([num2str(nTrial),'trials']);
    hold on
    
    nullD = squeeze(respMean(1,1,:,jj,plotSequence.d(2)));
    nullDStd = squeeze(respStd(1,1,:,jj,plotSequence.d(2)));
    dtNumBankShow = dtNumBank * 1/60 * 1000;
    PlotErrorPatch(dtNumBankShow,nullD',nullDStd',[0,0,1]);
%     
%     nullD = squeeze(respMean(1,1,:,jj,plotSequence.d(2)));
    set(gca,'Ylim',[yLimMin,yLimMax]);
    xlabel('dt [ms]')
    ylabel([num2str(nTrial),'trials']);
    legend('prefered direction','null direction');
    title(titleStr{jj});
%     if jj == 1
%         if roiType < 5
%             text(0.75, 0, roiName);
%         elseif roiType >=5 && roiType <= 20
%             text(0.75, 0, [roiName{1},roiName{2}]);
%         else
%             text(0.75, 0, ['Type is unclear']);
%         end
%     end
    hold off
end
hold off;
end
%%