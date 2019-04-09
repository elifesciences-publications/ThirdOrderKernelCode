function  [r,weight,mutR] = CorrCalFromParamToR(param)
 
    path = param.path;
    s = path.s;    
    % the foldername.v store the fist level of folder.
    % the path.data stores the first level of imformation...
    
    % vInfo
    vInfo = SearchFolder(path.data);    
    fstore = [path.data_ppfull,vInfo.name,s];
    filenameSum = [fstore,'D.mat'];
    % load the data, that is the value for the velocity..
    tic
    load(filenameSum)
    toc
    
    % for all numbers...
    [r,weight,mutR] = CorrCalFromDtoR(D); % summary result...
%     [r,weight,mutR] = CorrCalFromDtoR_NoExtremValue(D);

    
end