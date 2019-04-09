function HRC = GenerateHRC_ContrastAdaptation(contrast_adaptation_flag, adaptation_form)
% get the same sampling rate
HRC = VelocityEstimation_Utils_GenerateHRC();
HRC.contrast_adaptation_flag = contrast_adaptation_flag;
HRC.adaptation_form = adaptation_form;

end