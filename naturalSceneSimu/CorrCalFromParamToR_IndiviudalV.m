function  [rIndiviudalV,wIndiviudalV,mutRIndiviudalV,edge] = CorrCalFromParamToR_IndiviudalV(param,varargin)
% load the data, that is the value for the velocity..
vBinMethod = 'fullRange_absolute';

for ii = 1:2:length(varargin)
    eval([ varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

path = param.path;
s = path.s;
vInfo = SearchFolder(path.data);
fstore = [path.data_ppfull,vInfo.name,s];
filenameSum = [fstore,'D.mat'];
load(filenameSum)

% use arrayfun to get the result for different velocity...

% there are differemt ways to study the relationship between velocity and
% estimated velocity.
switch vBinMethod
    case 'smallRange'
        % key point is to get the interested velocity out.
        edge = -param.velocity.maxUniform:100:param.velocity.maxUniform;
        % ind has length of velocity, and will give out which value belongs
        % to which group.
        ind = discretize(D.v.real,edge);
    case 'smallRange_absolute'
        % modify it.
        edge = 0:100:param.velocity.maxUniform;
        ind = zeros(size(D.v.real));
        for ii = 1:1:length(edge) - 1
            ind(abs(D.v.real) >= edge(ii) & abs(D.v.real) < edge(ii + 1)) = ii;
        end
        % change the edge, the edge should be asymetric around zero here.
    case 'fullRange'
        % it is wiered to do this.
        %         edge = 0:100:param.velocity.maxUniform;
        %         ind = zeros(size(D.v.real));
        %         for ii = 1:1:length(edge) - 1
        %             ind(D.v.real >= edge(ii) & D.v.real < edge(ii + 1)) = ii;
        %         end
    case 'fullRange_absolute'
        edge = 0:100:param.velocity.maxUniform;
        ind = false(length(D.v.real),length(edge) - 1);
        % things are little different here. you might want to use 1 or 0 to
        for ii = 1:1:length(edge) - 1
            ind(abs(D.v.real) < edge(ii + 1),ii) = true;
        end
        
end

nBin = length(edge) - 1;
v = cell(nBin,1);
r = cell(nBin,1);
weight = cell(nBin,1);
mutR = cell(nBin,1);
% you might have to put absolute value into your code....

% for high velocity, it could not differentiate between those very well.
for ii = 1:1:nBin
    switch vBinMethod
        case 'smallRange'
             v{ii} = [D.v.real(ind==ii),D.v.k2(ind==ii),D.v.k3(ind==ii)];
        case 'smallRange_absolute'
             v{ii} = [D.v.real(ind==ii),D.v.k2(ind==ii),D.v.k3(ind==ii)];
        case 'fullRange'
             v{ii} = [D.v.real(ind(:,ii)),D.v.k2(ind(:,ii)),D.v.k3(ind(:,ii))];
        case 'fullRange_absolute'
             v{ii} = [D.v.real(ind(:,ii)),D.v.k2(ind(:,ii)),D.v.k3(ind(:,ii))];
    end
   
    [r{ii},weight{ii},mutR{ii}] = CorrCalFromVtoR( v{ii});
end

% it is a cell and cell array... for different velocity, you could turn
% it into a better shape...


rIndiviudalV = cellfun(@getfield,r,repmat({'k2'},size(r)));
rIndiviudalV = cat(2,rIndiviudalV,cellfun(@getfield,r,repmat({'k3'},size(r))));
rIndiviudalV =cat(2,rIndiviudalV,cellfun(@getfield,r,repmat({'k2plusk3'},size(r))));
rIndiviudalV =cat(2,rIndiviudalV,cellfun(@getfield,r,repmat({'best'},size(r))));

wIndiviudalV = reshape(cell2mat(weight),2,nBin)';
mutRIndiviudalV = cell2mat(mutR);
end

%% cellfun arrayfun strucfun