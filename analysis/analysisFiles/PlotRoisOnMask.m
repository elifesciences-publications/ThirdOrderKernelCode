function analysis = PlotRoisOnMask(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
% This function is meant to be used with ONE FLY! Otherwise it'll plot
% tons upon tons of things
flyEyes = [];
epochsForSelectivity = {'' ''};
timeShift = 0;
duration = 2000;
fps = 1;
barToCenter = 2;
% Can't instantiate this as empty because plenty of figures will have
% empty names as the default
figureName = 'omgIHopeNoFigureIsEverNamedThis';

fprintf('Two plots this time\n');
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% Gotta unwrap these because of how they're put in here
% flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
% params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);
dataPathsOut = [dataPathsOut{:}];

if any(cellfun('isempty', flyResp))
    nonResponsiveFlies = cellfun('isempty', flyResp);
    fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
    flyResp(nonResponsiveFlies) = [];
    epochs(nonResponsiveFlies) = [];
    roiMask(nonResponsiveFlies) = [];
else
    nonResponsiveFlies = [];
end

numFlies = length(flyResp);

if numFlies==0
    analysis = [];
    return
end



% run the algorithm for each fly

for ff = 1:numFlies
    epochNames = {params{ff}.epochName};
    %% Get epoch start times/durations for SelectResponsiveRois function
    numEpochs = length(params{ff});
    epochList = epochs{ff}(:, 1);
    epochStartTimes = cell(numEpochs,1);
    epochDurations = cell(numEpochs,1);
    
    for ee = 1:length(epochStartTimes)
        chosenEpochs = [0; epochList==ee; 0];
        startTimes = find(diff(chosenEpochs)==1);
        endTimes = find(diff(chosenEpochs)==-1)-1;
        
        epochStartTimes{ee} = startTimes;
        epochDurations{ee} = endTimes-startTimes+1;
    end
    
    
    
    
    
    roiMasksHere = roiMask{ff};
    if length(roiMasksHere)>1
        warning('more than one mask!');
        roiMaskHere = roiMasksHere;
    else
        roiMaskHere = roiMasksHere{1};
    end
    
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
        roiMaskOutlines = [roiMaskOutlines; bndrs];
        [indRows, indCols] = find(roiMaskChoices);
        roiCenterOfMass(roiInd:roiInd+length(bndrs)-1, 1) = mean(indRows);
        roiCenterOfMass(roiInd:roiInd+length(bndrs)-1, 2) = mean(indCols);
        roiMaskChoices(roiMaskHere==roiChoiceInds(i)) = false;
        roiInd = roiInd+length(bndrs);
    end
    
    MakeFigure;
    
    movieData = LoadAndProcessMovieData(dataPathsOut{ff}, [], [], linescan, false, false, true);
%     movieData = load(moviePath);
    movieData = double(movieData);
    
    
    maskPath = fullfile(dataPathsOut{ff},'movieMask.mat');
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
    
    imagesc(meanMovie); axis off; axis tight; axis equal;
    colormap gray; hold on;
    
    title(dataPathsOut{ff}, 'interpreter', 'none')
    
    
    
    for i = 1:length(roiMaskOutlines)
        lnOut = plot(roiMaskOutlines{i}(:, 2), roiMaskOutlines{i}(:, 1));
        text(roiCenterOfMass(i, 2), roiCenterOfMass(i, 1), num2str(i), 'HorizontalAlignment', 'center', 'Color',  [1 1 1]);
        lnOut.Color = [1 0 0];
    end
    
    
    
end

analysis = [];




end
