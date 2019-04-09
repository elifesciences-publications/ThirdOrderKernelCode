function All =  MyLoad(param)

velSampMode = param.velSampMode;
path = param.path;
s = path.s;

switch velSampMode
    case 'Binary'
        % the foldername.v store the fist level of folder.
        vInfo = SearchFolder(path.data_pp);
        nv = length(vInfo);
        All = cell(nv,1);
        %
        for vv = 1:1:nv
            % there would be a folder called D, which stores all the data about
            % that particular velocity.
            fV = [path.data_pp,vInfo(vv).name,s];
            datafile = dir([fV,'*.mat']);
            datafilefull = [fV,datafile.name];
            load(datafilefull);
            All{vv} = D;
        end
    case 'Uniform'
        filepath = SearchFolder(path.data_ppfull);
        datafile = dir([path.data_ppfull,'*.mat']);
        datafilefull = [path.data_ppfull,datafile.name];
        load(datafilefull);
        All = D;
end



end