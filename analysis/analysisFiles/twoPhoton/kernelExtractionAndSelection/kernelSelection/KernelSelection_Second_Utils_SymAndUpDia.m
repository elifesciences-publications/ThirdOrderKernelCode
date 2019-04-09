function kernelSym = KernelSelection_Second_Utils_SymAndUpDia(kernel)
maxSquared = size(kernel,1);
maxTau = round(sqrt(maxSquared));
kernelSquare = reshape(kernel,[maxTau,maxTau]);
kernelSym = kernelSquare - kernelSquare';
kernelSym(tril(true(maxTau,maxTau),-1)) =  0; % set the lower part of the kernel to be zeros..
kernelSym = kernelSym(:);
end