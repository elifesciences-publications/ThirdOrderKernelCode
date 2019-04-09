function PlotSquareWaveResponse(resp,respLinear,stim)
MakeFigure;

% the stimulus
suplotNumStim = [1,2];
titleStr = {'left moving','right moving'};
for qq = 1:1:2
    subplot(4,2,suplotNumStim(qq));
    imagesc(stim(:,:,qq));
    colorbar
    title(titleStr{qq})
end

% the linear response/.
suplotNumRespLinear = [3,4];
yLimMax = max(max(abs(respLinear(:)),abs(resp(:))));
for qq = 1:1:2
    subplot(4,2,suplotNumRespLinear(qq));
    plot(squeeze(respLinear(:,qq)));
    ylim([-yLimMax,yLimMax]);
end% end
%

suplotNumRespLinearHist = [5,6];
for qq = 1:1:2
    subplot(4,2,suplotNumRespLinearHist(qq));
    a = respLinear(:,qq);
    h = histogram(a(:));
    h.BinWidth = 0.05;
end


subpotNumResp = [7,8];
T = size(resp,1);
meanResp = mean(resp);
for qq = 1:1:2
    subplot(4,2,subpotNumResp(qq));
    plot(squeeze(resp(:,qq)));
    hold on   
    plot(1:T,ones(1,T) *meanResp(qq),'r');
    ylim([-yLimMax,yLimMax]);
end% end
end