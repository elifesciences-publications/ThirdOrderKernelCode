function All = CombVel(param)

path = param.path;
s = path.s;

% the foldername.v store the fist level of folder.
vInfo = SearchFolder(path.data);
nv = length(vInfo);
ndata = 0;

%
for vv = 1:1:nv
    % there would be a folder called D, which stores all the data about
    % that particular velocity.
    fV = [path.data,vInfo(vv).name,s];
    datafile = dir([fV,'*.mat']);
    datafilefull = [fV,datafile.name];
    load(datafilefull);
    ndata = ndata + D.ndata;
end

imageID = zeros(ndata,1);
stimc.std = zeros(ndata,1);
stimc.max = zeros(ndata,1);
v.HRC = zeros(ndata,1);
v.k2 = zeros(ndata,1);
v.k3= zeros(ndata,1);
v.real = zeros(ndata,1);

startP = 1;
for vv = 1:1:nv
    
    fV = [path.data,vInfo(vv).name,s];
    datafile = dir([fV,'*.mat']);
    datafilefull = [fV,datafile.name];
    load(datafilefull);
    
    endP = D.ndata;
    v.HRC(startP:startP + endP - 1) = D.v.HRC;
    v.k2(startP:startP + endP - 1) = D.v.k2;
    v.k3(startP:startP + endP - 1) = D.v.k3;
    v.real(startP:startP + endP - 1) = D.v.real;
    imageID(startP:startP + endP - 1) = D.imageID;
    stimc.std(startP:startP + endP - 1) = D.stimc.std;
    stimc.max(startP:startP + endP - 1) = D.stimc.max;
    
    startP = startP + endP;
end

All.v = v;
All.stimc = stimc;
All.imageID = imageID;
end