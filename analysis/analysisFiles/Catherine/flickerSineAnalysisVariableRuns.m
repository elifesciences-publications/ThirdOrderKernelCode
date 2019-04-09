function Z = flickerSineAnalysisVariableRuns(Z)

%% must run Z = tp_plotROITraces(Z) and Z = triggeredResponseAnalysis(Z) first

% eventually might want to know what eye was recorded from
%                 connDb = connectToDatabase;
%                 tableNames = tables(connDb);
%                 tableNames = tableNames(:, 1);
%                 tableNames(strcmp(tableNames, 'analysisRun')) = [];
%                 tableOfInterest = tableNames{randi([1, length(tableNames)])};
%                 
%                 tableFetch = exec(connDb, sprintf('select * from %s', tableOfInterest));
%                 tableRow = fetch(tableFetch, 1);
%                 columnData = attr(tableRow);
%                 columnNames = {columnData.fieldName};
%                 %flyData = fetch(connDb, sprintf('select * from fly where relativePath = "%s"', Z.params.pathName));
%                 flyData = fetch(connDb, sprintf('select * from fly'));


    %% compute mean response to each instance of gray interleave (to subtract
    %% from sine and flicker responses)
    %% epoch 13 is interleave
    %% order of sortedMeanResponses is 0 R, 0 R, 0.1 R, 0.1 R, 0.2 R, etc. (order listed in param file)

    mkdir('plots');
    interleaveEpoch = 13;
    numRuns = 3;
    epochLength = 5;
    rows = 10*numRuns;
    % subtract added time after trigger
    %cols = size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_13, 2)-60*Z.params.timeAfterTrigger;
    cols = 300;
    responses = zeros(rows, cols);
    b = {strcat('Z.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(interleaveEpoch))};  
    b = eval(b{1});
    b = b(:, 1:size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_13,2), :);
    for i = 1:rows
        responses(i, :) = nanmean(b(i,1:300,:),3);
    end   

    % average over last 2.5 seconds
    averagingResponses = responses(:, 150:end);
    meanResponses = mean(averagingResponses,2);
    sortedMeanResponses = zeros(size(meanResponses,1), 1);

    % determine order of epochs
    epochOrder = Z.sortedEpochs;
    interleaves = find(strcmp(Z.sortedEpochs, 'Gray Interleave'));
    sortedIndices = [];

    % put mean responses in order
    for i = interleaveEpoch+1:size(Z.stimulus.params,2)
        for j = 1:numRuns
            indices = find(strcmp(epochOrder, Z.stimulus.params(i).epochName))-interleaves(1);
            sortedIndices(end+1) = indices(j); % first, second, etc. instances of epoch
        end
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
    
    probeEpochs = interleaveEpoch-1;
    numEpochs = length(fieldnames(Z.triggeredResponseAnalysis.triggeredIntensities))-probeEpochs-1;

    epochNames = {'0, right', '0.1, right', '0.2, right', '0.5, right', '1, right', '0, left', '0.1, left', '0.2, left', '0.5, left', '1, left'};
    m = 1;

    % total responses by epoch
    flickerdata = zeros(numEpochs*numRuns, 3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2));
    currentRow = 1;
    figure('name', strcat('Total Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    n = 1;
    for i = (probeEpochs+2):length(fieldnames(Z.triggeredResponseAnalysis.triggeredIntensities))
        b = {strcat('Z.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(i))};  
        b = eval(b{1});
        c = {strcat('Z.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(interleaveEpoch))};
        c = eval(c{1});
         for j = 1:6:6*(numRuns-1)+1
             k = nanmean(b(j+1,:,:),3);
             flickerdata(currentRow, :) = cat(2,nanmean(c(renumberedIndices(n),1:size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2),:),3),nanmean(b(j,:,:),3),nanmean(b(j+5,:,:),3));
             currentRow = currentRow+1;
             n = n+1;
         end
        subplot(numRuns,10, m)
        plot(flickerdata(currentRow-3,:));
        flickerdata(currentRow-3, :) = flickerdata(currentRow-3,:);
        axis([0 700 -0.3 0.55])
        title(epochNames{m});
        subplot(numRuns,10,m+10)

        plot(flickerdata(currentRow-2,:));
        flickerdata(currentRow-2, :) = flickerdata(currentRow-2,:);
        axis([0 700 -0.3 0.55])
        subplot(numRuns,10,m+20)
        plot(flickerdata(currentRow-1, :));
        flickerdata(currentRow-1,:) = flickerdata(currentRow-1,:);
        axis([0 700 -0.3 0.55])
        title(epochNames{m});
        m = m+1;
    end
    
    saveas(gcf, ['plots', filesep, strcat('Total Responses', Z.params.epochsForSelectivity{1})], 'fig');

    
    %% plot all responses sequentially, without background subtraction
    subplot(2,1,1)
    figure('name', strcat('Sequential Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    %subplot(2,1,1)
    times = 0:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)*10*numRuns;
    k = 0;
    colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
    j = 1;
    usedIndices = zeros(1, 10);
    for i = 1:size(flickerdata,1)
        if i <=10
            plot(times(1+k:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+k), flickerdata(find(renumberedIndices == i),:), 'Color', colors(j, :));
        elseif i > 10 & i <= 20
            currentInstance = find(renumberedIndices == i);
            colorIndex = find(usedIndices == currentInstance - 1);
            plot(times(1+k:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+k), flickerdata(find(renumberedIndices == i),:), 'Color', colors(colorIndex, :));
        else
           currentInstance = find(renumberedIndices == i);
            colorIndex = find(usedIndices == currentInstance - 2);
            plot(times(1+k:3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+k), flickerdata(find(renumberedIndices == i),:), 'Color', colors(colorIndex, :)); 
        end
        
        hold on
        usedIndices(1, i) = find(renumberedIndices == i);
        k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
        j = j+1;
        if j == 11
            j = 1;
        end
        if j == 21
            j = 1;
        end
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Frame Number');
    ylabel('dF/F');
    title('Sequential Responses to Stimulus');
    
    saveas(gcf, ['plots', filesep, strcat('Sequential Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    % line plot of average response to sine wave over time
    %figure('name', strcat('Average Response to Sine Wave', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    figure;
    subplot(2,1,1)
    k = 0;
    %colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
    j = 1;
    p = 26;
    usedIndices = zeros(1, 10);
    numPoints = size(flickerdata(1,2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end),2);
    for i = 1:size(flickerdata,1)
        if i <=10
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:(end-ceil(numPoints/2)))) - meanResponses(i), 'MarkerEdgeColor',color);
        elseif i > 10 & i <= 20
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            currentInstance = find(renumberedIndices == i);
            %colorIndex = find(usedIndices == currentInstance - 1);
            scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:(end-ceil(numPoints/2)))) - meanResponses(i), 'MarkerEdgeColor',color);
        else
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
           currentInstance = find(renumberedIndices == i);
           %colorIndex = find(usedIndices == currentInstance - 2);
           scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:(end-ceil(numPoints/2)))) - meanResponses(i), 'MarkerEdgeColor',color); 
        end
        
        hold on
        usedIndices(1, i) = find(renumberedIndices == i);
        k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
        j = j+1;
        if j == 11
            j = 1;
        end
        if j == 21
            j = 1;
        end
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Epoch');
    ylabel('dF/F');
    title('Average response to First Half Of Sine Wave');
    %saveas(gcf, ['plots', filesep, strcat('Average Response First Half of Sine Wave', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
        % line plot of average response to sine wave over time
    %figure('name', strcat('Average Response to Sine Wave', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    subplot(2,1,2)
    k = 0;
    %colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
    j = 1;
    p = 26;
    usedIndices = zeros(1, 10);
    for i = 1:size(flickerdata,1)
        if i <=10
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1+floor(numPoints/2):end)) - meanResponses(i), 'MarkerEdgeColor',color);
        elseif i > 10 & i <= 20
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            currentInstance = find(renumberedIndices == i);
            %colorIndex = find(usedIndices == currentInstance - 1);
            scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1+floor(numPoints/2):end)) - meanResponses(i), 'MarkerEdgeColor',color);
        else
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
           currentInstance = find(renumberedIndices == i);
           %colorIndex = find(usedIndices == currentInstance - 2);
           scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1+floor(numPoints/2):end)) - meanResponses(i), 'MarkerEdgeColor',color); 
        end
        
        hold on
        usedIndices(1, i) = find(renumberedIndices == i);
        k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
        j = j+1;
        if j == 11
            j = 1;
        end
        if j == 21
            j = 1;
        end
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Epoch');
    ylabel('dF/F');
    title('Average response to Second Half of Sine Wave');
    saveas(gcf, ['plots', filesep, strcat('Average Response Half of Sine Wave', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    
    % line plot of average response to sine wave over time
    %figure('name', strcat('Average Response to Sine Wave', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    figure;
    subplot(2,1,1)
    k = 0;
    %colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
    j = 1;
    p = 26;
    usedIndices = zeros(1, 10);
    for i = 1:size(flickerdata,1)
        if i <=10
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end)) - meanResponses(i), 'MarkerEdgeColor',color);
        elseif i > 10 & i <= 20
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            currentInstance = find(renumberedIndices == i);
            %colorIndex = find(usedIndices == currentInstance - 1);
            scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end)) - meanResponses(i), 'MarkerEdgeColor',color);
        else
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
           currentInstance = find(renumberedIndices == i);
           %colorIndex = find(usedIndices == currentInstance - 2);
           scatter(i, mean(flickerdata(find(renumberedIndices == i),2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end)) - meanResponses(i), 'MarkerEdgeColor',color); 
        end
        
        hold on
        usedIndices(1, i) = find(renumberedIndices == i);
        k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
        j = j+1;
        if j == 11
            j = 1;
        end
        if j == 21
            j = 1;
        end
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Epoch');
    ylabel('dF/F');
    title('Average response to Sine Wave');
    saveas(gcf, ['plots', filesep, strcat('Average Response over Time', ' ', Z.params.epochsForSelectivity{1})], 'fig');
   
     
    % plot average displacement (based on Z.grab.alignmentData) during the
    % epoch containing each sine wave.
    avgdisplacementEpoch = zeros(10*numRuns, 1);
    j = 1;
    for i = 14:23
        for k = 1:3
            a = strcat('Z.params.trigger_inds.epoch_', num2str(i), '.bounds(1,', num2str(k), ')');
            b = strcat('Z.params.trigger_inds.epoch_', num2str(i), '.bounds(2,', num2str(k), ')');
            % round lower bound up, round upper bound down
            c = ceil(eval(a));
            d = floor(eval(b));
            avgdisplacementEpoch(j, 1) = mean(Z.sqDisps(ceil((c+d)/2):d));
            j = j+1;
        end
    end
        % line plot of average displacement during each epoch
   % figure('name', strcat('Average Displacement During Epoch', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
   subplot(2,1,2)
   %subplot(2,1,2)
    k = 0;
    %colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
    j = 1;
    p = 26;
    usedIndices = zeros(1, 10);
    %avgdisplacementEpoch
    for i = 1:size(renumberedIndices,1)
        if i <=10
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            scatter(i, avgdisplacementEpoch(find(renumberedIndices == i)), 'MarkerEdgeColor',color);
        elseif i > 10 & i <= 20
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
            currentInstance = find(renumberedIndices == i);
            %colorIndex = find(usedIndices == currentInstance - 1);
            scatter(i, avgdisplacementEpoch(find(renumberedIndices == i)), 'MarkerEdgeColor',color);
        else
            if strcmp(Z.sortedEpochs{p}(1), 'R')
                color = 'b';
                p = p+2;
            else
                color = 'r';
                p = p+2;
            end
           currentInstance = find(renumberedIndices == i);
           %colorIndex = find(usedIndices == currentInstance - 2);
           scatter(i, avgdisplacementEpoch(find(renumberedIndices == i)), 'MarkerEdgeColor',color); 
        end
        
        hold on
        usedIndices(1, i) = find(renumberedIndices == i);
        k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
        j = j+1;
        if j == 11
            j = 1;
        end
        if j == 21
            j = 1;
        end
    end
    %legend(Z.sortedEpochs(26:2:end))
    xlabel('Epoch');
    ylabel('x^{2}+y^{2} (pixels^{2})');
    title('Average Displacement During Sine Wave');
            % line plot of average displacement during each epoch
   % figure('name', strcat('Average Displacement During Epoch', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
       % plot average displacement (based on Z.grab.alignmentData) during the
    % epoch containing each sine wave.
%     avgdisplacementFlicker = zeros(10*numRuns, 1);
%     j = 1;
%     for i = 14:23
%         for k = 1:3
%             a = strcat('Z.params.trigger_inds.epoch_', num2str(i), '.bounds(1,', num2str(k), ')');
%             b = strcat('Z.params.trigger_inds.epoch_', num2str(i), '.bounds(2,', num2str(k), ')');
%             % round lower bound up, round upper bound down
%             c = ceil(eval(a));
%             d = floor(eval(b));
%             Z.sqDisps(c:d);
%             avgdisplacementFlicker(j, 1) = mean(Z.sqDisps(c:floor((c+d)/2)));
%             j = j+1;
%         end
%     end
%    subplot(3,1,3)
%     k = 0;
%     %colors = [128 0 0; 240 128 128; 218 165 32; 127 255 0; 0 250 154; 0 255 255; 100 149 237; 0 0 255; 153 50 204; 112 128 154]/255;
%     j = 1;
%     p = 26;
%     usedIndices = zeros(1, 10);
%     %avgdisplacementFlicker
%     for i = 1:size(renumberedIndices,1)
%         if i <=10
%             if strcmp(Z.sortedEpochs{p}(1), 'R')
%                 color = 'b';
%                 p = p+2;
%             else
%                 color = 'r';
%                 p = p+2;
%             end
%             scatter(i, avgdisplacementFlicker(find(renumberedIndices == i)), 'MarkerEdgeColor',color);
%         elseif i > 10 & i <= 20
%             if strcmp(Z.sortedEpochs{p}(1), 'R')
%                 color = 'b';
%                 p = p+2;
%             else
%                 color = 'r';
%                 p = p+2;
%             end
%             currentInstance = find(renumberedIndices == i);
%             %colorIndex = find(usedIndices == currentInstance - 1);
%             scatter(i, avgdisplacementFlicker(find(renumberedIndices == i)), 'MarkerEdgeColor',color);
%         else
%             if strcmp(Z.sortedEpochs{p}(1), 'R')
%                 color = 'b';
%                 p = p+2;
%             else
%                 color = 'r';
%                 p = p+2;
%             end
%            currentInstance = find(renumberedIndices == i);
%            %colorIndex = find(usedIndices == currentInstance - 2);
%            scatter(i, avgdisplacementFlicker(find(renumberedIndices == i)), 'MarkerEdgeColor',color); 
%         end
%         
%         hold on
%         usedIndices(1, i) = find(renumberedIndices == i);
%         k = k+3*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2);
%         j = j+1;
%         if j == 11
%             j = 1;
%         end
%         if j == 21
%             j = 1;
%         end
%     end
%     %legend(Z.sortedEpochs(26:2:end))
%     xlabel('Epoch');
%     ylabel('x^{2}+y^{2}');
%     title('Average Displacement During Flicker');
    saveas(gcf, ['plots', filesep, strcat('Average Response and Displacement over Time', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
   figure('name', strcat('Sine Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    % sine responses by epoch
    currentRow = 4;
    for m = 1:numEpochs
        subplot(numRuns,10,m)
        plot(flickerdata(currentRow-3, 2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end));
        title(epochNames{m});
        ylabel('dF/F')
        xlabel('Contrast')
        subplot(numRuns,10,m+10)
        plot(flickerdata(currentRow-2,2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end));
        title(epochNames{m});
        ylabel('dF/F')
        xlabel('Contrast')
        subplot(numRuns,10,m+20)
        plot(flickerdata(currentRow-1,2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end));
        title(epochNames{m});
        ylabel('dF/F')
        xlabel('Contrast')
        m = m+1;
        currentRow = currentRow+numRuns;
    end

    saveas(gcf, ['plots', filesep, strcat('Sine Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    Z.flickerdata = flickerdata;
    
        % flicker responses by epoch
    figure('name', strcat('Flicker Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    currentRow = 4;
    for m = 1:numEpochs
        subplot(numRuns,10,m)
        plot(flickerdata(currentRow-3, size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)));
        axis([0 325 -0.2 0.35]);
        ylabel('dF/F')
        xlabel('Contrast')
        title(epochNames{m});
        subplot(numRuns,10,m+10)
        plot(flickerdata(currentRow-2,size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)));
        axis([0 325 -0.2 0.35]);
        ylabel('dF/F')
        xlabel('Contrast')
        title(epochNames{m});
        subplot(numRuns,10,m+20)
        plot(flickerdata(currentRow-1,size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)));
        axis([0 325 -0.2 0.35]);
        ylabel('dF/F')
        xlabel('Contrast')
        title(epochNames{m});
        m = m+1;
        currentRow = currentRow+3;
    end

    saveas(gcf, ['plots', filesep, strcat('Flicker Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    %% make line plot of mean responses to sine wave and flicker portion of stimulus, subtracting mean response to gray 
    %% interleave portion

    sineResponses = flickerdata(:, 2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end);
    meanSineResponses = zeros(numEpochs*3, 1);
    sineTimes = (1:302)/5;
    for i = 1:length(meanSineResponses)
        meanSineResponses(i) = mean(sineResponses(i, :));
    end
    
    ymin = min(min(meanSineResponses));
    ymax = max(max(meanSineResponses));
    values = zeros(numRuns, 5);
    figure('name', strcat('Mean Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    subplot(2,1, 1)
    plot([0 0.1 0.2 0.5 1], meanSineResponses(16:3:end)-sortedMeanResponses(16:numRuns:end), '-.');
    values(1, :) = meanSineResponses(16:3:end)-sortedMeanResponses(16:numRuns:end);
    hold on
    plot([0 0.1 0.2 0.5 1], meanSineResponses(17:3:end)-sortedMeanResponses(17:numRuns:end), '-.');
    values(2,:) = meanSineResponses(17:3:end)-sortedMeanResponses(17:numRuns:end);
    plot([0 0.1 0.2 0.5 1], meanSineResponses(18:3:end)-sortedMeanResponses(18:numRuns:end), '-.');
    values(3,:) = meanSineResponses(18:3:end)-sortedMeanResponses(18:numRuns:end);
    axis([0 1 ymin-0.1 ymax+0.1]);
    plot([0 0.1 0.2 0.5 1], mean(values));
    ylabel('dF/F');
    xlabel('Contrast of Flicker');
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Sine Responses');
    else
        title('Anti-Preferred Direction Sine Responses')
    end
    
    subplot(2, 1, 2)
    values2 = zeros(numRuns,5);
    hold on
    for j = 1:numRuns
        plot([0 0.1 0.2 0.5 1], meanSineResponses(j:numRuns:epochLength*numRuns)-sortedMeanResponses(j:numRuns:epochLength*numRuns), '-.');
    end
    values2(1, :) = meanSineResponses(1:numRuns:15)-sortedMeanResponses(1:numRuns:15);
    values2(2, :) = meanSineResponses(2:numRuns:15)-sortedMeanResponses(2:numRuns:15);
    values2(3, :) = meanSineResponses(3:numRuns:15)-sortedMeanResponses(3:numRuns:15);
    plot([0 0.1 0.2 0.5 1], mean(values2));
    axis([0 1 ymin-0.1 ymax+0.1]);
        ylabel('dF/F');
    xlabel('Contrast of Flicker');
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Sine Responses');
    else
        title('Preferred Direction Sine Responses')
    end
   

%     flickerResponses = flickerdata(:, 302:604);
%     meanFlickerResponses = zeros(numEpochs*numRuns, 1);
%     flickerTimes = (1:302)/5;
% 
%     for i = 1:length(meanFlickerResponses)
%         meanFlickerResponses(i) = mean(flickerResponses(i, :)); 
%     end
%    
%     ymin2 = min(min(meanFlickerResponses));
%     ymax2 = max(max(meanFlickerResponses));
%     subplot(2,2,3)
%     hold on
%     for j = 1:numRuns
%         plot([0 0.1 0.2 0.5 1], meanFlickerResponses(j+epochLength*numRuns:numRuns:end)-sortedMeanResponses(j+epochLength*numRuns:numRuns:end), '-.');
%     end
%     hold off
%     axis([0 1 ymin2-0.1 ymax2+0.1]);
%     if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
%         title('Preferred Direction Flicker Responses');
%     else
%         title('Anti-Preferred Direction Flicker Responses')
%     end
%     
%     subplot(2,2,4)
%     hold on
%     for j = 1:numRuns
%         plot([0 0.1 0.2 0.5 1], meanFlickerResponses(j:numRuns:epochLength*numRuns)-sortedMeanResponses(j:numRuns:epochLength*numRuns), '-.');
%     end
%     hold off
%     axis([0 1 ymin2-0.1 ymax2+0.1]);
%     if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
%         title('Anti-Preferred Direction Flicker Responses');
%     else
%         title('Preferred Direction Flicker Responses')
%     end
    saveas(gcf, ['plots', filesep, strcat('Total Mean Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    
    %% plot all responses on top of each other, with background subtraction
    figure('name', strcat('All Responses', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));
    for i = 1:size(flickerdata,1)
        plot(flickerdata(find(renumberedIndices == i), :)-sortedMeanResponses(i));
        hold on
    end
    legend(Z.sortedEpochs(26:2:end))
    xlabel('Frame Number')
   % saveas(gcf, ['plots', filesep, strcat('All Responses', ' ', Z.params.epochsForSelectivity{1})], 'fig');
    
    % interleave frames are 1:301, flicker frames are 302:604, sine frames
    % are 605:667
    
    
    %% plot average responses without background subtraction
    
    % average responses to sine portion of stimulus
    sineResponses = flickerdata(:, 2*size(Z.triggeredResponseAnalysis.triggeredIntensities.epoch_14,2)+1:end);
    meanSineResponses = zeros(numEpochs*numRuns, 1);
    sineTimes = (1:302)/5;

    for i = 1:length(meanSineResponses)
        meanSineResponses(i) = mean(sineResponses(i, :)); 
    end

    ymin = min(min(meanSineResponses));
    ymax = max(max(meanSineResponses));
    
    figure('name', strcat('Mean Responses without Subtraction', ' ', Z.params.epochsForSelectivity{1}, ' ', Z.params.pathName));

    subplot(2, 2, 1)
    hold on
    for j = 1:numRuns
        plot([0 0.1 0.2 0.5 1], meanSineResponses(5*numRuns+j:numRuns:end), '-.');
    end
    hold off
    axis([0 1 ymin-0.1 ymax+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Sine Responses');
    else
        title('Anti-Preferred Direction Sine Responses')
    end
    
    subplot(2, 2, 2)
    hold on
    for j = 1:numRuns
        plot([0 0.1 0.2 0.5 1], meanSineResponses(j:numRuns:epochLength*numRuns), '-.');
    end
    hold off
    axis([0 1 ymin-0.1 ymax+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Sine Responses');
    else
        title('Preferred Direction Sine Responses')
    end

    % average responses to flicker portion of stimulus
    flickerResponses = flickerdata(:, 302:604);
    meanFlickerResponses = zeros(numEpochs*numRuns, 1);
    flickerTimes = (1:302)/5;

    for i = 1:length(meanFlickerResponses)
        meanFlickerResponses(i) = mean(flickerResponses(i, :)); 
    end
   
    ymin2 = min(min(meanFlickerResponses));
    ymax2 = max(max(meanFlickerResponses));
    
    subplot(2, 2, 3)
    hold on
    for j = 1:numRuns
        plot([0 0.1 0.2 0.5 1], meanFlickerResponses(epochLength*numRuns+j:numRuns:end), '-.');
    end
    hold off
    axis([0 1 ymin2-0.1 ymax2+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Preferred Direction Flicker Responses');
    else
        title('Anti-Preferred Direction Flicker Responses')
    end
    
    subplot(2, 2, 4)
    hold on
    for j = 1:numRuns
        plot([0 0.1 0.2 0.5 1], meanFlickerResponses(j:numRuns:epochLength*numRuns), '-.');
    end
    hold off
    axis([0 1 ymin2-0.1 ymax2+0.1]);
    if strcmp(Z.params.epochsForSelectivity{1}, 'Square Left')
        title('Anti-Preferred Direction Flicker Responses');
    else
        title('Preferred Direction Flicker Responses')
    end

    % plot average response to sine wave by ROI
    % plot average shift during sine wave presentation
    % different color for L vs R sine wave averages
    % plot coefficient of variation for each ROI
    % plot average pixel shift during each sine wave presentation
    
end