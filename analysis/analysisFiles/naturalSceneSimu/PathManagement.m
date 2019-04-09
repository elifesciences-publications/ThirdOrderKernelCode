function path = PathManagement(OSMode)

if strcmp(OSMode,'PC')
    %% path.
    
    % get the system Config, so that it could be set to H/
%     S = GetSystemConfiguration;
    homedir = 'D:\Natural_Scene_Simu';
    s = '\';
    % use the
else strcmp(OSMode,'hpc')
    % in the cluster
    %
    homedir = [cd,'/'];
    s = '/';
end

% image pathway.
path.raw = fullfile(homedir,'image','data_001-100');
path.image_cl = fullfile(homedir,'image','statiche0');
path.image_cle = fullfile(homedir,'image','statiche1');
% path.image_lum = [homedir,'image_lum',s];
path.image_luml = [homedir,'image_luml',s];
% data will be separately stored for two different situations
path.data_cl = [homedir,'data_cl',s];
path.data_cle = [homedir,'data_cle',s];
% path.data_lum = [homedir,'data_lum',s];
path.data_luml = [homedir,'data_luml',s];
% store the prepocessed data D.
path.data_pp_cl = [homedir,'data_pp_cl',s];
path.data_pp_cle = [homedir,'data_pp_cle',s];
% path.data_pp_lum = [homedir,'data_pp_lum',s];
path.data_pp_luml  = [homedir,'data_pp_luml',s];
% store the preprocessed data D, which contains the time trace of the
% stimulus.
path.data_ppfull_cl = [homedir,'data_ppfull_cl',s];
path.data_ppfull_cle = [homedir,'data_ppfull_cle',s];
path.data_ppfull_luml = [homedir,'data_ppfull_luml',s];


path.paradata = fullfile(homedir,'parameterdata');
path.data_trans = [homedir,'data_trans',s];

path.s = s;
end