function ComparePowermapFigure(powerMap,xMeshLog,yMeshLog,bootedPowerMapsLinear,numPlot,figLabels)
    % the number of power maps to deal with
    numMaps = length(powerMap);
    mapMax = 0;
    fontSize = 12;
    
    for mm = 1:numMaps
        if max(max(abs(powerMap{mm}-1))) > mapMax
            mapMax = max(max(abs(powerMap{mm}-1)));
        end
    end
    
    mapLimits = [-mapMax mapMax]+1;
    [~,mapLimitsCentered] = GetMapLimits(powerMap);
    numContours = 20;
    breakOffset = 2.5;
    plotEveryX = 2;
    plotEveryY = 4;
    
    % these are the indicies for
    powerMapPlots = 1:ceil(numMaps*3/2);
    powerMapPlots = powerMapPlots(mod(powerMapPlots,3)~=0);
    
    % number of power maps that go into 1 figure. It is two, for pro/reg or
    % right/left
    powerMapsPerSubPlot = 2;
    % number adjacent is the number of power maps to put next to each other
    % currently two, control and experimental
    numAdjacent = numPlot(1);
    % number of summary figures, currently one to compare amplitude
    numSummary = numPlot(2);
    
    % number of vertical subplots
    subY = ceil(numMaps/(powerMapsPerSubPlot*numAdjacent));
    % number of horizontal subplots
    subX = numAdjacent+numSummary;
    totalPlots = subY*subX;
    mm = -1;
    
    
    if nargin < 6
        figLabels.y = cell(1,subY);
        figLabels.title = cell(1,subX);
    end
    
    MakeFigure;
    for ss = 1:totalPlots
        subplot(subY,subX,ss);
        
        % check whether this is a powermap plot or a summary plot
        if ~sum(mod(ss,(numAdjacent+1):subX)==0)
            % is a powermap plot
            % find the two powermaps to combine for this figure
            mm = mm+2;
            % plot progressive/right
            PlotPowerMap(powerMap{mm},mapLimitsCentered(:,1),numContours,-fliplr(xMeshLog{mm}(1,:)),yMeshLog{mm}(:,1),0);
            % plot regressive/left
            PlotPowerMap(fliplr(powerMap{mm+1}),mapLimitsCentered(:,1),numContours,xMeshLog{mm+1}(1,:),yMeshLog{mm+1}(:,1),0);
            
            caxis(mapLimits);
            if ss == 1
                xlabel(['SF (1/' char(176) ')']);
                % number of significant figures in the x label
                numSigFigsX = 2;
                
                % determine x labels
                tickX = [xMeshLog{mm}(1,1:plotEveryX:end) 0 -fliplr(xMeshLog{mm+1}(1,1:plotEveryX:end))];
                tickY = yMeshLog{mm}(1:plotEveryY:end,1);
                tickLabelX = [-fliplr(exp(xMeshLog{mm}(1,1:plotEveryX:end))) 0 exp(xMeshLog{mm}(1,1:plotEveryX:end))];
                tickLabelY = round(exp(tickY)*10)/10;
                
                % reduce the x label to significant figures
                tickLabelX = spa_sf(tickLabelX,numSigFigsX);
                % find the exponent
                labelMult = length(num2str(tickLabelX(end)))-(numSigFigsX-1)-2;
                tickLabelX = tickLabelX*10^labelMult;
                
                labelMultString = ['10^-^' num2str(labelMult)];
                
%                 a = annotation('textbox');
%                 a.String = labelMultString;
%                 a.Position = [1 0 0.1 0.1];
                
                ConfAxis('tickX',tickX,'tickY',tickY,'tickLabelX',tickLabelX,'tickLabelY',tickLabelY,'rotateLabels',0,'fontSize',fontSize);    
            else
                ConfAxis('tickX',tickX,'tickLabelX',' ','tickY',tickY,'tickLabelY',' ','fontSize',fontSize);
            end
            
            % put up the title and y labels
            if mod(ss-1,subX) == 0
                ylabel(figLabels.y{(ss-1)/subX+1});
            end
            
            if ss<=numAdjacent
                title(figLabels.title{ss});
            end
            
            % configure axis
            ax = gca; ax.LineWidth = 0.5;
            set(gca, 'Layer', 'top');
            
            % add break in axis
            breakxaxis([-breakOffset breakOffset]);
            if ss == 1
                t=text(1,0,labelMultString,'Units','normalized');
            end
        else
            % is a summary plot
            % we will compare the amplitude of fly response to
            % progressive/regressive between control and experimental
            % condition
            
            % find the two powermaps to compare
            compareList = (mm-(numAdjacent-1)*2):mm+1;
            % bootedPowerMapsLinear is a matrix such that size(x,1) = number
            % of sf/tf pairs measured, and size(x,2) = number of
            % bootstrapped maps
            mapsToCompare = bootedPowerMapsLinear(compareList);
            
            % the is the alpha which we consider significant
            alphaP = 0.01;
            
            % number of powermaps we will be comparing, i.e. 3 genotypes
            % and pro/reg = 6
            numToCompare = powerMapsPerSubPlot*numAdjacent;
            mapAmpDist = cell(numToCompare,1);
            mapAmpMean = zeros(numToCompare,1);
            mapAmpCI = cell(1,2);
            mapAmpCI{1} = zeros(numToCompare,1);
            mapAmpCI{2} = zeros(numToCompare,1);
            
            % store average amplitude, this is what we will plot
            for cc = 1:length(compareList)
                % get the distribution of amplitudes by averaging across
                % the first diminsion of maps to compare. After transpose
                % it is a vector containing the bootsrapped amplitudes of
                % powermaps
                mapAmpDist{cc} = mean(mapsToCompare{cc},1)';
                % mean of the map we are comparing
                mapAmpMean(cc) = mean(mapAmpDist{cc},1);
                % confidence interval for those means
                mapAmpCI{1,1}(cc,1) = prctile(mapAmpDist{cc},100*alphaP);
                mapAmpCI{1,2}(cc,1) = prctile(mapAmpDist{cc},100-100*alphaP);
            end
            
            % store the control minus expt
            controlMinusExptPro = zeros(size(mapsToCompare{1},2),numAdjacent-1);
            controlMinusExptReg = zeros(size(mapsToCompare{1},2),numAdjacent-1);
            
            % loop through the maps to compare and calculate the control -
            % experimental
            for cc = 1:numAdjacent-1
                controlMinusExptPro(:,cc) = mapAmpDist{2*cc-1}-mapAmpDist{2*numAdjacent-1};
                controlMinusExptReg(:,cc) = mapAmpDist{2*cc}-mapAmpDist{2*numAdjacent};
            end
            
            % p value for whether the control is greater than pro/reg
            ControlGreaterThanExptPro = (2*sum(controlMinusExptPro<0,1)'/size(controlMinusExptPro,1))<alphaP;
            ControlGreaterThanExptReg = (2*sum(controlMinusExptReg<0,1)'/size(controlMinusExptPro,1))<alphaP;

            % now we want to compare the difference between progressive and
            % regressive. Subtract response relative to control to show
            % that they are suppressed MORE in pro or reg
            proDiffMinusRegDiff = controlMinusExptPro - controlMinusExptReg;
            
            proReducedThanReg = (2*sum(proDiffMinusRegDiff<0,1)'/size(proDiffMinusRegDiff,1))<alphaP;
            regReducedThanPro = (2*sum(proDiffMinusRegDiff>0,1)'/size(proDiffMinusRegDiff,1))<alphaP;
            
            % this is 1 is pro significantly reduced relative to Reg, -1 if
            % Reg is significantly reduced relative to pro, and 0 if
            % neither is significant. For both Gal4 and shibire control.
            proReducedThanRegDiff = proReducedThanReg - regReducedThanPro;
            
            % skip first two colors
            barColors = lines(numAdjacent+2);
            barColors = barColors(3:end,:);
            barWidth = 0.25;
            plotOffsetX = [-0.5 0.5];
            plotOffsetY = [0 0.2];
            figureHandles = zeros(numAdjacent-1,1);
            
            hold on;
            for bb = 1:numAdjacent
                plotX = [bb bb+numAdjacent+1]';
                plotY = [mapAmpMean(2*bb) mapAmpMean(2*bb-1)]';
                plotCI = {mapAmpCI{1}([2*bb 2*bb-1]) mapAmpCI{2}([2*bb 2*bb-1])};

                figureHandles(bb) = bar(plotX,plotY,barWidth,'FaceColor',barColors(bb,:));
                PlotErrBars(plotX(:),plotY(:),[],plotCI,'.k');
            end
            hold off;

            xlim([plotOffsetX(1)+1 2*numAdjacent+1+plotOffsetX(2)]);
            ylim([plotOffsetY(1) max(abs(mapAmpCI{2}))+plotOffsetY(2)]);
                
            if ss == subX
                legend(figureHandles,{'GAL4 control' 'shibire control' 'GAL4>shibire'},'Location','none','Position',[0.8 0.8 0.1 0.1]);

                
                ConfAxis('tickX',[(numAdjacent+1)/2 (numAdjacent+1)/2+numAdjacent+1],'tickLabelX',{'regressive' 'progressive'},'tickY',0:0.2:2,'tickLabelY',0:0.2:2,'rotateLabels',0,'labelY','walking speed (fold change)','fontSize',fontSize);
            else
                ConfAxis('tickX',[(numAdjacent+1)/2 (numAdjacent+1)/2+numAdjacent+1],'tickLabelX',' ','tickY',0:0.2:2,'tickLabelY',' ','rotateLabels',0,'fontSize',fontSize);
            end
        end
    end
end