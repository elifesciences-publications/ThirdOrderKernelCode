%%
clear
clc
%hpcSetup;
PCSetup;
% 
% FWHMBank = [1.5,3,5,10,20,50,360];
cl_FWHM= 6;
histeqMode = 0;
velCalMode = 'inst';
velSampMode = 'Uniform';
%%
stim = cell(length(FWHMBank),1);
for cl_FWHM = 1:1:4
    param = ParameterFile(OSMode,cl_FWHM, histeqMode,velCalMode,velSampMode);
 %  DataTransferUniform(param);
   %res = AnaDataUniform(param,0);
   %res = AnaDataUniform(param,1,0.5);
   res = AnaDataUniform(param,0);
   ScatterVBinned(res.v);
  %AnaDataIndVelFullTemp(param,0);
end
DataTransferVel(param)
% %%
% %DataTransferVel(param)
% % AnaMultiPointWeight(param)
% % AnaDataIndVel(param)
% % AnaDataIndVelFull only responsible for generate data, do not plot data
% % anymore, move the functino of plotting out of the AnaDataIndVelFull();
% % %%
% [resWithExt] = AnaDataIndVelFullTemp(param,0);
% [resWithoutExt] = AnaDataIndVelFullTemp(param,1);
% %
% [tExt,eExt,vValue] = AnaIndVelFullComb(resWithExt);
% [tNoExt,eNoExt,vValue] = AnaIndVelFullComb(resWithoutExt);
% %
% % % sor the theoretical one.
% % %%
% % % plot the result for different thing together.
% % PlotXRExtremTheo(tExt.r,tNoExt.r,vValue);
% PlotXRExtremExp(eExt.r,eNoExt.r,vValue);
% % %% plot the scatter plot and the correlation plot, between k2 and k3.
% PlotVScatterExp(resWithExt.v,resWithoutExt.v)
% %PlotVScatterTheo(resWithExt.v,resWithoutExt.v)

%% plot the correlation between different condition.


%
% All = CombVel(param);
% AnaVScale(All.v);
% %%
% stdVBank = param.stdVBank;
% DataTransfer(param);
% load('90VelData.mat');
% AnaExtremV(D);
% %%
% % load interested data;
% fileInfo = dir([param.path.data,'*.mat']);
% fullname = [param.path.data,fileInfo.name];
% load(fullname);
% ngroup = length(D);
%
% %% analyze the data for different velocity distribution.
% result = cell(1,ngroup);
% %%
% p = 5;
% for i = 1:1:2
%     % there could be a lot of possible way to analyize the data.
%     % do all the similar analysis you have done before ?
%
%     % saw the distribution
%
%     v = D{i}.v;
%     if i == 2
%      AnaVScale(v);
%      AnaCorrAllPerc(v);
%     end
%      if i ~= 2
%     result{i} = AnaIndividual(v,p,1);
%      end
% end
%
% %% plot the result of correlation, p = 1. 98%. without bootstrp.
% %%
% % save('TempDataGlobal.mat','result','D');
%
% % %%
% % load('TempdataGlobal.mat');
% % [r,w] = AnaCombRW(result);
% % strInfo.title = ['real velocity are drawn from different distribution'];
% % strInfo.xlabel = ['std of velocity'];
% %
% % PlotXRW(r,w,stdVBank,strInfo);
% % %%
% % ShowResultSTDandV;
% %
%
