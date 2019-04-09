function filepath_new = ChangePath_Temp(filepathAll)
nfile = length(filepathAll);
filepath_new= cell(nfile,1);
for ff = 1:1:nfile
    filepath = filepathAll{ff};
    
    % try to get into this file.
    file_in_folder = dir(filepath);
    if length(file_in_folder) == 3
        filepath_new{ff} = [filepath,'/', file_in_folder(3).name];
    else
        filepath_new{ff} = filepath;
    end
    
end