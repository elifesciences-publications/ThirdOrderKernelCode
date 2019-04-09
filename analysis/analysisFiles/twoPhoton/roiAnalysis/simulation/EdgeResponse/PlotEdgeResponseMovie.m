function PlotEdgeResponseMovie(roi,resp,respLinear,stim)
[T,nMultiBars,~] = size(stim);



firstFilter = roi.filterInfo.firstKernelOriginal;
barCenter = roi.filterInfo.barCenter;
firstFilter = roiAnalysis_AverageFirstKernel_AlignOneFilter(firstFilter,barCenter);
% only the center 5 will remain?
X = flipud(firstFilter);
[maxTau,~] = size(X);


filMap = cell(T,1); % would be T with different size? at first, it is really small...
alph = cell(T,1);
for tt = maxTau:1:T
    jj = tt - maxTau + 1;
    ind = jj:1:tt;
    filMap{tt} = zeros(T,nMultiBars);
    filMap{tt}(ind,:) = X;
    alph{tt} = false(T,nMultiBars);
    alph{tt}(ind,:) = true;
    %     MakeFigure;
    %     h = imagesc(filMap{tt});
    %     set(h,'AlphaData',0.8 * alph{tt});
    %
end
maxVal = max(abs(X(:)));
if maxVal == 0;
    maxVal = 1;
end
titleStr = {'left light','right light','left dark','right dark'};
for qq = 1:1:4
    % colormap is extreamly important.
    MakeFigure;
    subplot(1,2,1);
    imagesc(stim(:,:,qq));
    set(gca,'Clim',[-maxVal maxVal]);
    title(titleStr{qq});
    xLim = [0,T];
    for tt = maxTau:1:T
        subplot(1,2,1);
        hold on
        h = imagesc(filMap{tt});
        set(h,'AlphaData',0.8 * alph{tt});
        
        subplot(2,2,2);
        plot(respLinear(1:tt,qq));
        xlim(xLim);
        subplot(2,2,4)
        plot(resp(1:tt,qq));
        xlim(xLim);
        pause(0.1);
    end
end
