function outMean = MattMean(sampledInputs)
    outMean = zeros(size(sampledInputs));

    for ii = 1:length(sampledInputs)
        outMean(ii) = mean(sampledInputs{ii});
    end
end