function analysis = kernelAnalysis(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)

%kernelAnalysis(timeByRoisInitial, epochList, roiRecordingCorrespondingStimulusPerFly, allStimulusBehaviorData, selectedRois)
 % timeByRoisInitial : responses by time
 % epochList : list of epoch numbers
 % roiRecordingCorrespondingStimulusPerFly : stimulus index at each time
 % allStimulusBehaviorData : contains what was in stimData.mat

 for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
 end

 
 %%
kernelsPerSelection = [];
 numFlies = length(flyResp);
 totROI = 0;
 kernelLength = floor(2*dataRate);
 for ff = 1:numFlies
     %trunc = find(epochs{ff}(:, 1) >= interleaveEpoch);
     kernels = [];
%      timeByRoisMatrix = preSelectionROIResponses{ff};
%      if ~isempty(selectedRois{ff})
%          timeByRoisMatrix = timeByRoisMatrix(:, selectedRois{ff});
%          currentAllStimBehaviorData = allStimulusBehaviorDataKernels{ff};
%          stimulusTrace = currentAllStimBehaviorData.StimulusData(:, 2);
%          stimulusTrace = stimulusTrace-mean(stimulusTrace);
%          frameNumbers = roiRecordingCorrespondingStimulusPerFly{ff};
%          frameNumbers = frameNumbers(:, selectedRois{ff});
%          frameNumbers(isnan(frameNumbers)) = 1;
         for a = 1:size(flyResp{ff}, 2)
             tdsStim = stim{ff}(roiStimIndexes{ff}(find(~isnan(roiStimIndexes{ff}(:, a))), a), 15);
             tdsStim = tdsStim - mean(tdsStim);
%              currentResponseTrace = timeByRoisMatrix(:, a);
%              currentResponseTrace(isnan(currentResponseTrace)) = 0;
%              tdsStim =  stimulusTrace(frameNumbers(trunc, a));
             tResp = flyResp{ff}(find(~isnan(roiStimIndexes{ff}(:, a))), a);%currentResponseTrace(trunc);
             [k, rhat, rho, S, R] = extractKernel(tdsStim, tResp, kernelLength, 0, []);
             kernels = [kernels k];
             
             %         figure;plot(k)
             %         figure;plot(rhat);hold on;plot(tResp)
        end
%      end
     if ~isempty(kernels)
         
         kernelPerFly = mean(kernels, 2);
         numROI = size(kernels,2);
         totROI = numROI + totROI; 

         if numROI == 1
             semPerFly = [];
         else
            semPerFly = std(kernels')./sqrt(size(kernels,2)); 
         end
           frames =  0:5:length(kernelPerFly); 
         time = frames/ dataRate ;
         MakeFigure, PlotXvsY([1:length(kernelPerFly)]', [kernelPerFly],'error',semPerFly'), hold on,
         PlotConstLine(0);set(gca, 'XTick',frames), set(gca, 'XTickLabel', time, 'FontSize', 25),xlabel('Time (s)'); ylabel(['Kernel for - ', num2str(numROI),' Rois'])
        title(['Fly Number ', num2str(ff), ' for ', epochsForSelection{ff}{1}])

        kernelsPerSelection(ff,:) = kernelPerFly;
        allKernelsPerFly{ff} = kernels;
     end
 end
 if ~isempty(kernelsPerSelection)
     avgKernelPerSelection = mean(kernelsPerSelection, 1);
     if size(kernelsPerSelection, 1) == 1
        semKernelPerSelection = [];
     else
        semKernelPerSelection = std(kernelsPerSelection)./sqrt(numFlies);
     end
        
     MakeFigure, PlotXvsY([1:length(avgKernelPerSelection)]', [avgKernelPerSelection]','error',semKernelPerSelection'), hold on,
     PlotConstLine(0);set(gca, 'XTick',frames), set(gca, 'XTickLabel', time, 'FontSize', 25),xlabel('Time (s)'); ylabel(['Avg kernel for - ', num2str(size(kernelsPerSelection, 1)),' Flies'])
     title([epochsForSelection{ff}{1}])
 else
     print('NO KERNELS FOR YOU')
 end
 
 %  for k = 1:size(kernels, 2)
%      figure;
%      plot(kernels(:, k))
%  end
analysis.indFly = {allKernelsPerFly};

end

