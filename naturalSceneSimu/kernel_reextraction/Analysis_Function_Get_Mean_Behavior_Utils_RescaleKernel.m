function kernel = Analysis_Function_Get_Mean_Behavior_Utils_RescaleKernel(kernel, nMultiBars)
    % you want to get the putative elementory motion detectors.
    % assume there are 270 degree screen
    scaling_factor = 270/5 /nMultiBars;
    kernel = kernel/scaling_factor;
end