function analysis = plotROIsOnMask_MA2(~,~,~,~ ,~,~,~,varargin)

if length(varargin)==1
    varargin=varargin{1};
end

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% Gotta unwrap these because of how they're put in here
% flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
% params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);
dataPathsOut = [dataPathsOut{:}];

% if any(cellfun('isempty', flyResp))
%     nonResponsiveFlies = cellfun('isempty', flyResp);
%     fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
%     flyResp(nonResponsiveFlies) = [];
%     epochs(nonResponsiveFlies) = [];
%     roiMask(nonResponsiveFlies) = [];
% else
%     nonResponsiveFlies = [];
% end

%numFlies = length(flyResp);
%numFlies=1;

% if numFlies==0
%     analysis = [];
%     return
% end



% run the algorithm for each fly

%for ff = 1:numFlies

roiMask = roiMask(1);
if iscell(roiMask)
    roiMask=roiMask{1};
end

if iscell(roiMask)
    roiMask=roiMask{1};
end

if iscell(roiMask)
    roiMask=roiMask{1};
end

roiMaskHere = roiMask;

if size(roiMaskHere, 1) == 1
    roiMaskHere = repmat(roiMaskHere, size(roiMaskHere, 2), 1);
    
    linescan = true;
else
    linescan = false;
end

if ~iscell(roiMaskHere)
    roiMaskChoices = false(size(roiMaskHere));
    roiChoiceInds = unique(roiMaskHere(:));
else
    roiMaskChoices = false(size(roiMaskHere{:}));
    roiChoiceInds = unique(roiMaskHere{:});
end
roiChoiceInds(roiChoiceInds==0) = [];
%     roiMaskOutlines = cell(1, length(roiChoiceInds));
roiMaskOutlines = [];
roiInd = 1;
for i = 1:length(roiChoiceInds)
    roiMaskChoices(roiMaskHere==roiChoiceInds(i)) = true;
    bndrs = bwboundaries(roiMaskChoices);
    aux=[];
    if size(bndrs,1)>1
        for ss=1:size(bndrs,1)
            aux(ss)=size(bndrs{ss},1);
        end
        [~,b12]=max(aux);
        bndrs=bndrs(b12);
    end
    roiMaskOutlines = [roiMaskOutlines; bndrs];
    [indRows, indCols] = find(roiMaskChoices);
    roiCenterOfMass(roiInd:roiInd+length(bndrs)-1, 1) = mean(indRows);
    roiCenterOfMass(roiInd:roiInd+length(bndrs)-1, 2) = mean(indCols);
    roiMaskChoices(roiMaskHere==roiChoiceInds(i)) = false;
    roiInd = roiInd+length(bndrs);
end
n=length(roiMaskOutlines);

if exist(fullfile(dataPathsOut{1},'meanMovie.mat'),'file')
    load(fullfile(dataPathsOut{1},'meanMovie.mat'));
else
    moviePath = fullfile(dataPathsOut{1},'alignedMovie.mat');
    movieData = load(moviePath);
    if isfield(movieData,'imgFrames_ch1')
        movieData = double(movieData.imgFrames_ch1);
    else
        movieData = double(movieData.imgFrames_ch2);
    end
    
    maskPath = fullfile(dataPathsOut{1},'movieMask.mat');
    if ~isempty(dir(maskPath)) % Some movies don't have masks... not sure why
        movieMask = load(maskPath);
        movieMask = movieMask.windowMask;
        [top,left] = find(movieMask,1,'first');
        [bottom,right] = find(movieMask,1,'last');
        movieIn = movieData(top:bottom,left:right,:);
    else
        movieIn = movieData;
    end
    
    clear('movieData');
    
    if linescan
        meanMovie = mean(mean(movieIn, 3));
        meanMovie = repmat(meanMovie, size(roiMaskHere, 2), 1);
    else
        meanMovie = mean(movieIn, 3);
    end
    save(fullfile(dataPathsOut{1},'meanMovie.mat'),'meanMovie')
    
end

%MakeFigure;

imagesc(meanMovie);
set(gca,'YDir','reverse');
axis off
axis tight
axis equal
hold on

colors = jet(n);
for i = 1:length(roiMaskOutlines)
    lnOut = plot(roiMaskOutlines{i}(:, 2), roiMaskOutlines{i}(:, 1),'LineWidth',2);
    text(roiCenterOfMass(i, 2), roiCenterOfMass(i, 1), num2str(i),...
        'FontSize',12, 'HorizontalAlignment', 'center', 'Color',  [1 1 1]);
    %lnOut.Color = [1 0 0];
    lnOut.Color = [colors(i,:) 1];
end
%end

analysis = [];

