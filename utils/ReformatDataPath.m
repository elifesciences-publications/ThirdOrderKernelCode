clear all; close all;

dir = 'D:\Documents\data\dataPath';

resp = dirrec(dir,'.mat')';

for ii = 1:size(resp,1)
    thesePaths = load(resp{ii});
    
    paths.folders = cell(1,length(thesePaths.folders));
    paths.resp = cell(length(thesePaths.resp),1);
    paths.stim = cell(length(thesePaths.stim),1);
    paths.param = cell(length(thesePaths.stim),1);
    if isfield(thesePaths,'xtp')
        paths.xtp = thesePaths.xtp;
    end
    
    pathStart = strfind(thesePaths.resp{1},'data\')+5;
    for jj = 1:length(thesePaths.resp)
        incFolder = fileparts(thesePaths.resp{jj});
        incFolder = incFolder(pathStart:end);

        lastFolder = strfind(incFolder,'\')+1;
        genoStart = strfind(incFolder(lastFolder(end):end),'_')+1;

        genotype = incFolder(lastFolder(end)+genoStart(3)-1:end);
        searchExp = '(\w*)_\d\d?[a,p]m\w*';
        genotype = regexprep(genotype,searchExp,'$1');
        genotype = strrep(genotype, '_Holly', '');
        newFolder = [thesePaths.resp{jj}(1:pathStart-2) '\' genotype '\' incFolder(1:lastFolder(end)+genoStart(3)-3)];
        
        if strcmp(thesePaths.resp{jj}(end-2:end),'csv')
            paths.folders{jj} = newFolder;
            paths.resp{jj} = [newFolder '\respdata.csv'];
            paths.stim{jj} = [newFolder '\stimdata.csv'];
            paths.param{jj} = [newFolder '\chosenparams.mat'];
        elseif strcmp(thesePaths.resp{jj}(end-2:end),'mat')
            paths.folders{jj} = newFolder;
            paths.resp{jj} = [newFolder '\respdata.mat'];
            paths.stim{jj} = [newFolder '\stimdata.mat'];
            paths.param{jj} = [newFolder '\chosenparams.mat'];
        elseif strcmp(thesePaths.resp{jj}(end-2:end),'txt')
            paths.folders{jj} = newFolder;
            paths.resp{jj} = [newFolder '\respdata.txt'];
            paths.stim{jj} = [newFolder '\stimdata.txt'];
            paths.param{jj} = [newFolder '\chosenparams.mat'];
        else
            disp('weird extension');
        end
    end
    
    save(resp{ii},'-struct','paths');
end