function outSnipMat = ReduceDimensionFFT(inSnipMat)
% Take the mean along a given dimension.
% Takes in a snipMat and a string specifying the dimension to average
% across: 'flies','epochs','time', or 'trials'. Optionally take in a
% function handle to apply to the dimension. dimension can also be a cell
% array of dimensions to apply in order.

% hard coded for frequency of 1 Hz
    outSnipMat = {};
    for k = 1:size(inSnipMat, 2)
        for j = 1:size(inSnipMat, 1)
            currentData = inSnipMat{j, k};
            Fs = size(currentData, 1)/5;
            T = 1/Fs;
            L = size(currentData, 1);
            t = (0:L-1)*T;
            Y = fft(currentData);
            P2 = abs(Y/L);
            P1 = P2(1:(L-1)/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:L/2)/L;
            outSnipMat{j, k} = P1(f ==1);
        end
    end
            
            
    

end