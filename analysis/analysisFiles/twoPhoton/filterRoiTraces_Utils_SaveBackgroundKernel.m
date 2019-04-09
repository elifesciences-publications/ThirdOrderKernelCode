function filterRoiTraces_Utils_SaveBackgroundKernel(Z)

pathname = [Z.params.filename,'/','savedAnalysis/'];
filename = [pathname,'bckgKernel_',datestr(now,'yy_mm_dd'),'.mat'];
bckgkernel = Z.kernels.kernels;
save(filename,'bckgkernel');

end