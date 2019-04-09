function basicPlotting(a)
% plot flicker and sine wave responses to each epoch

probeEpochs = 12;
numEpochs = length(fieldnames(a.triggeredResponseAnalysis.triggeredIntensities))-probeEpochs-1;

epochNames = {'0, right', '0.1, right', '0.2, right', '0.5, right', '1, right', '0, left', '0.1, left', '0.2, left', '0.5, left', '1, left'};
m = 1;

% total responses by epoch
flickerdata = zeros(numEpochs*2, 366);
currentRow = 1;
figure('name', 'Total Responses');
for i = (probeEpochs+2):length(fieldnames(a.triggeredResponseAnalysis.triggeredIntensities))
   b = {strcat('a.triggeredResponseAnalysis.triggeredIntensities.epoch_', num2str(i))};  
   b = eval(b{1});
   for j = 1:6:7
       k = nanmean(b(j+1,:,:),3);
       flickerdata(currentRow, :) = cat(2,nanmean(b(j,:,:),3),nanmean(b(j+1,:,:),3),nanmean(b(j+2,:,:),3),nanmean(b(j+3,:,:),3),nanmean(b(j+4,:,:),3), nanmean(b(j+5,:,:),3));
       currentRow = currentRow+1;
   end
   subplot(2,10, m)
   plot(flickerdata(currentRow-2,:));
   title(epochNames{m});
   subplot(2,10,m+10)
   plot(flickerdata(currentRow-1,:));
   title(epochNames{m});
   m = m+1;
end


figure('name', 'Flicker Responses');

% flicker responses by epoch
currentRow = 3;
for m = 1:numEpochs
    subplot(2,10,m)
    plot(flickerdata(currentRow-2, 1:305));
    title(epochNames{m});
    subplot(2,10,m+10)
    plot(flickerdata(currentRow-1,1:305));
    title(epochNames{m});
    m = m+1;
    currentRow = currentRow+1;
end

figure('name', 'Sine Responses');

% sine responses by epoch
currentRow = 3;
for m = 1:numEpochs
    subplot(2,10,m)
    plot(flickerdata(currentRow-2, 306:end));
    title(epochNames{m});
    subplot(2,10,m+10)
    plot(flickerdata(currentRow-1,306:end));
    title(epochNames{m});
    m = m+1;
    currentRow = currentRow+2;
end


end

