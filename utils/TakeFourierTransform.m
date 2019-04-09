function fourierTransformed = TakeFourierTransform(snipMat)
    fourierTransformed = cellfun(@(x) abs(fft(x,[],1)),snipMat,'UniformOutput',0);
end