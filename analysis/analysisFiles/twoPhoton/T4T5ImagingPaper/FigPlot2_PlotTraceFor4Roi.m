function FigPlot2_PlotTraceFor4Roi(roiData)
% try to plot all the four traces on top of each other....
verSpaceStep = 5; % the maxium response should be smaller than 10.
verSpace = (3:-1:0) * verSpaceStep;
[~,edgeTypeColorRGB,~] = FigPlot1ColorCode();

% do you want to aligned them so that they all look the same?
% that is a relatively hard work... you might have to kill some period to
% do the alignment...
nEdges = 4;


% trace = zeros(nT,nRoi);
% hopefully, they are all the same flies.
nRoi = length(roiData);
traceEdge = cell(nRoi,1);
nT = length(roiData{1}.typeInfo.trace{1,1});
trace = zeros(nT,nEdges,nRoi);
for ii = 1:1:nRoi
    traceThisRoi = roiData{ii}.typeInfo.trace;
    edgeType = roiData{ii}.typeInfo.edgeType;
    traceEdge{ii} = [traceThisRoi{1,edgeType};traceThisRoi{1,edgeType}];
    for qq = 1:1:4
        % it is possible that the trace is larger than 156.
        nTThis = length(traceThisRoi{1,qq});
        if nTThis > nT
            trace(:,qq,ii) = (traceThisRoi{1,qq}(1:nT) + traceThisRoi{2,qq}(1:nT))/2;         
        else
            trace(:,qq,ii) = (traceThisRoi{1,qq} + traceThisRoi{2,qq})/2;
        end
    end
end
relativeTimeMat_Edge = roiAnalysis_AverageFirstKernel_alignTrace_relativeTimeMat(traceEdge);
relativeTimeMat = relativeTimeMat_Edge;
relativeTime = roiAnalysis_AverageFirstKernel_fbestRelativeTime(relativeTimeMat);
relativeFirst = round(relativeTime(1,:));

shiftedTrace = zeros(nT,nEdges,nRoi);
% how do you plot several things together?
% padding zeros will be the easiest thing to do
% test again...
for ii = 1:1:nRoi
    xab = relativeFirst(ii);
    if ii == 1
        shiftedTrace(:,:,ii) = trace(:,:,ii);
        %         shiftedTrace{ii} = traceEdge{ii};
    else
        if xab > 0
            shiftN = abs(xab);
            shiftedTrace(:,:,ii) = cat(1,zeros(shiftN,nEdges),trace(1:end - shiftN,:,ii));
        elseif xab < 0
            shiftN = abs(xab);
            shiftedTrace(:,:,ii) = cat(1,trace(shiftN + 1:end,:,ii),zeros(shiftN,nEdges));
        else
            shiftedTrace(:,:,ii)= trace(:,:,ii);
        end
        
    end
end
% how do you make sure that they are the same scale?
PlotedTrace = zeros(nT,nEdges,nRoi);
for ii = 1:1:nRoi
    for qq = 1:1:4
        PlotedTrace(:,qq,ii) = verSpace(qq) +  shiftedTrace(:,qq,ii);
        %         A = verSpace(qq) +  shiftedTrace(:,qq,ii); % the trace ebcomes larger///
        plot(PlotedTrace(:,qq,ii),'color',edgeTypeColorRGB(qq,:));
        hold on
    end
end
xLabelStr = 'time [s]';
yLabelStr = ['\Delta','F/F'];
timeUnit = 1/13; % 60Hz,16.6 ms.
set(gca,'YLim',[-1,20]);
ax = gca;
timeTickLabel = strsplit(num2str(ax.XTick * timeUnit,2));
ax.XTickLabel = timeTickLabel;
xlabel(xLabelStr);
ylabel(yLabelStr);


% plot y axis.
hold off
end