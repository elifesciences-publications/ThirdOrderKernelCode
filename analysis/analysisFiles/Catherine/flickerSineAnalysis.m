function Z = flickerSineAnalysis(Z)

%% must run Z = tp_plotROITraces(Z) and Z = triggeredResponseAnalysis(Z) first

% graph axis in s
% direction axis labels

    %% compute mean response to each instance of gray interleave (to subtract
    %% from sine and flicker responses)
    %% epoch 13 is interleave
    %% order of sortedMeanResponses is 0 R, 0 R, 0.1 R, 0.1 R, 0.2 R, etc. (order listed in param file)

    mkdir('plots');
    rows= 20;
    % subtract added 4s after trigger
    cols = size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_13, 2)-60*Z.params.timeAfterTrigger;
    interleaveEpoch = 13;

    responses = zeros(rows, cols);
    b = {strcat('Z.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(interleaveEpoch))};  
    b = eval(b{1});
    b = b(:, 1:300, :);
    for i = 1:rows
        responses(i, :) = nanmean(b(i,:,:),3);
    end   

    % average over last 1.5 seconds
    averagingResponses = responses(:, 210:end);
    meanResponses = mean(averagingResponses,2);
    sortedMeanResponses = zeros(size(meanResponses,1), 1);

    % determine order of epochs
    epochOrder = Z.sortedEpochs;
    interleaves = find(strcmp(Z.sortedEpochs, 'Gray Interleave'));
    sortedIndices = [];

    % put mean responses in order
    for i = interleaveEpoch+1:size(Z.stimulus.params,2)
        indices = find(strcmp(epochOrder, Z.stimulus.params(i).epochName))-interleaves(1);
        sortedIndices(end+1) = indices(1); % first instance of epoch
        sortedIndices(end+1) = indices(2); % second instance of epoch    
    end

    [B, index] = sortrows(sortedIndices', 1);

    renumberedIndices = zeros(size(meanResponses,1), 1);
    for i = 1:length(index)
        renumberedIndices(index(i),1) = i;
    end

    for i = 1:length(index)
        sortedMeanResponses(i, 1) = meanResponses(renumberedIndices(i));
    end

    Z.params.sortedMeanResponses = sortedMeanResponses;
    
    probeEpochs = 12;
    numEpochs = length(fieldnames(Z.triggeredResponseAnalysis.triggeredIntensities))-probeEpochs-1;

    epochNames = {'0, right', '0.1, right', '0.2, right', '0.5, right', '1, right', '0, left', '0.1, left', '0.2, left', '0.5, left', '1, left'};
    m = 1;

    % total responses by epoch
    
    
    flickerdata = zeros(numEpochs*2, 3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2));
    currentRow = 1;
    figure('name', strcat('Total Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    n = 1;
    for i = (probeEpochs+2):length(fieldnames(Z.triggeredResponseAnalysis.triggeredIntensities))
        b = {strcat('Z.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(i))};  
        b = eval(b{1});
        c = {strcat('Z.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(interleaveEpoch))};
        c = eval(c{1});
%         for j = 1:6:7
%             k = nanmean(b(j+1,:,:),3);
%             flickerdata(currentRow, :) = cat(2,nanmean(c(renumberedIndices(n),:,:),3),nanmean(b(j,:,:),3),nanmean(b(j+1,:,:),3),nanmean(b(j+2,:,:),3),nanmean(b(j+3,:,:),3),nanmean(b(j+4,:,:),3), nanmean(b(j+5,:,:),3));
%             currentRow = currentRow+1;
%             n = n+1;
%         end
         for j = 1:6:7
             k = nanmean(b(j+1,:,:),3);
             flickerdata(currentRow, :) = cat(2,nanmean(c(renumberedIndices(n),1:size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2),:),3),nanmean(b(j,:,:),3),nanmean(b(j+5,:,:),3));
             currentRow = currentRow+1;
             n = n+1;
         end
        subplot(2,10, m)
        %plot(flickerdata(currentRow-2,:) - Z.params.sortedMeanResponses(m));
        plot(flickerdata(currentRow-2,:));
        %flickerdata(currentRow-2, :) = flickerdata(currentRow-2,:) - Z.params.sortedMeanResponses(m);
        flickerdata(currentRow-2, :) = flickerdata(currentRow-2,:);
        axis([0 700 -0.3 0.55])
        title(epochNames{m});
        subplot(2,10,m+10)
        %plot(flickerdata(currentRow-1,:) - Z.params.sortedMeanResponses(m+1));
        plot(flickerdata(currentRow-1,:));
        %flickerdata(currentRow-1, :) = flickerdata(currentRow-1,:) - Z.params.sortedMeanResponses(m+1);
        flickerdata(currentRow-1, :) = flickerdata(currentRow-1,:);
        axis([0 700 -0.3 0.55])
        title(epochNames{m});
        m = m+1;
    end
    
    saveas(gcf, ['plots', filesep, strcat('Total Responses', Z.params.epochsForSelectivity{1})], 'fig');
    % plot all responses sequenctially, without background subtraction
    figure('name', strcat('Sequential Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
%     times = 0:5/300:666*20;
%     k = 0;
%     size(flickerdata)
%     size(times(1:667))
%     for i = 1:size(flickerdata,1)
%         plot(times(1+k:667+k), flickerdata(find(renumberedIndices == i),:));
%         hold on
%         k = k+667;
%     end
    times = 0:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)*20;
    k = 0;
    colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
    j = 1;
    usedIndices = zeros(1, 10);
    for i = 1:size(flickerdata,1)
        if i <=10
            plot(times(1+k:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+k), flickerdata(find(renumberedIndices == i),:), 'Color', colors(j, :));
        else
            currentInstance = find(renumberedIndices == i);
            colorIndex = find(usedIndices == currentInstance - 1);
            plot(times(1+k:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+k), flickerdata(find(renumberedIndices == i),:), 'Color', colors(colorIndex, :));
        end
        hold on
        usedIndices(1, i) = find(renumberedIndices == i);
        k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
        j = j+1;
        if j > 10
            j = 1;
        end
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Frame Number');
    ylabel('dF/F');
    saveas(gcf, ['plots', filesep, strcat('Sequential Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    figure('name', strcat('Flicker Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));

    % flicker responses by epoch
    currentRow = 3;
    for m = 1:numEpochs
        subplot(2,10,m)
        plot(flickerdata(currentRow-2, size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)));
        axis([0 325 -0.2 0.35]);
        title(epochNames{m});
        subplot(2,10,m+10)
        plot(flickerdata(currentRow-1,size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)));
        axis([0 325 -0.2 0.35]);
        title(epochNames{m});
        m = m+1;
        currentRow = currentRow+2;
    end

    saveas(gcf, ['plots', filesep, strcat('Flicker Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
     figure('name', strcat('Sine Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    % sine responses by epoch
    currentRow = 3;
    for m = 1:numEpochs
        subplot(2,10,m)
        plot(flickerdata(currentRow-2, 2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end));
        title(epochNames{m});
        subplot(2,10,m+10)
        plot(flickerdata(currentRow-1,2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end));
        title(epochNames{m});
        m = m+1;
        currentRow = currentRow+2;
    end

    saveas(gcf, ['plots', filesep, strcat('Sine Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    Z.flickerdata = flickerdata;
    
    %% make line plot of mean responses to sine wave and flicker portion of stimulus, subtracting mean response to gray 
    %% interleave portion

    % integrate responses to sine wave portion of stimulus, exlcuding first
    % second
    %sineResponses = flickerdata(:, 306:end);
    sineResponses = flickerdata(:, 2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end);
    %integratedSineResponses = zeros(numEpochs*2, 1);
    meanSineResponses = zeros(numEpochs*2, 1);
    sineTimes = (1:302)/5;

    %for i = 1:length(integratedSineResponses)
     %   integratedSineResponses(i) = trapz(sineTimes, sineResponses(i, :)); 
    %end
    
    for i = 1:length(meanSineResponses)
        meanSineResponses(i) = mean(sineResponses(i, :));
    end
    
    %ymin = floor(min(min(integratedSineResponses)));
    %ymax = ceil(max(max(integratedSineResponses)));
    
    ymin = min(min(meanSineResponses));
    ymax = max(max(meanSineResponses));
    
    figure('name', strcat('Mean Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    
    subplot(2,2, 1)
    plot([0 0.1 0.2 0.5 1], meanSineResponses(11:2:end)-sortedMeanResponses(11:2:end), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanSineResponses(12:2:end)-sortedMeanResponses(12:2:end), '-.');
    %axis([0 1 -2.5 2.5])
    xlabel('Contrast')
    ylabel('dF/F')
    axis([0 1 ymin-0.1 ymax+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Sine Responses');
    else
        title('Anti-Preferred Direction Sine Responses')
    end
    
    subplot(2,2, 2)
    plot([0 0.1 0.2 0.5 1], meanSineResponses(1:2:10)-sortedMeanResponses(1:2:10), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanSineResponses(2:2:10)-sortedMeanResponses(2:2:10), '-.');
    %axis([0 1 -2.5 2.5])
    axis([0 1 ymin-0.1 ymax+0.1]);
    xlabel('Contrast')
    ylabel('dF/F')
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Sine Responses');
    else
        title('Preferred Direction Sine Responses')
    end
   

    % integrate responses to flicker portion of stimulus
    flickerResponses = flickerdata(:, 302:604);
    %integratedFlickerResponses = zeros(numEpochs*2, 1);
    meanFlickerResponses = zeros(numEpochs*2, 1);
    flickerTimes = (1:302)/5;

%     for i = 1:length(integratedFlickerResponses)
%         integratedFlickerResponses(i) = trapz(flickerTimes, flickerResponses(i, :)); 
%     end

    for i = 1:length(meanFlickerResponses)
        meanFlickerResponses(i) = mean(flickerResponses(i, :)); 
    end
   
    ymin2 = min(min(meanFlickerResponses));
    ymax2 = max(max(meanFlickerResponses));
    subplot(2,2,3)
    xlabel('Contrast')
    ylabel('dF/F')
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(11:2:end)-sortedMeanResponses(11:2:end), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(12:2:end)-sortedMeanResponses(12:2:end), '-.');
    %axis([0 1 -10 7]);
    axis([0 1 ymin2-0.1 ymax2+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Flicker Responses');
    else
        title('Anti-Preferred Direction Flicker Responses')
    end
    
    subplot(2,2,4)
    xlabel('Contrast')
    ylabel('dF/F')
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(1:2:10)-sortedMeanResponses(1:2:10), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(2:2:10)-sortedMeanResponses(2:2:10), '-.');
    %axis([0 1 -10 7]);
    axis([0 1 ymin2-0.1 ymax2+0.1]);
    % (non-preferred = right)
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Flicker Responses');
    else
        title('Preferred Direction Flicker Responses')
    end
    saveas(gcf, ['plots', filesep, strcat('Total Mean Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    % plot all responses on top of each other, with background subtraction
    figure('name', strcat('All Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    for i = 1:size(flickerdata,1)
        plot(flickerdata(find(renumberedIndices == i), :)-sortedMeanResponses(i));
        hold on
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Frame Number')
    ylabel('dF/F')
    saveas(gcf, ['plots', filesep, strcat('All Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    % interleave frames are 1:301, flicker frames are 302:604, sine frames
    % are 605:667
    
    
    %% plot without background subtraction
    % integrate responses to sine wave portion of stimulus, exlcuding first
    % second
    %sineResponses = flickerdata(:, 306:end);
    sineResponses = flickerdata(:, 2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end);
    %integratedSineResponses = zeros(numEpochs*2, 1);
    meanSineResponses = zeros(numEpochs*2, 1);
    sineTimes = (1:302)/5;

    %for i = 1:length(integratedSineResponses)
     %   integratedSineResponses(i) = trapz(sineTimes, sineResponses(i, :)); 
    %end
    
    for i = 1:length(meanSineResponses)
        meanSineResponses(i) = mean(sineResponses(i, :)); 
    end
    
    %ymin = floor(min(min(integratedSineResponses)));
    %ymax = ceil(max(max(integratedSineResponses)));
    
    ymin = min(min(meanSineResponses));
    ymax = max(max(meanSineResponses));
    
    figure('name', strcat('Mean Responses without Subtraction', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    
    subplot(2,2, 1)
    xlabel('Contrast')
    ylabel('dF/F')
    plot([0 0.1 0.2 0.5 1], meanSineResponses(11:2:end), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanSineResponses(12:2:end), '-.');
    %axis([0 1 -2.5 2.5])
    axis([0 1 ymin-0.1 ymax+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Sine Responses');
    else
        title('Anti-Preferred Direction Sine Responses')
    end
    
    subplot(2,2, 2)
    xlabel('Contrast')
    ylabel('dF/F')
    plot([0 0.1 0.2 0.5 1], meanSineResponses(1:2:10), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanSineResponses(2:2:10), '-.');
    %axis([0 1 -2.5 2.5])
    axis([0 1 ymin-0.1 ymax+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Sine Responses');
    else
        title('Preferred Direction Sine Responses')
    end
   

    % integrate responses to flicker portion of stimulus
    flickerResponses = flickerdata(:, 302:604);
    %integratedFlickerResponses = zeros(numEpochs*2, 1);
    meanFlickerResponses = zeros(numEpochs*2, 1);
    flickerTimes = (1:302)/5;

%     for i = 1:length(integratedFlickerResponses)
%         integratedFlickerResponses(i) = trapz(flickerTimes, flickerResponses(i, :)); 
%     end

    for i = 1:length(meanFlickerResponses)
        meanFlickerResponses(i) = mean(flickerResponses(i, :)); 
    end
   
    ymin2 = min(min(meanFlickerResponses));
    ymax2 = max(max(meanFlickerResponses));
    subplot(2,2,3)
    xlabel('Contrast')
    ylabel('dF/F')
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(11:2:end), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(12:2:end), '-.');
    %axis([0 1 -10 7]);
    axis([0 1 ymin2-0.1 ymax2+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Flicker Responses');
    else
        title('Anti-Preferred Direction Flicker Responses')
    end
    
    subplot(2,2,4)
    xlabel('Contrast')
    ylabel('dF/F')
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(1:2:10), '-.');
    hold on
    plot([0 0.1 0.2 0.5 1], meanFlickerResponses(2:2:10), '-.');
    %axis([0 1 -10 7]);
    axis([0 1 ymin2-0.1 ymax2+0.1]);
    % (non-preferred = right)
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Flicker Responses');
    else
        title('Preferred Direction Flicker Responses')
    end

end

