dir = 'D:\Documents\data';

resp = dirrec(dir,'respdata*')';
pathStart = strfind(resp{1},'data\')+5;
for ii = 1:size(resp,1)
    incFolder = fileparts(resp{ii});
    incFolder = incFolder(pathStart:end);
    
    lastFolder = strfind(incFolder,'\')+1;
    genoStart = strfind(incFolder(lastFolder(end):end),'_')+1;
    
    genotype = incFolder(lastFolder(end)+genoStart(3)-1:end);
    newFolder = [dir '\' genotype '\' incFolder(1:lastFolder(end)+genoStart(3)-3)];
    
    movefile([dir '\' incFolder],newFolder);
end