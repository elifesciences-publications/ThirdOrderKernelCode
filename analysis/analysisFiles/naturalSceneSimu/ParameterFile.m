function param = ParameterFile(OSMode,cl_FWHM, histeqMode,onlyLum,velCalMode,velSampMode,varargin)
nStim = 1000;
FWHMBank = [];
contrast_form = 'static'
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% OSMode : PC  or HPC
% cl_FMHW : It is a index, not a value.
% histeqMode: 0, do not use front-end equlization. 1, use it.
% VelMode: averaged velocity or unaveraged one.
% in anycase, do not calculat the 70 term in the full model. too much for
% the computer.
path = PathManagement(OSMode);
%%
% a lot of linear interpolation needs to be done...
time.dt = 1/60;
time.duration = 1000 * 1e-3;
time.t = 0:time.dt:time.duration;
time.n = length(time.t);
% time scale
%%
% parameter for photoreceptor
photoreceptor.spatial.distance = 5.1; % two photoreceptor is 5.1 degree separate.

% parameter of spatial filter.
photoreceptor.spatial.FWHM = 5.7; % 5.7 degree
photoreceptor.spatial.sig = photoreceptor.spatial.FWHM/2.3548;
photoreceptor.spatial.GaussianRange = 3;
photoreceptor.spatial.nHorSig = DegreeToPixel(photoreceptor.spatial.sig,'h');
photoreceptor.spatial.nVerSig = DegreeToPixel(photoreceptor.spatial.sig,'v');
photoreceptor.spatial.filter = FilterGeneration(photoreceptor.spatial);
photoreceptor.spatial.on = 1;

%% the data here should be load every time from the data;
load(fullfile(path.paradata,'Metadata.mat'));
image.origin.hor.nPixel = length(Metadata.horsteps);
image.origin.ver.nPixel = length(Metadata.vertsteps);
image.origin.hor.degree = Metadata.horsteps;
image.origin.ver.degree = Metadata.vertsteps;
clear Metadata;

image.param.hor.nPixel = image.origin.hor.nPixel;
image.param.ver.nPixel = image.origin.ver.nPixel; % to be changed... 4 * sig. to be changed again.
image.param.hor.degree = image.origin.hor.degree;
image.param.ver.degree = image.origin.ver.degree; % to be changed.
image.param.hor.x = image.param.hor.degree;
image.param.hor.dx = image.param.hor.degree(2) - image.param.hor.degree(1);

%% the FWHM will be subjected to change. It is painful, but I have to do that...
% the MainStimiulus would require the FWHMBank to change value accordingly.
%
image.lcf.FWHMBank = FWHMBank;
image.lcf.FWHMi = cl_FWHM;
image.lcf.FWHM = image.lcf.FWHMBank(cl_FWHM);
image.lcf.sig = image.lcf.FWHM/2.3548;
image.lcf.GaussianRange = 2;
image.lcf.nHorSig = DegreeToPixel(image.lcf.sig,'h');
image.lcf.nVerSig = DegreeToPixel(image.lcf.sig,'v');
image.lcf.filter = FilterGeneration(image.lcf,'ipara.hor.nPixel',image.param.hor.nPixel,'ipara.ver.nPixel',image.param.ver.nPixel);
image.histeq.range = [-1,1];

% image_cl(image_cle)/FWHM20/image1, 2, .....
switch contrast_form
    case 'static'
        path.image = FoldernameGenCL(path,image.lcf.FWHM,histeqMode,onlyLum);
    case 'dynamic'
        path.image = 'D:\Natural_Scene_Simu\image\dynamiche0'; % hard coded here for now.
end
%%===========================!!! change this so that it is correct in the
%%future.! you want to change your data source flexibly in the future.

% %% you want to generate a group image which has zero mean, but has not been 0...
% % data_cl(data_cle)/FWHM20(360)/inst(ave)/Binary(Guassian)/Vel16,Vel32,....(Std90,Std300...)
%
% path.data = FoldernameGenData(path,image.lcf.FWHM,histeqMode,onlyLum, velCalMode, velSampMode);
% path.data_pp = FoldernameGenDataPP(path,image.lcf.FWHM,histeqMode,onlyLum, velCalMode, velSampMode);
% path.data_ppfull = FoldernameGenDataPPFull(path,image.lcf.FWHM,histeqMode,onlyLum,velCalMode, velSampMode);
% %%
% % if velSampMode =
% %%
% % try to store the velocity
% % stdVBank = [30;90;270;810;2430];
% velocity.mean = 0;
% velocity.std = 90; % 90 degree/second.
% velocity.value = [16,32,64,128,256,512,1024];
% velocity.maxUniform = 500;
% %%
% stim.n = nStim; % 10 data points.
% stim.param.time = time;
%
% %% HRC filter
% HRC.param.tau = 20 * 1e-3;
% HRC.param.dur = 200 * 1e-3;
% HRC.param.dt = time.dt;
% HRC.param.t = 0:HRC.param.dt:HRC.param.dur;
% HRC.param.n = length(HRC.param.t);
% HRC = HRCGenerator(HRC);
%
% %% explicit multipoint correlator.
% % interms of the parameter of temporal resolution and the time constant.
% MC = HRC;
% % the highest order is 4.
% MC.n = 4;
% MC.w_ind = MCIndexOrder();
% %% theoretical third order correlator.
%
% % there are two converging third order kernels;
% % (f*V1)(g*V1)(f*V2)()
% % (f*V1)()(f*V2)(g*V2)
% ConvK3.WinMC = [1,1,1,0;1,0,1,1];
% [~,ConvK3.ind] = ismember(ConvK3.WinMC,MC.w_ind,'rows');
% % there are two past skew third order kernels;
% % (f*V1)^2()()(g*V2)
% % ()(g*V1)(f*V2)^2()
% PSK3.WinMC = [2,0,0,1;0,1,2,0];
% [~,PSK3.ind] = ismember(PSK3.WinMC,MC.w_ind,'rows');
% %% autocorrelation
% % (f*V1)^2
% % (g*V1)^2
% % (f*V2)^2
% % (g*V2)^2
% AutoK2.WinMC = [2,0,0,0;0,2,0,0;0,0,2,0;0,0,0,2];
% [~,AutoK2.ind] = ismember(AutoK2.WinMC,MC.w_ind,'rows');
%
% %% second order filter
% load([path.paradata,'OLS_2o_nonorm.mat']);
% K2.param.dt = 1/60; % data is 60 Hz;
% K2.param.n = 50; % length of data is 1/60Hz.
% K2.param.dur = K2.param.dt * (K2.param.n - 1);
% K2.param.t = 0:K2.param.dt:K2.param.dur;
%
% K2.k2_xy = Z.kernels.meanKernels.k2_xy;
% K2.k2_sym = Z.kernels.meanKernels.k2_sym;
% clear Z
% %% third order filter
% %% second order filter
% load([path.paradata,'OLS_3o_nonorm.mat']);
% K3.param.dt = 1/60; % data is 60 Hz;
% K3.param.n = 50; % length of data is 1/60Hz.
% K3.param.dur = K3.param.dt * (K3.param.n - 1);
% K3.param.t = 0:K3.param.dt:K3.param.dur;
%
% K3.k3_xxy = Z.kernels.meanKernels.k3_xxy;
% % sum(sum(sum(K3.k3_xxy))) = -2.0771;
% K3.k3_yyx = Z.kernels.meanKernels.k3_yyx;
% %  sum(sum(sum(K3.k3_yyx))) = -10.5797;
% K3.k3_sym = Z.kernels.meanKernels.k3_sym;
% clear Z
%
% %% store them into a larger structure, kernel.
% kernel.HRC = HRC;
% kernel.K2 = K2;
% kernel.K3 = K3;
% kernel.MC = MC;
% kernel.ConvK3 = ConvK3;
% kernel.PSK3 = PSK3;
% kernel.AutoK2 = AutoK2;
%
% %% computation related parameter
% % the stimulu, velocity pair would be stored in the form of unit.
% % after each unit, usr should be able to combine them together.
% computation.nSpS = 20000;

%%
% param.stim = stim;
% param.kernel = kernel;
% param.velocity = velocity;
param.path = path;
param.image = image;
param.time = time;
param.photoreceptor = photoreceptor;
% param.OSMode = OSMode;
% param.histeqMode = histeqMode;
% param.velCalMode = velCalMode;
% param.velSampMode = velSampMode;
% param.computation = computation;

end