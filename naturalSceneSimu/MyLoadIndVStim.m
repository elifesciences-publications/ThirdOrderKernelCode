function AllIndV =  MyLoadIndVStim(param)


path = param.path;
s = path.s;

% the foldername.v store the fist level of folder.
vInfo = SearchFolder(path.data_ppfull);
nv = length(vInfo);
AllIndV = cell(nv,1);
%
for vv = 1:1:nv
    % there would be a folder called D, which stores all the data about
    % that particular velocity.
    fV = [path.data_ppfull,vInfo(vv).name,s];
    datafile = dir([fV,'*.mat']);
    datafilefull = [fV,datafile.name];
    load(datafilefull);
    AllIndV{vv} = D; 
end


end