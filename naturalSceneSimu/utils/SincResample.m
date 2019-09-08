function dd = SincResample(data,dataSampleRate,desiredSampleRate)
    % resamples data every resampleInt points after filtering with a sinc
    % function
    
    if mod(dataSampleRate,desiredSampleRate) ~= 0
        disp('data sample rate must be a multiple of desired sampel rate');
        exit;
    end
    
    numSamples = length(data);
    resampleInt = round(dataSampleRate/desiredSampleRate);
    
    filterT = ((0:numSamples-1)-numSamples/2)/dataSampleRate;
    % generate sinc function and then normalize by multiplying by the ratio
    % of the two frequencies so that the fourier transform has a maximum of 1
    sincForm = sinc(filterT*(desiredSampleRate))*desiredSampleRate/dataSampleRate;
    
    % consider normalizing the filter to have unit energy
    
    dd = conv(data,sincForm,'same');
    
    dd = dd(1:resampleInt:end);
end