function foldername = FoldernameGenData(path,FWHM,histeqMode,onlyLum,velCalMode, velSampMode)
% generate several folders together.
s = path.s;
str = ['FWHM',num2str(FWHM,'%u')];

if onlyLum
    foldername = [path.data_luml,str];
else
if histeqMode
    foldername = [path.data_cle,str];
else
    foldername = [path.data_cl,str];
end
end
if strcmp(velCalMode,'inst')
    foldername = [foldername,s,'inst'];
elseif strcmp(velMode,'ave')
    foldername = [foldername,s,'ave'];
end

foldername = [foldername,s,velSampMode];

if ~exist(foldername,'dir');
    mkdir(foldername);
end

foldername = [foldername,s];
end