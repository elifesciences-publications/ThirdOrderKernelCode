% the structure of your program

% first, generate images using the different contrast calculatio..
clear
clc
%hpcSetup;
PCSetup;

FWHMBank = [10,20,35,50,75,100,360];
cl_FWHM = 6;
histeqMode = 0;
onlyLum = 1;
velCalMode = 'inst';
velSampMode = 'Binary';

for cl_FWHM = 1:1:length(FWHMBank)
param = ParameterFile(OSMode,cl_FWHM, histeqMode,onlyLum,velCalMode,velSampMode);
ImagePreProcess(param);
end
% tic
% param = ParameterFile(OSMode,5, histeqMode,velCalMode,velSampMode);
% ImagePreProcess(param);
% 
% param = ParameterFile(OSMode,6, histeqMode,velCalMode,velSampMode);
% ImagePreProcess(param);
% toc
% second, generate stimulus and the extracted velocity.

% third, analyze the relationship between vest and vreal.