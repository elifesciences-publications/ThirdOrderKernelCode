function kHandle = quickKernelPlot( kernel )
% Plots first- or second-order kernel by making an educated guess based on
% size.

    if length(kernel) > 500
        maxTau = round(sqrt(length(kernel)));
        kHandle = imagesc( reshape(kernel, [maxTau maxTau] ) );
    else
        maxTau = length(kernel);
        kHandle = plot( kernel );
    end

end

