function DataTransferStimulus(param)
% This is data tansformation designed for data was generated based on
% velcity.
% from 16 to ...
% there would be several pattern.
% if it is raw data, calculate the raw one.
% the final result should be stored in a big D structure.? could matlab
% store such a large data set?

path = param.path;
s = path.s;
nSpS = param.computation.nSpS;

% the foldername.v store the fist level of folder.
vInfo = SearchFolder(path.data);
nv = length(vInfo);

for vv = 1:1:nv
    % from there, in every children folder, there would be a tempo
    % get into every file, check whether there is anything .
    fV = [path.data,vInfo(vv).name,s];
    dateInfo = SearchFolder(fV);
    disp(fV);
    
    ndate = length(dateInfo);
    nDataUnit = 0;
    % first, know how many data are there for this particular velocity.
    for tt = 1:1:ndate
        fDate = [fV,dateInfo(tt).name,s];
        fileInfo = dir([fDate,'*.mat']);
        nfile = length(fileInfo);
        nDataUnit = nDataUnit + nfile;
    end
    % for this velocity, store all the result into one big Structure called
    % for this particular velocity and this particular date,
    % summarize the data and store them into a summary file

    imageID = zeros(nSpS,nDataUnit);
    stimc.std = zeros(nSpS,nDataUnit);
    stimc.max = zeros(nSpS,nDataUnit);
    stimc.whole = cell(nSpS,nDataUnit);
    v.HRC = zeros(nSpS,nDataUnit);
    v.k2 = zeros(nSpS,nDataUnit);
    v.k3= zeros(nSpS,nDataUnit);
    v.real = zeros(nSpS,nDataUnit);
    % v.MC = zeros(nDataUnit,70
    v.ConvK3 = zeros(nSpS, nDataUnit, 2); % two data, might not be equally weighted
    v.PSK3 = zeros(nSpS, nDataUnit, 2); % two data, might not be equally weighted.
    v.AutoK2 = zeros(nSpS, nDataUnit, 4); % four data, what is happening for them? interesting...
    
    counter = 1;
    
    for tt = 1:1:ndate
        fDate = [fV,dateInfo(tt).name,s];
        fileInfo = dir([fDate,'*.mat']);
        nfile = length(fileInfo);
        
        for dd = 1:1:nfile
            
            load([fDate,fileInfo(dd).name]);
            % the data has to be accessed in a strange way...
            % your design is soooooo bad.....
            for ii = 1:1:nSpS
                v.HRC(ii,counter) = dataArray{ii}.vest.HRC;
            v.k2(ii,counter) = dataArray{ii}.vest.K2.sym;
            v.k3(ii,counter) = dataArray{ii}.vest.K3.sym;
            v.MC(ii,counter,:) = dataArray{ii}.vest.MC';
            v.ConvK3(ii,counter,:) = dataArray{ii}.vest.ConvK3';
            v.PSK3(ii,counter,:) = dataArray{ii}.vest.PSK3';
            v.AutoK2(ii,counter,:) = dataArray{ii}.vest.AutoK2';
            v.real(ii,counter) = dataArray{ii}.vel;
            
            imageID(ii,counter) = dataArray{ii}.ImageID;
            % information for that set of stimulus.
            stimc.max(ii,counter) = max([max(dataArray{ii}.s1),max(dataArray{ii}.s2)]);
            stimc.std(ii,counter) = (std(dataArray{ii}.s1) + std(dataArray{ii}.s2))/2;            
            stimc.whole{ii,counter}.s1 = dataArray{ii}.s1;
            stimc.whole{ii,counter}.s2 = dataArray{ii}.s2;
            % apart from the velocity, the stimulus would also be stored.
           % look at what is happening to those ts
            end
           
            counter = counter + 1;
        end
    end
    
    imageID = imageID(:);
    stimc.std = stimc.std(:);
    stimc.max = stimc.max(:);
    
    v.HRC = v.HRC(:);
    v.k2 = v.k2(:);
    v.k3= v.k3(:);
    v.real = v.real(:);
    % v.MC = zeros(nDataUnit,70
    v.ConvK3 = reshape(v.ConvK3,[],2); % two data, might not be equally weighted
    v.PSK3 = reshape(v.PSK3,[],2); %two data, might not be equally weighted.
    v.AutoK2 = reshape(v.AutoK2,[],4);
    stimc.whole = cat(1,stimc.whole{:});
    % after collect those data,store them in the velocity folder.
    % every time you collected some new data, updata that.
    % next time, find a way to updata? no way...
    D.v = v;
    D.stimc = stimc;
    D.imageID = imageID;
    D.ndata = nDataUnit * nSpS;
    
    % data_trans fer is a temporary place to store the data, after each
    % data transfer, manually put the data from this folder into right
    % folder. mainly for the use in the cluster.
    fstore = [path.data_ppfull,vInfo(vv).name,s];
    
    if ~exist(fstore,'dir');
        mkdir(fstore);
    end
    disp(fstore);
    filenameSum = [fstore,'D.mat'];
    save(filenameSum,'D');
end


end