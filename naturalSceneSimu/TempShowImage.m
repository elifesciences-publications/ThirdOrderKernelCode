% show the result for all different picutre, one example. 
% plot the figure and save it. 
clear
clc
%hpcSetup;
PCSetup;

FWHMBank = [1.5,3,5,10,20,50,360];
cl_FWHM= 6;
histeqMode = 0;
velCalMode = 'inst';
velSampMode = 'Binary';
for cl_FWHM = 1:1:7
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,velCalMode,velSampMode);
    ImageShow(param,1);
    
    %Show Effect of Contrast Mapping;
    %StimVelCalculationUniSampV(param);
end
% from here, generate the parameter file