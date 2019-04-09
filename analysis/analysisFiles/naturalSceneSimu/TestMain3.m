% pilot code for everything.
clear
clc
% hpcSetup;
PCSetup;
% 1.5 does not make sense...
FWHMBank = [10,20,35,50,75,100,360];
cl_FWHM= 1;
histeqMode = 0;
onlyLum = 1;
velCalMode = 'inst';
velSampMode = 'Uniform';
tic

% generate
for cl_FWHM = 1:1:7
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,onlyLum,velCalMode,velSampMode);
    %ImageHistEqua(param);
    tic
    StimVelCalculationUniSampV(param);
    toc
end
toc


for cl_FWHM = 1:1:7
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,onlyLum,velCalMode,velSampMode);
    %ImageHistEqua(param);
    tic
    DataTransferUniform(param);
    toc
end


% analyze the data, should be easy....
% how are you going to analyze your data? what are the data you are
% interested in?

% how it change over space





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
