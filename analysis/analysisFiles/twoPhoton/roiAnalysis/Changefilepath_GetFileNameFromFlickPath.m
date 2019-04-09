function filepathNew = Changefilepath_GetFileNameFromFlickPath(filepath,flickpath)
    % only change the last part of the name? no. change the whole name into
    % correct format.
    oldAbsolutePath = 'H:/2pData/2p_microscope_data/';
    newAbsolutePath = 'Y:\';
    filepath(1:length(oldAbsolutePath)) = [];
    filepath = [newAbsolutePath,filepath];
    filepath(filepath == '/') = '\'
    flickpath(flickpath == '/') = '\'
    
    filepathSeg = strsplit(filepath,'\');
    flickpathSeg = strsplit(flickpath,'\');
    
    filepathSeg{end} = flickpathSeg{3};
    filepathNew = strjoin(filepathSeg,'\');
    
    % you should fix the file paths again....
    % second, get the correct flickpath.
end