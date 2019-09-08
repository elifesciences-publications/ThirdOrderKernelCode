function flyId = AssignFlyId(sameFly)
    if nargin < 1
        sameFly = 0;
    end

    flyIdPath = fullfile(fileparts(which('RunStimulus')),'analysis','flyId.mat');

    if sameFly
        load(flyIdPath);
    else
        % generate a random number for a fly Id. This number will be 64 bit
        % so the probability of repeating is tiny
        % generate 64 random 0 or 1s
        binList = uint64(round(rand(64,1)));
        % get the weight vector to convert from binary to unint64
        convArray = uint64((0:63)');
        weights = uint64(2).^convArray;
        flyId = sum(binList.*weights,'native');
        save(flyIdPath,'flyId');
    end
end