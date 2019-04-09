function analysis = kernelAnalysis_60HzStim13HzResp(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)

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
 filterLength = 60;
 for ff = 1:numFlies
     %trunc = find(epochs{ff}(:, 1) >= interleaveEpoch);
     
     
     
%      kernels = [];
%      for a = 1:size(flyResp{ff}, 2)
%          stimMatrix = [];
%          tResp = [];
%          stimTrace = stim{ff}(:, 15);
%          stimTrace = stimTrace-mean(stimTrace);
%          for ii = 1:size(roiStimIndexes{ff}(:, a))
%              startingStimIndex = roiStimIndexes{ff}(ii, a);
%              if startingStimIndex >121 && ~isnan(flyResp{ff}(ii, a))
%                  stimMatrix = [stimMatrix; stimTrace((startingStimIndex):-2:(startingStimIndex-119))']; 
%                  tResp = [tResp; flyResp{ff}(ii, a)];
%              end
%          end
% %          tdsStim = stim{ff}(roiStimIndexes{ff}(find(~isnan(roiStimIndexes{ff}(:, a))), a), 15);
%          tResp = tResp-nanmean(tResp);
%          k = stimMatrix\tResp;
% %          MakeFigure;plot(k)
% %          [k, rhat, rho, S, R] = extractKernel_60HzStim13HzResp(tdsStim, tResp, 120, 0, []);
%          kernels = [kernels k];
% end
     kernels = [];
     for a = 1:size(flyResp{ff}, 2)
         
         tResp = [];
         stimTrace = stim{ff}(:, 15);
         stimTrace = stimTrace-mean(stimTrace);
         respStart = 1;
         
         stimStartIndAll = roiStimIndexes{ff}(:, a)-(filterLength*2-1);
         stimStartInd = stimStartIndAll(stimStartIndAll>0);
         stimEndIndAll = roiStimIndexes{ff}(:, a);
         stimEndInd = stimEndIndAll(stimStartIndAll>0);
         stimMatrix = zeros(length(stimEndInd), filterLength);
         
         tResp = [flyResp{ff}(stimStartIndAll>0, a)];
         for ii = 1:length(stimEndInd)
             %startingStimIndex = roiStimIndexes{ff}(ii, a);
            stimMatrix(ii, :) = [stimTrace(stimEndInd(ii):-2:stimStartInd(ii))']; 
             
         end
         
%          tdsStim = stim{ff}(roiStimIndexes{ff}(find(~isnan(roiStimIndexes{ff}(:, a))), a), 15);
         tResp = tResp-nanmean(tResp);
         
         tResp = tResp(~isnan(tResp));
         stimMatrix = stimMatrix(~isnan(tResp),:);
         
         k = stimMatrix\tResp;
         %MakeFigure;plot(k)
%          [k, rhat, rho, S, R] = extractKernel_60HzStim13HzResp(tdsStim, tResp, 120, 0, []);
         kernels = [kernels k];
     end
    
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