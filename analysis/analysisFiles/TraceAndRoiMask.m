 function analysis = TraceAndRoiMask(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
   % This function is meant to be used with ONE FLY! Otherwise it'll plot
   % tons upon tons of things
    flyEyes = [];
    epochsForSelectivity = {'' ''};
    timeShift = 0;
    duration = 2000;
    fps = 1;
    barToCenter = 2;
    % Can't instantiate this as empty because plenty of figures will have
    % empty names as the default
    figureName = 'omgIHopeNoFigureIsEverNamedThis';

    fprintf('Two plots this time\n');
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    epochNames = {params.epochName};
    % Gotta unwrap these because of how they're put in here
    flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
    
    if any(cellfun('isempty', flyResp))
        nonResponsiveFlies = cellfun('isempty', flyResp);
        fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
        flyResp(nonResponsiveFlies) = [];
        epochs(nonResponsiveFlies) = [];
        roiMask(nonResponsiveFlies) = [];
    else
        nonResponsiveFlies = [];
    end
    
    numFlies = length(flyResp);
    averagedROIs = cell(1,numFlies);
    
    if numFlies==0
        analysis = [];
        return
    end
    
    
    
    numROIs = zeros(1, numFlies);
    % run the algorithm for each fly
        for selEpochs = 1:size(epochsForSelectivity, 1)
            dsiAll = [];
            selIndAll = [];
            zValsAll = [];
            indsIntAll = true(0);
            roiChoicesAll = true(0);
    for ff = 1:numFlies
        %% Get epoch start times/durations for SelectResponsiveRois function
        numEpochs = length(params);
        epochList = epochs{ff}(:, 1);
        epochStartTimes = cell(numEpochs,1);
        epochDurations = cell(numEpochs,1);
        
        for ee = 1:length(epochStartTimes)
            chosenEpochs = [0; epochList==ee; 0];
            startTimes = find(diff(chosenEpochs)==1);
            endTimes = find(diff(chosenEpochs)==-1)-1;
            
            epochStartTimes{ee} = startTimes;
            epochDurations{ee} = endTimes-startTimes+1;
        end
        
            
        selIndThresh = 0.4;
        primCorrIndThresh = 0.4;
        dirSelThresh = 0.4;
        pValThresh = .05;
            [~,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectResponsiveRois(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectivity(selEpochs, :), params,varargin{:}, 'dataRate', dataRate);
            
            valuesCell = struct2cell(valueStruct);
            valuesMatrix = cat(1, valuesCell{:});
            
            primCorr = valueStruct.primaryCorrelations;
            valueStruct.secondaryCorrelations;
            dsi = valueStruct.dirSel;
            selInd = valueStruct.selectivityIndex;
            pVals = valueStruct.pVals;
            zVals = norminv(pVals);
            
            roiChoices = selInd>selIndThresh  & primCorr>primCorrIndThresh & dsi>dirSelThresh;% & pVals<(pValThresh/size(flyResp{ff}, 2));
            
            epochNumPrimDir = ConvertEpochNameToIndex(params, epochsForSelectivity{selEpochs, 1});
            epochNumSecDir = ConvertEpochNameToIndex(params, epochsForSelectivity{selEpochs, 2});
            epochNumPrim = ConvertEpochNameToIndex(params, epochsForSelectivity{selEpochs, 3});
            epochNumSec = ConvertEpochNameToIndex(params, epochsForSelectivity{selEpochs, 4});
            dirPrimResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices), epochStartTimes, epochDurations, epochNumPrimDir);
            dirSecResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices), epochStartTimes, epochDurations, epochNumSecDir);
            dirPrimResp = cat(1, dirPrimResp{:});
            dirSecResp = cat(1, dirSecResp{:});
            primaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices),epochStartTimes,epochDurations,epochNumPrim);
            secondaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices),epochStartTimes,epochDurations,epochNumSec);
            primaryResponse = cat(1, primaryResponse{:});
            secondaryResponse = cat(1, secondaryResponse{:});
            
            numRois = sum(roiChoices);
            roiNumber = find(roiChoices);
            
            [~, bestRoiInd] = max(selInd(roiChoices));
            
            
            roiMasksHere = roiMask{1};
            if length(roiMasksHere)>1
                warning('more than one mask!')
                continue
            else
                roiMaskHere = roiMasksHere{1};
            end
            
            roiChoiceInds = find(roiChoices);
            roiMaskChoices = false(size(roiMaskHere));
            roiMaskOutlines = cell(1, length(roiChoiceInds));
            for i = 1:length(roiChoiceInds)
                roiMaskChoices(roiMaskHere==roiChoiceInds(i)) = true;
                roiMaskOutlines(i) = bwboundaries(roiMaskChoices);
                roiMaskChoices(roiMaskHere==roiChoiceInds(i)) = false;
            end
            
            plotFigure = findobj('Type', 'Figure', 'Name', figureName);
            if isempty(plotFigure)
                plotFigure = MakeFigure;
                plotFigure.Name = figureName;
                newPlot = true;
            
                moviePath = fullfile(dataPath{ff},'alignedMovie.mat');
                movieData = load(moviePath);
                movieData = double(movieData.imgFrames_ch1);
                
                
                maskPath = fullfile(dataPath{ff},'movieMask.mat');
                movieMask = load(maskPath);
                movieMask = movieMask.windowMask;
                [top,left] = find(movieMask,1,'first');
                [bottom,right] = find(movieMask,1,'last');
                movieIn = movieData(top:bottom,left:right,:);
                
                clear('movieData');
                
                meanMovie = mean(movieIn, 3);
                
                subplot(2, 1, 1)
                imagesc(meanMovie); axis off; axis tight; axis equal;
                colormap gray; hold on;
            else
                newPlot = false;
                figure(plotFigure);
            end
            
            
            
            
            if any(strfind(figureType, 'T4'))
                currSbplot = subplot(2, 2, 3);
                lineColorPrimary = [0 0 1];
                lineColorSecondary = [1 0 0];
            elseif any(strfind(figureType, 'T5'))
                currSbplot = subplot(2, 2, 4);
                lineColorPrimary = [1 0 0];
                lineColorSecondary = [0 0 1];
            else
                warning('Remember to label your figureType with T4 or T5 so I know what colors to plot the ROIs as!');
                continue
            end
            subplot(2, 1, 1);hold on
            for i = 1:length(roiMaskOutlines)
                lnOut = plot(roiMaskOutlines{i}(:, 2), roiMaskOutlines{i}(:, 1));
                lnOut.Color = lineColorPrimary;
                if i == bestRoiInd && isempty(currSbplot.Tag)
                    lnOut.LineWidth = 3;
                end
            end
            
            
                axes(currSbplot)
            if any(strfind(figureType, 'T4'))
                if ~strcmp(currSbplot.Tag, 'T4')
                    primRespLn = plot(primaryResponse(:, bestRoiInd));hold on
                    primRespLn.Color = lineColorPrimary;
                    secRespLn = plot(secondaryResponse(:, bestRoiInd));hold off
                    secRespLn.Color = lineColorSecondary;
                    %                     text(0, 0, [num2str(pVals(roiNumber(pltInd))) ' - ' num2str(pValThresh/size(flyResp{ff}, 2))], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                    title(sprintf('%d - %d', ff, roiNumber(bestRoiInd)));
                    
                    legend([epochsForSelectivity{selEpochs, [1 3]}], [epochsForSelectivity{selEpochs, [1 4]}]);
                    currSbplot.Tag = 'T4';
                end
            elseif any(strfind(figureType, 'T5'))
                if ~strcmp(currSbplot.Tag, 'T5')
                    primRespLn = plot(primaryResponse(:, bestRoiInd));hold on
                    primRespLn.Color = lineColorPrimary;
                    secRespLn = plot(secondaryResponse(:, bestRoiInd));hold off
                    secRespLn.Color = lineColorSecondary;
                    %                     text(0, 0, [num2str(pVals(roiNumber(pltInd))) ' - ' num2str(pValThresh/size(flyResp{ff}, 2))], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                    title(sprintf('%d - %d', ff, roiNumber(bestRoiInd)));
                    
                    legend([epochsForSelectivity{selEpochs, [1 3]}], [epochsForSelectivity{selEpochs, [1 4]}]);
                    currSbplot.Tag = 'T5';
                end
            end
                
            
%             MakeFigure;
%             title('Distributions')
%             scatter(selInd,dsi);
%             xlabel(['Edge Selectivity' epochsForSelectivity{selEpochs, 1} ' - ' epochsForSelectivity{selEpochs, 2}]);
%             ylabel(['Direction Selectivity' epochsForSelectivity{selEpochs, 3} ' - ' epochsForSelectivity{selEpochs, 4}]);
            dsiAll = [dsiAll dsi];
            selIndAll = [selIndAll selInd];
            zValsAll = [zValsAll zVals];
            indsIntAll = [indsIntAll pVals < (pValThresh/size(flyResp{ff}, 2))];
            roiChoicesAll = [roiChoicesAll roiChoices];
    end
    set(findall(plotFigure,'-property','FontName'),'FontName', 'Ebrima')
    end
    analysis = [];
    
    % Eyes not being empty is an indication that we have to shuffle around
    % epochs to account for progressive/regressive stimulus differences
    % (direction-wise) in different eyes
%     if ~isempty(flyEyes)
%         flyEyes(nonResponsiveFlies) = [];
%         rightEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'R'));
%         leftEpochs = cellfun(@(foundInds) ~isempty(foundInds) && foundInds(1)==1, strfind(epochNames, 'L'));
%         % We're gonna do this in a left-dominated world, so left eyes
%         % don't have to be touched.
%         for i = 1:length(flyEyes)
%             if strfind('right', lower(flyEyes{i}))
%                 tempAvg = averagedROIs{i};
%                 tempNoTimeAvg = noTimeAveragedRois{i};
%                 if ~isempty(tempAvg)
%                     averagedROIs{i}(rightEpochs) = tempAvg(leftEpochs);
%                     averagedROIs{i}(leftEpochs) = tempAvg(rightEpochs);
%                     noTimeAveragedRois{i}(rightEpochs) = tempNoTimeAvg(leftEpochs);
%                     noTimeAveragedRois{i}(leftEpochs) = tempNoTimeAvg(rightEpochs);
%                 end
%             end
%         end
%     end
    
    %% convert from snipMat to matrix wtih averaged flies
%     averagedFlies = ReduceDimension(averagedROIs,'flies',@nanmean);
%     averagedFliesSem = ReduceDimension(averagedROIs,'flies',@NanSem);
%     
%     
%     respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
%     respMatSep = SeparateTraces(respMat,numSep,''); % separate every numSnips epochs into a new trace to plot
%     respMatPlot = permute(respMatSep,[3 7 6 1 2 4 5]);
% %     respMatPlot = squish(respMatSepPerm); % remove all nonsingleton dimensions
% 
%     respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
%     respMatSemSep = SeparateTraces(respMatSem,numSep,''); % separate every numSnips epochs into a new trace to plot
%     respMatSemPlot = permute(respMatSemSep,[3 7 6 1 2 4 5]);
% %     respMatSemPlot = squish(respMatSemPerm); % remove all nonsingleton dimensions
%     
%     analysis.respMatPlot = respMatPlot;
%     analysis.respMatSemPlot = respMatSemPlot;
%     
%     %% convert from snipMat to matrix wtih individual flies
% 
%     respMatInd = SnipMatToMatrix(averagedROIs); % turn snipMat into a matrix
%     respMatIndSep = SeparateTraces(respMatInd,numSep,''); % separate every numSnips epochs into a new trace to plot
%     respMatIndPlot = squish(respMatIndSep); % remove all nonsingleton dimensions
%     
%     analysis.respMatIndPlot = respMatIndPlot;
    
%     %% Average fly time traces
%     noTimeAveragedFlies = ReduceDimension(noTimeAveragedRois,'flies',@nanmean);
%     noTimeAveragedFliesSem = ReduceDimension(noTimeAveragedRois,'flies',@NanSem);
%     
%     respMatNoTime = SnipMatToMatrix(noTimeAveragedFlies); % turn snipMat into a matrix
%     respMatNoTimeSep =  SeparateTraces(respMatNoTime,numSep,''); % turn snipMat into a matrix
%     respMatNoTimePlot = permute(respMatNoTimeSep,[1 3 6 7 2 4 5]); % magic permutations
%     
%     respMatNoTimeSem = SnipMatToMatrix(noTimeAveragedFliesSem); % turn snipMat into a matrix
%     respMatNoTimeSepSem =  SeparateTraces(respMatNoTimeSem,numSep,''); % turn snipMat into a matrix
%     respMatNoTimeSemPlot = permute(respMatNoTimeSepSem,[1 3 6 7 2 4 5]); % magic permutations
%     
    
   

end
