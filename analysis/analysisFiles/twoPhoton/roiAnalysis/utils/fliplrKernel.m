function kernelAdjusted = fliplrKernel(kernel,order)
    switch order
        case 1
            kernelAdjusted = fliplr(kernel);
        case 2
            % there is 20 of them..
            nMultiBars = size(kernel,2);
            maxTauSquared = size(kernel,1);
            maxTau = round(sqrt(maxTauSquared));
                
            kernelAdjusted = zeros(maxTauSquared,nMultiBars);
            for qq = 1:1:nMultiBars
                kernelThisBar = kernel(:,qq);
                kernelThisBar = reshape(kernelThisBar, [maxTau,maxTau]);
                % switch the direction, stim1 is right direction now...
                kernelThisBarAdjusted = kernelThisBar';
                kernelAdjusted(:,qq) = kernelThisBarAdjusted(:);
            end
    end
end