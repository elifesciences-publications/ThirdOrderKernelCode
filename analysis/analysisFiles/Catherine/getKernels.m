function Z = getKernels(Z)

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
   figure;
   plot(1:28800, Z.stim(:, 1))
   title('stimulus')
   figure;
   plot(1:28800, Z.epoch3epoch4Data2(:, 4));
   title('responses')
    % without first second of epoch:
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
   
    
    
    % For only epoch 3 data, 120s kernel:
    f = Z.epoch3Data2;
    newEpochIndsF = find(diff(f,1) > 1);
    newEpochIndsF = [1; (newEpochIndsF + 1); (size(f,1)+1)];
    newEpochIndsF(end-2:end) = [];
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
    
    % Second 2 of epoch 3 data
    f2 = Z.epoch3Data2;
    newEpochIndsF2 = find(diff(f2,1) > 1);
    newEpochIndsF2 = [1; (newEpochIndsF2 + 1); (size(f2,1)+1)]
    newEpochIndsF2(end-2:end) = []
    for q = 1:length(newEpochIndsF2)-1 
        newEpochIndsF2(q);
        newEpochIndsF2(q+1);
        q;
        cutF2{q} = f2(newEpochIndsF2(q):newEpochIndsF2(q+1)-1,:);
    end

    maxTau = 60;
    filtersF2 = zeros(60,length(cutF2));
    for q = 1:length(cutF2)
        thisStim = cutF2{q}(1:120,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutF2{q}(1:120,4);
        thisResp = thisResp - mean(thisResp);
        filtersF2(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    a = cutF2{1}
    meanFiltF2 = mean(filtersF2,2);
    figure('name', 'Epoch 3'); plot(meanFiltF2); title('Contrast 0.2, Second 2');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Low Contrast Kernel, Second 2'], 'fig');
    
    % Second 3 of epoch 3 data
    f3 = Z.epoch3Data2;
    newEpochIndsF3 = find(diff(f3,1) > 1);
    newEpochIndsF3 = [1; (newEpochIndsF3 + 1); (size(f3,1)+1)]
    newEpochIndsF3(end-2:end) = []
    for q = 1:length(newEpochIndsF3)-1 
        newEpochIndsF3(q);
        newEpochIndsF3(q+1);
        q;
        cutF3{q} = f3(newEpochIndsF3(q):newEpochIndsF3(q+1)-1,:);
    end

    maxTau = 60;
    filtersF3 = zeros(60,length(cutF3));
    for q = 1:length(cutF3)
        thisStim = cutF3{q}(61:180,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutF3{q}(61:180,4);
        thisResp = thisResp - mean(thisResp);
        filtersF3(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    a = cutF3{1}
    meanFiltF3 = mean(filtersF3,2);
    figure('name', 'Epoch 3'); plot(meanFiltF3); title('Contrast 0.2, Second 3');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Low Contrast Kernel, Second 3'], 'fig');
    
    % Second 4 of epoch 3 data
    f4 = Z.epoch3Data2;
    newEpochIndsF4 = find(diff(f4,1) > 1);
    newEpochIndsF4 = [1; (newEpochIndsF4 + 1); (size(f4,1)+1)]
    newEpochIndsF4(end-2:end) = []
    for q = 1:length(newEpochIndsF4)-1 
        newEpochIndsF4(q);
        newEpochIndsF4(q+1);
        q;
        cutF4{q} = f4(newEpochIndsF4(q):newEpochIndsF4(q+1)-1,:);
    end

    maxTau = 60;
    filtersF4 = zeros(60,length(cutF4));
    for q = 1:length(cutF4)
        thisStim = cutF4{q}(121:240,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutF4{q}(121:240,4);
        thisResp = thisResp - mean(thisResp);
        filtersF4(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    a = cutF4{1};
    size(filtersF4)
    meanFiltF4 = mean(filtersF4,2);
    figure('name', 'Epoch 3'); plot(meanFiltF4); title('Contrast 0.2, Second 4');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Low Contrast Kernel, Second 4'], 'fig');
    
    % Second 5 of epoch 3 data
    f5 = Z.epoch3Data2;
    newEpochIndsF5 = find(diff(f5,1) > 1);
    newEpochIndsF5 = [1; (newEpochIndsF5 + 1); (size(f5,1)+1)]
    newEpochIndsF5(end-2:end) = []
    for q = 1:length(newEpochIndsF5)-1 
        newEpochIndsF5(q);
        newEpochIndsF5(q+1);
        q;
        cutF5{q} = f4(newEpochIndsF5(q):newEpochIndsF5(q+1)-1,:);
    end

    maxTau = 60;
    filtersF5 = zeros(60,length(cutF5));
    for q = 1:length(cutF5)
        thisStim = cutF5{q}(181:300,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutF5{q}(181:300,4);
        thisResp = thisResp - mean(thisResp);
        filtersF5(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    a = cutF5{1};
    size(filtersF5)
    meanFiltF5 = mean(filtersF5,2);
    figure('name', 'Epoch 3'); plot(meanFiltF5); title('Contrast 0.2, Second 5');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'Low Contrast Kernel, Second 5'], 'fig');
    
    
    
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
    
    % For only epoch 4 data:
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
    
    % Second 2 of epoch 4 data
    g2 = Z.epoch4Data2;
    newEpochIndsG2 = find(diff(g2,1) > 1);
    newEpochIndsG2 = [1; (newEpochIndsG2 + 1); (size(g2,1)+1)]
    newEpochIndsG2(end-2:end) = []
    for q = 1:length(newEpochIndsG2)-1 
        newEpochIndsG2(q);
        newEpochIndsG2(q+1);
        q;
        cutG2{q} = g2(newEpochIndsG2(q):newEpochIndsG2(q+1)-1,:);
    end

    maxTau = 60;
    filtersG2 = zeros(60,length(cutG2));
    for q = 1:length(cutG2)
        thisStim = cutG2{q}(1:120,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutG2{q}(1:120,4);
        thisResp = thisResp - mean(thisResp);
        filtersG2(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    meanFiltG2 = mean(filtersG2,2);
    figure('name', 'Epoch 4'); plot(meanFiltG2); title('Contrast 0.9, Second 2');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'High Contrast Kernel, Second 2'], 'fig');
    
    % Second 3 of epoch 4 data
    g3 = Z.epoch4Data2;
    newEpochIndsG3 = find(diff(g3,1) > 1);
    newEpochIndsG3 = [1; (newEpochIndsG3 + 1); (size(g3,1)+1)]
    newEpochIndsG3(end-2:end) = []
    for q = 1:length(newEpochIndsG3)-1 
        newEpochIndsG3(q);
        newEpochIndsG3(q+1);
        q;
        cutG3{q} = g3(newEpochIndsG3(q):newEpochIndsG3(q+1)-1,:);
    end

    size(cutG3{1})
    maxTau = 60;
    filtersG3 = zeros(60,length(cutG3));
    for q = 1:length(cutG3)
        thisStim = cutG3{q}(61:180,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutG3{q}(61:180,4);
        thisResp = thisResp - mean(thisResp);
        filtersG3(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    meanFiltG3 = mean(filtersG3,2);
    figure('name', 'Epoch 4'); plot(meanFiltG3); title('Contrast 0.9, Second 3');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'High Contrast Kernel, Second 3'], 'fig');
    
    % Second 4 of epoch 4 data
    g4 = Z.epoch4Data2;
    newEpochIndsG4 = find(diff(g4,1) > 1);
    newEpochIndsG4 = [1; (newEpochIndsG4 + 1); (size(g4,1)+1)]
    newEpochIndsG4(end-2:end) = []
    for q = 1:length(newEpochIndsG4)-1 
        newEpochIndsG4(q);
        newEpochIndsG4(q+1);
        q;
        cutG4{q} = g4(newEpochIndsG4(q):newEpochIndsG4(q+1)-1,:);
    end

    maxTau = 60;
    filtersG4 = zeros(60,length(cutG4));
    for q = 1:length(cutG4)
        thisStim = cutG4{q}(121:240,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutG4{q}(121:240,4);
        thisResp = thisResp - mean(thisResp);
        filtersG4(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    size(filtersG4)
    meanFiltG4 = mean(filtersG4,2);
    figure('name', 'Epoch 3'); plot(meanFiltG4); title('Contrast 0.9, Second 4');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'High Contrast Kernel, Second 4'], 'fig');
    
    % Second 5 of epoch 4 data
    g5 = Z.epoch4Data2;
    newEpochIndsG5 = find(diff(g5,1) > 1);
    newEpochIndsG5 = [1; (newEpochIndsG5 + 1); (size(g5,1)+1)]
    newEpochIndsG5(end-2:end) = []
    for q = 1:length(newEpochIndsG5)-1 
        newEpochIndsG5(q);
        newEpochIndsG5(q+1);
        q;
        cutG5{q} = f4(newEpochIndsG5(q):newEpochIndsG5(q+1)-1,:);
    end

    maxTau = 60;
    filtersG5 = zeros(60,length(cutG5));
    for q = 1:length(cutG5)
        thisStim = cutG5{q}(181:300,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutG5{q}(181:300,4);
        thisResp = thisResp - mean(thisResp);
        filtersG5(:,q) = oneD_filter( thisStim,thisResp,60);
    end
    a = cutG5{1};
    size(filtersG5)
    meanFiltG5 = mean(filtersG5,2);
    figure('name', 'Epoch 3'); plot(meanFiltG5); title('Contrast 0.9, Second 5');
    ylabel('k(\tau)');
    xlabel('\tau (frames)');
    saveas(gcf, ['plots', filesep, 'High Contrast Kernel, Second 5'], 'fig');
    

    % epoch 3 kernel, including first second
    h = Z.epoch3DataFirstSecondIncluded;
    newEpochIndsH = find(diff(h,1) > 1);
    newEpochIndsH = [1; (newEpochIndsH + 1); (size(h,1)+1)];
    for q = 1:length(newEpochIndsH)-1
        newEpochIndsH(q+1)-1;
        cutH{q} = h(newEpochIndsH(q):newEpochIndsH(q+1)-1,:);
     end
    maxTau = 60;
    filtersH = zeros(60, length(cutH));
    for q = 1:length(cutH)
        thisStim = cutH{q}(:,3);
        thisStim(size(thisStim,1)/2+1:end) = 0;
        thisStim = thisStim - mean(thisStim);
        thisResp = cutH{q}(:, 4);
        thisResp(1:size(thisStim,1)/2) = 0;
        thisResp = thisResp - mean(thisResp);
        filtersH(:,q) = oneD_filter(thisStim, thisResp, 60);
    end
    filtersN = filtersF;
    avgStimVal = mean(thisStim)
    filtersH(:, end) = [];
    filtersN = [filtersN'; filtersH'];
    nSize = size(filtersN)
    hSize = size(filtersH)
    meanFiltN = mean(filtersN);
    meanFiltH = mean(filtersH,2);
    
    figure('name', 'Epoch 3');
    plot(meanFiltN); title('Epoch 3: Contrast 0.2, First Second Included, 1');
    saveas(gcf, ['plots', filesep, 'Low Contrast, First Second Included'], 'fig');
    
    % epoch 3 kernel, first second only
    h = Z.epoch3DataFirstSecondIncluded;
    newEpochIndsH = find(diff(h,1) > 1);
    newEpochIndsH = [1; (newEpochIndsH + 1); (size(h,1)+1)];
    for q = 1:length(newEpochIndsH)-1
        newEpochIndsH(q+1)-1;
        cutH{q} = h(newEpochIndsH(q):newEpochIndsH(q+1)-1,:);
     end
    maxTau = 60;
    filtersH = zeros(60, length(cutH));
    for q = 1:length(cutH)
        thisStim = cutH{q}(1:120,3);
        thisStim = thisStim - mean(thisStim);
        thisResp = cutH{q}(1:120, 4);
        thisResp = thisResp - mean(thisResp);
        filtersH(:,q) = oneD_filter(thisStim, thisResp, 60);
    end
    meanFiltH = mean(filtersH,2);
    
    figure('name', 'Epoch 3');
    plot(meanFiltH); title('First Second Only');
    saveas(gcf, ['plots', filesep, 'Low Contrast, First Second Only'], 'fig');
    
    filtersN = filtersF;
    filtersN = [filtersN'; filtersH'];
    filtersNsize = size(filtersN)
    meanFiltN = mean(filtersN);
    
    figure('name', 'Epoch 3');
    plot(meanFiltN); title('Epoch 3: Contrast 0.2, First Second Included, 2');
    saveas(gcf, ['plots', filesep, 'Low Contrast, First Second Included'], 'fig');
    
    % epoch 4 kernel, including first second
    k = Z.epoch4DataFirstSecondIncluded;
    newEpochIndsK = find(diff(k,1) > 1);
    newEpochIndsK = [1; (newEpochIndsK + 1); (size(k,1)+1)];
    for q = 1:length(newEpochIndsK)-1
        cutK{q} = k(newEpochIndsK(q):newEpochIndsK(q+1)-1,:);
     end
    maxTau = 60;
    filtersK = zeros(60, length(cutK));
    for q = 1:length(cutK)
        thisStim = cutK{q}(:,3);
        thisStim(size(thisStim,1)/2+1:end) = 0;
        thisStim = thisStim - mean(thisStim);
        thisResp = cutK{q}(:, 4);
        thisResp(1:size(thisStim,1)/2) = 0;
        thisResp = thisResp - mean(thisResp);
        filtersK(:,q) = oneD_filter(thisStim, thisResp, 60);
    end
    filtersN = filtersG;
    filtersN =  [filtersN'; filtersK'];
    nSize = size(filtersN)
    kSize = size(filtersK)
    meanFiltN = mean(filtersN);
    meanFiltK = mean(filtersK,2);
    
    figure('name', 'Epoch 4');
    plot(meanFiltN); title('Epoch 4: Contrast 0.9, First Second Included');
    saveas(gcf, ['plots', filesep, 'High Contrast, First Second Included'], 'fig');
    
    figure('name', 'Epoch 4');
    plot(meanFiltK); title('First Second Kernels');
    saveas(gcf, ['plots', filesep, 'High Contrast, First Second'], 'fig');
    


end

