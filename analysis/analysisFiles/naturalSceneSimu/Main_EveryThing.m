% pilot code for everything.
clear
clc
% hpcSetup;
PCSetup;
% 1.5 does not make sense...
FWHMBank = [10,20,35,50,75,100,360];
cl_FWHM= 1;
histeqMode = 0;
velCalMode = 'inst';
velSampMode = 'Guassian';
tic

% generate
for cl_FWHM = 1:1:7
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,velCalMode,velSampMode);
    %ImageHistEqua(param);
    tic
    StimVelCalculationUniSampV(param);
    toc
end
toc
% combine the data generated in batch into a big thing, but with less
% information.
for cl_FWHM = 1:1:7
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,velCalMode,velSampMode);
    %ImageHistEqua(param);
    tic
   DataTransferUniform(param);
    toc
end
toc

% ImageHistEqua(param);
%%
ImagePreProcess(param);
% MainImageAna(param);
%ImageProcessLocalContrast(param);
%
% stdVBank = [30;270;810;2430];
% nStd = length(stdVBank);
% for i = 1:1:nStd
% ParameterFile
% param.velocity.std = stdVBank(i);
% StimVelCalculationUniSamp(param);
% end
% %MainDataAnalysis
