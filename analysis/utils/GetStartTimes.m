function epochStartTimes = GetStartTimes(epochs)
    % approximate max epoch is the max of the first fly and ROI.
    % Technically that fly might not have seen all epochs, but the cell
    % array will allow us to add later, this is an approximation.

    % Find the frames where the epoch changes. Note that the first epoch
    % won't be counted.
    [epochChangeFrames,epochChangeRois] = find(diff([zeros(1,size(epochs,2)); epochs]));
    % Account for shift caused by the diff function
%     epochChangeFrames = epochChangeFrames+1; 

    % Get linear index of epochs that are starting at the change point
    epochIdx = sub2ind(size(epochs),epochChangeFrames, epochChangeRois);

    % Make a snipMat-like data format for the start times of the epochs.
    % Accumarray is given the {} function which concatonates all the change
    % frames for a given epoch and fly.
    epochStartTimes = accumarray([epochs(epochIdx) epochChangeRois],...
                                 epochChangeFrames, [], @(x){sort(x)});
end