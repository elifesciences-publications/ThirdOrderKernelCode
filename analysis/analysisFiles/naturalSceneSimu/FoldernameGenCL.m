function foldername = FoldernameGenCL(path,FWHM,histeqMode,onlyLum)
% generate several folders together.
s = path.s;
str = ['FWHM',num2str(FWHM,'%u')];

if onlyLum
    foldername = fullfile(path.image_luml,str);
else
    if histeqMode
        foldername = fullfile(path.image_cle,str);
    else
        foldername = fullfile(path.image_cl,str);
    end
end


if ~exist(foldername,'dir');
    mkdir(foldername);
end

foldername = [foldername,s];
end