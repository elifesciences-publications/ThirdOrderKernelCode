
maxTaus = 64;
lambda = 30;
fs = 60;

analytical_quad_tuning = predictQuadraticTuning( ...
    reshape(sum(quadKernels,2),[maxTaus maxTaus]), ...
    lambda, fs ); % Note that analytical quadratic tuning is mean of selected filters
analyticalQuadTuning = analytical_quad_tuning.predResp;
freqQuadAxis = (analytical_quad_tuning.filtF_axis);
% analyticalQuadTuning = cat(2,analyticalQuadTuning,...
%     (analytical_quad_tuning.predResp)');

% simulation
kernels{1} = [];
kernels{2} = quadKernels;
for r = 1:length(freqQuadAxis)
    thisOmega = freqQuadAxis(r);
    quadSim = ... % see comments for linear simulation
        tp_simplePrediction( kernels, 'identity',... % no nonlinearity - just apply filter!
        'stimType','sine','which',[0 1 0],... % only applying SECOND ORDER filter
        'stimLambda',lambda,'nOm',1,'multiBarsUse',1,'stimOmega',thisOmega,...
        'stimHz',fs,'barWd',barWidth);
    simulation_quad_tuning(r,1) = quadSim.model.respMean;
    fprintf(['Second order response ' num2str(r) ' out of ' num2str(length(freqQuadAxis)) ' calculated. ' ]); toc
end
simulationQuadTuning = simulation_quad_tuning;

freqQuadAxisShift = fftshift(freqQuadAxis);
freqQuadAxisShift = mod(freqQuadAxisShift+fs/2,fs) - fs/2;
analyticalQuadTuningShift = fftshift(analyticalQuadTuning);
simulationQuadTuningShift = fftshift(simulationQuadTuning);

subplot(2,2,2)
plot(freqQuadAxisShift,analyticalQuadTuningShift); hold all;
plot(freqQuadAxisShift,simulationQuadTuningShift); hold all;
%         plot(dtQuadAxisShift,dtQuadShiftScale); hold off;
title('Tuning of Second Order Kernel  - Holly');
legend('analytical','simulation');
xlabel('Frequency (hz)');
ylabel('Response (au)');
