function LNModel(linearFilter, stimulus, responseData, bins)

simulatedResponse = conv(stimulus, linearFilter, 'valid');
responseData = responseData(length(linearFilter):end);

binEdges = linspace(min(simulatedResponse), max(simulatedResponse), bins);

%histc does a weird one with the last edge where it only covers things
%matching that edge; to make the bins equal, we make sure nothing matches
%that edge while being smaller than it by setting it to inf
binEdgesMod = [binEdges(1:end-1) inf];
[numValsPerBin, bin] = histc(simulatedResponse, binEdgesMod);

if numValsPerBin(end)
    disp('Double warning: for some reason a value in your simulatedResponse is equal to infinity. The second warning is that said value will be ignored.')
end

% The center is just halfway from the first edge to the next one
binCenters = diff(binEdges)/2+binEdges(1:end-1);


%Go through all the bins
for i = 1:length(binEdges)-1
    avgResp(i) = mean(responseData(bin==i));
    stdResp = std(responseData(bin==i));
    semResp(i) = stdResp/sqrt(length(responseData(bin==i)));
end

%We only want to fit points that have plenty of values to average over
fittingIndexes = find(numValsPerBin>std(numValsPerBin)/3);
% fittingIndexes = 1:length(binCenters);

newBinCenters = binCenters(fittingIndexes);
newAvgResp = avgResp(fittingIndexes);
newSemResp = semResp(fittingIndexes);

%Do a linear fit
coeffs = polyfit(newBinCenters, newAvgResp, 1);

nonlinearity = polyval(coeffs, newBinCenters);
plot_err_patch(newBinCenters, newAvgResp, newSemResp, lines(1));
hold on

% plot(newBinCenters, nonlinearity, 'r', 'LineWidth', 14);
axis square;
axisLims = axis;

%This is the linear response line
% plot(axisLims(1:2), axisLims(1:2), 'r', 'LineWidth', 1.5);
plot(newBinCenters, nonlinearity, 'r');

xlabel('Predicted linear response (\Delta F/F)')
ylabel('Actual response (\Delta F/F)')

legend('Predicted vs. actual (binned) response', 'Linear response line')
title('Linear model prediction')
hold off