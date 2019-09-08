function nMultiBars = decipher_nMulitbars_from_full_file_path(filepath)
    filepath_parts = strsplit(filepath, filesep);
    stimfunction = filepath_parts{3};
    stim_parts = strsplit(stimfunction, '_');
    nMultiBars = str2num(stim_parts{2});
end