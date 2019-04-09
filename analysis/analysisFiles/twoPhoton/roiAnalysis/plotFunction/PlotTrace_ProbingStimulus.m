function PlotTrace_ProbingStimulus(alltrace, varargin)
% PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','titleStr',name,'colorBank',typeColorRGB);
% PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'colorBank',edgeTypeColorRGB);
% this function can be extremly complicated....too bad...
edgeTypesStrStim = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge','Square Left','Square Right','Square Up','Square Down'};
edgeTypesStrEye = {'Progressive Light','Regressive Light','Progressive Dark','Regressive Dark','Progressive','Regressive','Up','Down'};
[dirTypeColorRGB,edgeTypeColorRGB,~] = FigPlot1ColorCode();
traceToDraw = 'meanTrace'; % meanTrace
coordinates = 'eye'; % stim
whichProb = 'edge'; % it could be edge or square...

yLimPreSetFlag = 0;
yLimMinPreSet = 0;
yLimMaxPreSet = 0;
% axis,title,and legend.
legendLabel = []; % it could be ESI
legendValue = zeros(4,1);

% title
titleStr = [];

% XLabel,YLabel
xLabelStr = 'time [s]';
yLabelStr = ['\Delta','F/F'];
% XTick, YTick....
timeUnit = 1/13; % 60Hz,16.6 ms.
% alltrace = [];      % it should be a trace cell, 2 by 8.
colorBank = [edgeTypeColorRGB;dirTypeColorRGB];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


switch coordinates
    case 'stim'
        edgeTypes = edgeTypesStrStim;
    case 'eye'
        edgeTypes = edgeTypesStrEye;
end


% before plot the thing, set the y limit the same for all of them
if yLimPreSetFlag
    yLimMin = yLimMinPreSet;
    yLimMax = yLimMaxPreSet;
else
    traceTogether = [];
    for ii = 1:1:size(alltrace,1)
        for jj = 1:1:size(alltrace,2)
            traceTogether =  [traceTogether;alltrace{ii,jj}];
        end
    end
    
    yLimMin = min(traceTogether);
    yLimMax = max(traceTogether);
end

switch whichProb
    case 'edge'
        traceInd = [1:4];
    case 'square'
        traceInd = [5:8];
    case 'both' %% the both would be a little bit harder.... just try ! not very hard.% you could not draw both...soooo sad....
end

switch traceToDraw
    case 'individualTrace'
        legendStr = cell(8,1);
        for ii = 1:1:4  % evey time, only four..
            qq = traceInd(ii);
            % instead of ploting four pictures. just use colors to plot the
            % epoches, how do you remember the color?
            plot(alltrace{1,qq},'color',colorBank(qq,:));
            hold on
            plot(alltrace{2,qq},'color',colorBank(qq,:));
            set(gca,'Ylim',[yLimMin yLimMax]);
            %     title([edgeTypes{q},'r: ',num2str(cfRoi.CC.Value(r,q))]);
            legendStr{(ii-1) * 2 + 1} = [edgeTypes{qq}];
            if ~isempty(legendLabel)
                switch legendLabel
                    case 'corr'
                        legendStr{(ii-1) * 2 + 2} = ['r: ',num2str(legendValue(qq))];
                    case 'ESI'
                        legendStr{(ii-1) * 2 + 2} = ['ESI: ',num2str(legendValue(qq))];
                    case 'typeOnly'
                        legendStr{(ii-1) * 2 + 2} = ['r: ',num2str(0)];
                end
            end
            xlabel(xLabelStr);
            ylabel(yLabelStr);
            
            
        end
        ax = gca;
        timeTickLabel = strsplit(num2str(ax.XTick * timeUnit,2));
        ax.XTickLabel = timeTickLabel;
        
    case 'meanTrace'
        legendStr = cell(4,1);
        for ii = 1:1:4
            qq = traceInd(ii);
            plot((alltrace{1,qq}+alltrace{2,qq})/2,'color',colorBank(qq,:));
            hold on
            
            set(gca,'Ylim',[yLimMin yLimMax]);
            %     title([edgeTypes{q},'r: ',num2str(cfRoi.CC.Value(r,q))]);
            if ~isempty(legendLabel)
                switch legendLabel
                    case 'corr'
                        legendStr{ii} = [edgeTypes{ii},' r: ',num2str(legendValue(qq))];
                    case 'ESI'
                        legendStr{ii} = [edgeTypes{ii}, 'ESI: ',num2str(legendValue(qq))];
                    case 'typeOnly'
                        legendStr{ii} = edgeTypes{ii};
                end
            end
            
            xlabel(xLabelStr);
            ylabel(yLabelStr);
            
            
        end
        ax = gca;
        timeTickLabel = strsplit(num2str(ax.XTick * timeUnit,2));
        ax.XTickLabel = timeTickLabel;
end
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
if ~isempty(legendLabel)
    hLegend = legend(legendStr,'location','northwest');
end
title(titleStr)
end
