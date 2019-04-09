function Z = kernelScript(Z)
% (mostly written by Holly) 

%     b = Z.epoch3Data;
%     c = Z.epoch4Data;
%     d = Z.epoch3epoch4Data;
%     % epoch 3 = contrast 0.2
%     % epoch 4 = contrast 1
%     
%     % For only epoch 3 data:
%     newEpochIndsB = find(diff(b,1) > 1);
%     newEpochIndsB = [1; (newEpochIndsB + 1); (size(b,1)+1)];
%     for q = 1:length(newEpochIndsB)-1
%         cutB{q} = b(newEpochIndsB(q):newEpochIndsB(q+1)-1,:)
%     end
% 
%     maxTau = 60;
%     filtersB = zeros(60,length(cutB));
%     for q = 1:length(cutB)
%         thisStim = cutB{q}(:,3);
%         thisStim = thisStim - mean(thisStim);
%         thisResp = cutB{q}(:,4);
%         thisResp = thisResp - mean(thisResp);
%         filtersB(:,q) = oneD_filter( thisStim,thisResp,60);
%     end
%     meanFiltB = mean(filtersB,2);
%     figure('name', 'Epoch 3'); plot(meanFiltB); title('Epoch 3: Contrast 0.2');
%     
%     % For only epoch 4 data:
%     %%
%     newEpochIndsC = find(diff(c,1) > 1);
%     newEpochIndsC = [1; (newEpochIndsC + 1); (size(c,1)+1)];
%     for q = 1:length(newEpochIndsC)-1
%         cutC{q} = c(newEpochIndsC(q):newEpochIndsC(q+1)-1,:);
%     end
% 
%     maxTau = 60;
%     filtersC = zeros(60,length(cutC));
%     for q = 1:length(cutC)
%         thisStim = cutC{q}(:,3);
%         thisStim = thisStim - mean(thisStim);
%         thisResp = cutC{q}(:,4);
%         thisResp = thisResp - mean(thisResp);
%         filtersC(:,q) = oneD_filter(thisStim,thisResp,60);
%     end
%     meanFiltC = mean(filtersC,2);
%     figure('name', 'Epoch 4'); plot(meanFiltC); title('Epoch 4: Contrast 1');
% 
%     % all data
%     filtersD = zeros(60, 1);
%     thisStim = Z.epoch3epoch4Data(:,3);
%     thisStim = thisStim - mean(thisStim);
%     thisResp = Z.epoch3epoch4Data(:,4);
%     thisResp = thisResp-mean(thisResp);
%     filtersD(:,1) = oneD_filter(thisStim, thisResp, 60);
%     
%     meanFiltD = mean(filtersD,2);
%     figure('name', 'Entire Stimulus'); plot(meanFiltD); title('Entire Stimulus');
%     
%     % plot time trace of response
%         figure;
%         plot(Z.epoch3epoch4Data(:,1), Z.epoch3epoch4Data(:,4));
%         
%     % plot all traces on top of each other
%         figure;
%         hold on
%         j = 1;
%         for i = 1:48
%             plot(1:600, Z.epoch3epoch4Data(j:j+599,4));
%             j = j+600;
%         end
%         
        
        
    mkdir('plots');
    % all data
    filtersD = zeros(60, 1);
    thisStim = Z.stim(:, 1);
    thisStim = thisStim - mean(thisStim);
    thisResp = Z.meanResponses2(:, 1);
    thisResp = thisResp-mean(thisResp);
    filtersD(:,1) = oneD_filter(thisStim, thisResp, 60);
    
    meanFiltD = mean(filtersD,2);
    figure('name', 'Entire Stimulus'); plot(meanFiltD); title('Entire Stimulus');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Entire Stimulus Kernel'], 'fig');
    
    % all data, 120s kernel
    filtersD = zeros(120, 1);
    thisStim = Z.stim(:, 1);
    thisStim = thisStim - mean(thisStim);
    thisResp = Z.meanResponses2(:, 1);
    thisResp = thisResp-mean(thisResp);
    filtersD(:,1) = oneD_filter(thisStim, thisResp, 120);
    
    meanFiltD = mean(filtersD,2);
    figure('name', 'Entire Stimulus'); plot(meanFiltD); title('Entire Stimulus, 120s kernel');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Entire Stimulus Kernel, 120s'], 'fig');
    
    
    % For only epoch 3 data:
    f = Z.epoch3Data2;
    newEpochIndsF = find(diff(f,1) > 1);
    newEpochIndsF = [1; (newEpochIndsF + 1); (size(f,1)+1)]
    newEpochIndsF(end-2:end) = []
    for q = 1:length(newEpochIndsF)-1 
        newEpochIndsF(q);
        newEpochIndsF(q+1);
        q;
        cutF{q} = f(newEpochIndsF(q):newEpochIndsF(q+1)-1,:);
    end

    maxTau = 60;
    filtersF = zeros(60,length(cutF));
    for q = 1:length(cutF)
        thisStim = cutF{q}(:,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutF{q}(:,4);
        thisResp = thisResp - mean(thisResp);
        filtersF(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    meanFiltF = mean(filtersF,2);
    figure('name', 'Epoch 3'); plot(meanFiltF); title('Contrast 0.2');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Low Contrast Kernel'], 'fig');
    
    
    % For only epoch 3 data, 120s kernel:
    f = Z.epoch3Data2;
    newEpochIndsF = find(diff(f,1) > 1);
    newEpochIndsF = [1; (newEpochIndsF + 1); (size(f,1)+1)]
    newEpochIndsF(end-2:end) = []
    for q = 1:length(newEpochIndsF)-1 
        newEpochIndsF(q);
        newEpochIndsF(q+1);
        q;
        cutF{q} = f(newEpochIndsF(q):newEpochIndsF(q+1)-1,:);
    end

    maxTau = 60;
    filtersF = zeros(120,length(cutF));
    for q = 1:length(cutF)
        thisStim = cutF{q}(:,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutF{q}(:,4);
        thisResp = thisResp - mean(thisResp);
        filtersF(:,q) = oneD_filter( thisStim,thisResp,120);
    end
    meanFiltF = mean(filtersF,2);
    figure('name', 'Epoch 3'); plot(meanFiltF); title('Contrast 0.2, 120s kernel');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Low Contrast Kernel, 120s'], 'fig');
    
    % For only epoch 4 data:
    %%
    g = Z.epoch4Data2;
    newEpochIndsG = find(diff(g,1) > 1);
    size(newEpochIndsG);
    newEpochIndsG = [1; (newEpochIndsG + 1); (size(g,1)+1)];
    for q = 1:length(newEpochIndsG)-1
        q;
        newEpochIndsG(q+1)-1;
        size(g);
        cutG{q} = g(newEpochIndsG(q):newEpochIndsG(q+1)-1,:);
    end

    maxTau = 60;
    filtersG = zeros(60,length(cutG));
    for q = 1:length(cutG)
        thisStim = cutG{q}(:,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutG{q}(:,4);
        thisResp = thisResp - mean(thisResp);
        filtersG(:,q) = oneD_filter(thisStim,thisResp,60);
    end
    meanFiltG = mean(filtersG,2);
    figure('name', 'Epoch 4'); plot(meanFiltG); title('Contrast 0.9');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'High Contrast Kernel'], 'fig');
    
    % For only epoch 4 data, 120s kernel:
    g = Z.epoch4Data2;
    newEpochIndsG = find(diff(g,1) > 1);
    size(newEpochIndsG);
    newEpochIndsG = [1; (newEpochIndsG + 1); (size(g,1)+1)];
    for q = 1:length(newEpochIndsG)-1
        q;
        newEpochIndsG(q+1)-1;
        size(g);
        cutG{q} = g(newEpochIndsG(q):newEpochIndsG(q+1)-1,:);
    end

    maxTau = 60;
    filtersG = zeros(120,length(cutG));
    for q = 1:length(cutG)
        thisStim = cutG{q}(:,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutG{q}(:,4);
        thisResp = thisResp - mean(thisResp);
        filtersG(:,q) = oneD_filter(thisStim,thisResp,120);
    end
    meanFiltG = mean(filtersG,2);
    figure('name', 'Epoch 4'); plot(meanFiltG); title('Contrast 0.9, 120s kernel');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'High Contrast Kernel, 120s'], 'fig');
    
    
    % plot all traces on top of each other
    figure;
    hold on
    j = 1;
    orderedValues = zeros(48,600);
    for i = 1:48
        plot(1:600, Z.epoch3epoch4Data2(j:j+599,4));
        orderedValues(i, :) = Z.epoch3epoch4Data2(j:j+599, 4);
        j = j+600;
    end
    xlabel('Frame Number')
    ylabel('Response dF/F');
    title('Responses to 10 second intervals');
    saveas(gcf, ['plots', filesep, '10s interval responses'], 'fig');
    
   % plot mean trace
   figure;
   plot(1:600, mean(orderedValues));
   title('Mean Response');
   xlabel('Frame Number');
   ylabel('Response dF/F');
   saveas(gcf, ['plots', filesep, 'Mean Response Trace'], 'fig');
   
   
    

% 
%     % simulated data
%     %%
%     randInput = randn([1e3 1]);
%     lpFun = @(x,tau) x.*exp(-x/tau) / tau^2;
%     filtAxis = [0:59] * 1000/60;
%     filtEg = lpFun(filtAxis,50);
%     resp = filter(filtEg,1,randInput);
%     filtEgExtract = oneD_filter(randInput,resp,60);
%     figure; plot(filtEgExtract);
%     hold all; plot(filtEg);
%     % figure; plot(xcorr(randInput))
end