function analysis = kernelAnalysisWithRepeats(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)

 % kernelAnalysis(timeByRoisInitial, epochList, roiRecordingCorrespondingStimulusPerFly, allStimulusBehaviorData, selectedRois)
 % timeByRoisInitial : responses by time
 % epochList : list of epoch numbers
 % roiRecordingCorrespondingStimulusPerFly : stimulus index at each time
 % allStimulusBehaviorData : contains what was in stimData.mat

 for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
 end

 
 %% to do: 
 % plot repeated segment
 % nonlinearity
 
 epochDuration = 5;
 repeatedStart = 45;
 repeatedDuration = 15; 
 
 kernelsPerSelection = [];
 lowContrastKernelsPerSelection = [];
 highContrastKernelsPerSelection = [];
 numFlies = length(flyResp);
 totROI = 0;
 filterLength = 60; %floor(2*dataRate);
 interpolateResponse = 0;
 
 for ff = 1:numFlies
     analysis.indFly{ff} = {};
     trunc = find(epochs{ff}(:, 1) >= interleaveEpoch);
     kernels = [];
     lowContrastKernels = [];
     highContrastKernels = [];
%      timeByRoisMatrix = preSelectionROIResponses{ff};
%      if ~isempty(selectedRois{ff})
%          timeByRoisMatrix = timeByRoisMatrix(:, selectedRois{ff});
%          currentAllStimBehaviorData = allStimulusBehaviorDataKernels{ff};
%          stimulusTrace = currentAllStimBehaviorData.StimulusData(:, 2);
%          stimulusTrace = stimulusTrace-mean(stimulusTrace);
%          frameNumbers = roiRecordingCorrespondingStimulusPerFly{ff};
%          frameNumbers = frameNumbers(:, selectedRois{ff});
%          frameNumbers(isnan(frameNumbers)) = 1;
%          
%          
         % extract kernel for the entire stimulus
         for a = 1:size(flyResp{ff}, 2)
             tResp = [];
             stimTrace = stim{ff}(:, 15);
             stimTrace = stimTrace-mean(stimTrace);
             respStart = 1;

             stimStartIndAll = roiStimIndexes{ff}(trunc, a)-(filterLength*2-1);
             stimStartInd = stimStartIndAll(stimStartIndAll>0);
             stimEndIndAll = roiStimIndexes{ff}(trunc, a);
             stimEndInd = stimEndIndAll(stimStartIndAll>0);
             stimMatrix = zeros(length(stimEndInd), filterLength);
             allResponseTrace = flyResp{ff}(trunc, a);
%              tResp = [flyResp{ff}(stimStartIndAll>0, a)];
             tResp = allResponseTrace(stimStartIndAll>0);
             for ii = 1:length(stimEndInd)
                 %startingStimIndex = roiStimIndexes{ff}(ii, a);
                stimMatrix(ii, :) = [stimTrace(stimEndInd(ii):-2:stimStartInd(ii))']; 

             end
    %              
 %           tdsStim = tdsStimTestTot(trunc);
%              currentResponseTrace = timeByRoisMatrix(:, a);
%              currentResponseTrace(isnan(currentResponseTrace)) = 0;
%              tdsStim =  stimulusTrace(frameNumbers(trunc, a));
%                 trunc = 1000;
                     tResp = tResp(~isnan(tResp));
               stimMatrix = stimMatrix(~isnan(tResp),:);
              %tdsStim = stimMatrix(trunc:end);
              %tResp = tResp(trunc:end);%currentResponseTrace(trunc);
             tdsStim = stimMatrix;
             %tResp = responses;
             [k, rhat, rho, S, R] = extractKernel_60HzStim13HzResp(tdsStim, tResp, filterLength, 0, []);
             kernels = [kernels k];
             
             %         figure;plot(k)

             %         figure;plot(k)
             %         figure;plot(rhat);hold on;plot(tResp)


         % extract kernel for high and low contrast segments
            % find the indices of the high and low contrast segments
            epochTrace = epochs{ff}(trunc, a);
            
            % (gives first frame number of each epoch)
            epochSwitches = [1; find(diff(epochTrace) ~= 0)+1];
            
            repeatStartIndex = (repeatedStart + epochDuration)/epochDuration;
            jumpBy = (repeatedDuration + repeatedStart)/(epochDuration);
            repeatRows = [];
            % find the indices of the repeated segments
            for rows = repeatStartIndex:jumpBy:length(epochSwitches)
                repeatRows(end+1:end+3) = [rows rows+1 rows+2];
            end
            
            repeatRowIndices = epochSwitches(repeatRows);
            nonRepeatedIndices = epochSwitches(~ismember(epochSwitches, repeatRowIndices));
            
            allRepeatedFrameNumbers = {};
            for kk = 1:3:length(repeatRowIndices)-3
                allRepeatedFrameNumbers{end+1} = [epochSwitches(repeatRows(kk)):epochSwitches(repeatRows(kk)+3)-1];
            end
            allRepeatedFrameNumbers = allRepeatedFrameNumbers;
            
%             figure;
%             hold on;
%             for m = 1:length(allRepeatedFrameNumbers)
%                 plot(tdsStim(allRepeatedFrameNumbers{m}));
%             end
%             
            lowContrastIndices = [];
            for jj = 3:2:length(epochSwitches)
                if ~ismember(epochSwitches(jj), repeatRowIndices)
%                     lowContrastIndices = [lowContrastIndices epochSwitches(jj)-floor(2*dataRate):epochSwitches(jj+1)-floor(2*dataRate)];
                      lowContrastIndices = [lowContrastIndices epochSwitches(jj):epochSwitches(jj+1)];
                end
            end
            lowContrastIndices = lowContrastIndices(lowContrastIndices>0);
            [klow, rhat, rho, Slow, Rlow] = extractKernel_60HzStim13HzResp(tdsStim, tResp, filterLength, 0, lowContrastIndices);
            
            highContrastIndices = [];
            for jj = 2:2:length(epochSwitches)-1
                if ~ismember(epochSwitches(jj),repeatRowIndices)
%                     highContrastIndices = [highContrastIndices epochSwitches(jj)-floor(2*dataRate):epochSwitches(jj+1)-floor(2*dataRate)];
                      highContrastIndices = [highContrastIndices epochSwitches(jj):epochSwitches(jj+1)];
                end
            end
            highContrastIndices = highContrastIndices(highContrastIndices>0);
            [khigh, rhat, rho, Shigh, Rhigh] = extractKernel_60HzStim13HzResp(tdsStim, tResp, filterLength, 0, highContrastIndices);
            
            lowContrastKernels = [lowContrastKernels klow];
            highContrastKernels = [highContrastKernels khigh];
            
         end
     
     if ~isempty(kernels)
         
         kernelPerFly = mean(kernels, 2);
         lowContrastKernelPerFly = mean(lowContrastKernels, 2);
         highContrastKernelPerFly = mean(highContrastKernels, 2);
         numROI = size(kernels,2);
         totROI = numROI + totROI; 

         if numROI == 1
             semPerFly = [];
             lowContrastSemPerFly = [];
             highContrastSemPerFly = [];
         else
            semPerFly = std(kernels')./sqrt(size(flyResp{ff}, 2)); 
            lowContrastSemPerFly = std(lowContrastKernels')./sqrt(size(flyResp{ff}, 2)); 
            highContrastSemPerFly = std(highContrastKernels')./sqrt(size(flyResp{ff}, 2));
         end
         frames =  0:5:length(kernelPerFly); 
         %time = frames/ (dataRate*2) ;
         time = round(frames*1000/30);
         x = [1:length(kernelPerFly);1:length(kernelPerFly);1:length(kernelPerFly)]';
         y = [lowContrastKernelPerFly, highContrastKernelPerFly, kernelPerFly];
         err = [lowContrastSemPerFly; highContrastSemPerFly; semPerFly]';
         MakeFigure, PlotXvsY(x, y,'error',err), hold on,
         PlotConstLine(0);set(gca, 'XTick',frames), set(gca, 'XTickLabel', time, 'FontSize', 25),xlabel('Time (s)'); ylabel(['Kernel for - ', num2str(numROI),' Rois'])
         title(['Fly Number ', num2str(ff), ' for ', epochsForSelection{ff}{1}])
        legend('Low Contrast', 'High Contrast', 'All');
        kernelsPerSelection(ff,:) = kernelPerFly;
        lowContrastKernelsPerSelection(ff, :) = lowContrastKernelPerFly;
        highContrastKernelsPerSelection(ff, :) = highContrastKernelPerFly;
        allKernelsPerFly{ff} = kernels;
        allLowContrastKernelsPerFly{ff} = lowContrastKernels;
        allHighContrastKernelsPerFly{ff} = highContrastKernels;
        analysis.indFly{ff}{end+1}.name = 'allKernels';
        analysis.indFly{ff}{end}.contents= allKernelsPerFly;
     end
 end
 if ~isempty(kernelsPerSelection)
     avgKernelPerSelection = mean(kernelsPerSelection, 1);
     avgLowContrastKernelPerSelection = mean(lowContrastKernelsPerSelection, 1);
     avgHighContrastKernelPerSelection = mean(highContrastKernelsPerSelection, 1);
     if size(kernelsPerSelection, 1) == 1
        semKernelPerSelection = [];
        lowContrastSemKernelPerSelection = [];
        highContrastSemKernelPerSelection = [];
     else
        semKernelPerSelection = std(kernelsPerSelection)./sqrt(numFlies);
        lowContrastSemKernelPerSelection = std(lowContrastKernelsPerSelection)./sqrt(numFlies);
        highContrastSemKernelPerSelection = std(highContrastKernelsPerSelection)./sqrt(numFlies);
     end
        
     MakeFigure;
     hold on;
     PlotXvsY([1:length(avgKernelPerSelection);1:length(avgKernelPerSelection);1:length(avgKernelPerSelection)]', [avgLowContrastKernelPerSelection;avgHighContrastKernelPerSelection; avgKernelPerSelection]','error',[lowContrastSemKernelPerSelection; highContrastSemKernelPerSelection; semKernelPerSelection]'); hold on;
     PlotConstLine(0);set(gca, 'XTick',frames), set(gca, 'XTickLabel', time, 'FontSize', 25),xlabel('Time (s)'); ylabel(['Avg kernel for - ', num2str(size(kernelsPerSelection, 1)),' Flies'])
     title([epochsForSelection{ff}{1}])
     legend('Low Contrast', 'High Contrast', 'All');
 else
     print('NO KERNELS FOR YOU')
 end
 
 %  for k = 1:size(kernels, 2)
%      figure;
%      plot(kernels(:, k))
%  end



end

