% pilot code for everything.
clear
clc
%hpcSetup;
PCSetup;

FWHMBank = [1.5,3,5,10,20,50,360];
cl_FWHM= 6;
histeqMode = 0;
velCalMode = 'inst';
velSampMode = 'Binary';
for cl_FWHM = 1:1:1
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,velCalMode,velSampMode);
    %ImageHistEqua(param);
    StimVelCalculationUniSampV(param);
end