% pilot code for everything.
clear
clc
%hpcSetup;
PCSetup;

FWHMBank = [10, 15, 20, 25, 35, 50, 100, 360];
cl_FWHM = length(FWHMBank);
histeqMode = 0;
velCalMode = 'inst';
velSampMode = 'Uniform';
for cl_FWHM = 4:1:4
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,velCalMode,velSampMode);
    ImagePreProcess(param);
    
    % ImageHistEquaPlot(param);
    StimVelCalculationUniSampV(param);
end
% from here, generate the parameter file
%%
%ImageHistEqua(param);
%%
% MainImageAna(param);
% ImageProcessLocalContrast(param);
%
% stdVBank = [30;270;810;2430];
% nStd = length(stdVBank);
% for i = 1:1:nStd
% ParameterFile
% param.velocity.std = stdVBank(i);
% StimVelCalculationUniSamp(param);
% end
% %MainDataAnalysis
%% raw Luminance picture to contrast picture, vertical dimension is blurred by fly's photoreceptor.
%%

%% there would be several mode to preprocess the Image.
% calculate the
% desInfo = ImagePreProcess(path,photoreceptor);

%% kills off some images. how to delete files from matlab?
% or, when you generate stimulus, you do not use the image int the
%% do you still need stimulus generation? yes.
% do you still need to store them? yes.
% mode = 1, use the contrast calculating by global luminance
% mode = 2, use the contrast calculating by a row luminance
% StimulusGeneration(path,photoreceptor,image,stim,velocity,time,mode)
% StimVelCalculation(param)
% StimVelCalculationUniSamp(param);
%StimVelCalculationUniSampV(param);

%% data analysis