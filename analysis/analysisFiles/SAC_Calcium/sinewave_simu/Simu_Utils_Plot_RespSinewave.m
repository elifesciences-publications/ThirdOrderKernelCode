function Simu_Utils_Plot_RespSinewave(resp_reshape)
c_max = max(abs(resp_reshape(:)));
MakeFigure;
subplot(2,4,1);
SAC_SineWave_Plot_Utils_KFPlot(resp_reshape(:,:,1), 1, c_max);
title('preferred direction');

subplot(2,4,2);
SAC_SineWave_Plot_Utils_KFPlot(resp_reshape(:,:,2), 1, c_max);
title('null direction');

subplot(2,4,3);
SAC_SineWave_Plot_Utils_KFPlot(resp_reshape(:,:,1) - resp_reshape(:,:,2), 0, c_max);
title('preferred - null');

end