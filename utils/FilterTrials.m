function output = FilterTrials(snipMat,responsiveTrials)
% Takes in a snipMat and a snipMat format cell array which contains a
% logical index of the trials
    output = cellfun(@(epoch,trials)epoch(:,trials,:),snipMat,responsiveTrials,'UniformOutput',false);

end