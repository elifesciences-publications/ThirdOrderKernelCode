function triggeredResponseDifferentialAnalysis(epoch_avg_triggered_intensities, differentialEpochs, varargin)
% This is one of the potential two photon analysis methods. It takes pairs
% of epochs that describe preferred and null directions, finds the mean
% fluorescence over the entire epoch and then subtracts the null direction
% value from the preferred direction value. It makes use of
% triggeredResponseAnalysis to do the extraction of the data in
% trigger-reference form (i.e. averaged over the stimulus presentation per
% epoch, but not over the entire duration of the trigger, which is one of
% the extra steps this function performs)

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

epochs = fields(epoch_avg_triggered_intensities);
epoch_nums = cellfun(@(epoch) str2num(epoch(epoch>'0' & epoch<'9')), epochs);

for antagonizingEpochs = differentialEpochs
    epochOneForResponse = antagonizingEpochs(1);
    epochTwoForResponse = antagonizingEpochs(2);
    if ~any(epoch_nums==antagonizingEpochs(1))
        warning(['Epoch ' num2str(antagonizingEpochs(1)) ' not found in the photodiode data']);
        continue;
    end
    if ~any(epoch_nums==antagonizingEpochs(2))
        warning(['Epoch ' num2str(antagonizingEpochs(2)) ' not found in the photodiode data']);
        continue;
    end
    epochOneMeanResponse = mean(epoch_avg_triggered_intensities.(['epoch_' num2str(epochOneForResponse)]), 2);
    epochTwoMeanResponse = mean(epoch_avg_triggered_intensities.(['epoch_' num2str(epochTwoForResponse)]), 2);
    differentialResponse = epochOneMeanResponse - epochTwoMeanResponse;
    figure
    plot(differentialResponse);
end

