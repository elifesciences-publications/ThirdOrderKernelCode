function [timeByRois,epochs,params,stim,flyIds,epochsForSelectivity,dataRate,interleaveEpoch,outArguments] = ReadImagingData(initialDataPaths,varargin)
    

    roiExtractionFile = 'IcaRoiExtraction';
    roiSelectionFile = 'RoiSelectionSizeAndResp';
    forceRois = 0;
    epochsForSelectivity = {'Square Right' 'Square Left' 'Right Light Edge' 'Right Dark Edge'; 'Square Left' 'Square Right' 'Left Light Edge' 'Left Dark Edge'};
    epochsForSelectivity = {'Square Right' 'Square Left'; 'Square Left' 'Square Right'};
    epochsForIdentification = '';
    progRegSplit = 0;
    filterMovie = 0;
    takeSqrtICA = false;
    calcDFOverFByRoi = true;
    backgroundSubtractMovie = true;
    useAlignedData = true;
    interleaveEpoch = [];
    noTrueInterleave = false;
    perRoiDfOverFCalcFunction = 'CalculatedDeltaFOverFByROI';
    stimulusResponseAlignment = false;
    percMotionThresh = 5;

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    % extract a list of data paths from the ones provided.
    if iscell(initialDataPaths)
        dataPath = initialDataPaths;
    else
        dataPath = {initialDataPaths};
    end

    % assume each different path is a different fly. We'll combine
    % duplicated flies later
    numFlies = length(dataPath);

    %% get roi extraction function
    roiExtractionFunction = str2func(roiExtractionFile);
    if ~isempty(roiSelectionFile)
        roiSelectionFunc = str2func(roiSelectionFile);
    else
        roiSelectionFunc = '';
        epochsForSelectivity = {''};
    end
    perRoiDfOverFCalcFunction = str2func(perRoiDfOverFCalcFunction);

    %% initialize output variables
    % cell array of fly responses. {epoch selectivity}{flies}{ROIs}[time
    % trials TW]
    numRoiExtractions = size(epochsForSelectivity,1);
    timeByRois = cell(numRoiExtractions,numFlies);
    roiMask = cell(numRoiExtractions,numFlies);
    timeByRoisInitial = cell(1,numFlies);
    epochs = cell(numRoiExtractions,numFlies);
    stim = cell(numRoiExtractions,numFlies);
    roiStimIndexes = cell(numRoiExtractions, numFlies);
    flyEyes = cell(1,numFlies);
    flyEpochsForSelection = cell(numRoiExtractions,numFlies);
    params = cell(1,numFlies);
    %%

    runDetails = cell(numFlies,1);

    fliesToUse = true(1,numFlies);

    %% run feature extraction on each imaging data set
    % for each different type of epoch selectivity (i.e. left vs right or
    % light edge vs dark edge) run on every data path. Pretend each path is
    % a unique fly, later on we'll combine duplicated flies.
    for ff = 1:numFlies
        % We're gonna reset forceRois every time here, because it might get
        % changed throughout the loop...
        forceRois = varargin{[false strcmp(varargin, 'forceRois')]};
        totalProcessTime = tic;
        %% get parameter file
        % assume all parameter files are the same
        paramPath = fullfile(dataPath{ff},'stimulusData','chosenparams.mat');
        paramsHere = load(paramPath);
        paramsHere = paramsHere.params;
        params{ff} = paramsHere;
        numEpochs = length(paramsHere);
        dataPathsOut{ff} = dataPath(ff);

        if isfield(paramsHere, 'nextEpoch')
            interleaveEpoch = paramsHere(end).nextEpoch;
        elseif isfield(paramsHere, 'epochName') && any(strcmp({paramsHere.epochName}, 'Gray Interleave'))
            interleaveEpoch = find(strcmp({paramsHere.epochName}, 'Gray Interleave'));
            % This is done solely to allow plotting of traces to not
            % conflate epoch 1 with the beginning of the stimulus
            % presentation (which would happen when below we set epochs for
            % non-stimulus presentation time points to interleaveEpoch(1)
            if interleaveEpoch(1) == 1  && length(interleaveEpoch)>1
                interleaveEpoch = interleaveEpoch(end:-1:1);
            end
        end

        %% load fly IDs
        runDetailsPath = fullfile(dataPath{ff},'stimulusData','runDetails.mat');
        if exist(runDetailsPath,'file') == 2
            runDetails{ff} = load(fullfile(dataPath{ff},'stimulusData','runDetails.mat'));
        else
            flyId = AssignFlyId();
            runDetails{ff}.flyId = flyId;
            save(runDetailsPath,'flyId');
        end

        %% grab the fly eye if progressive/regressive diffs are important
        % Key here is that we're analyzing progressive direction first and
        % then the regressive direction, no matter which eye gets
        % surgeried
        if progRegSplit
            [epochsForSelectionForFly, flyEye{1}, vararginOut] = AdjustEpochsForEye(dataPath{ff}, epochsForSelectivity, epochsForIdentification, varargin{:});
            epochsForIdentificationForFly = vararginOut([false strcmp(vararginOut, 'epochsForIdentificationForFly')]);
            if isempty(epochsForIdentificationForFly)
                clear epochsForIdentificationForFly
            else
                epochsForIdentificationForFly = epochsForIdentificationForFly{1};
            end
            varargin = vararginOut;
            flyEyes{ff} = flyEye;
        else

            if exist('epochsForIdentification', 'var')
                if any(strcmp(varargin, 'epochsForIdentificationForFly'))
                    varargin{[false strcmp(varargin, 'epochsForIdentificationForFly')]} = epochsForIdentification;
                else
                    varargin{end+1} = 'epochsForIdentificationForFly';
                    varargin{end+1} = epochsForIdentification;
                end
            end
            epochsForSelectionForFly = epochsForSelectivity;
            flyEyes{ff} = {GetEyeFromDatabase(dataPath{ff})};
        end

        %% check whether analysis was recently done

        if ~forceRois
            changeableVals = {'filterMovie', filterMovie, 'takeSqrtICA', takeSqrtICA, 'calcDFOverFByRoi', calcDFOverFByRoi, 'backgroundSubtractMovie', backgroundSubtractMovie, 'useAlignedData', useAlignedData, 'noTrueInterleave', noTrueInterleave, 'calcDFOverFByRoi', calcDFOverFByRoi, 'perRoiDfOverFCalcFunction', perRoiDfOverFCalcFunction, 'interleaveEpoch', interleaveEpoch};
            [lastRoi, forceRois] = LoadLastSavedRoiFile(dataPath{ff}, changeableVals{:}, varargin{:});
            if ~isempty(lastRoi)
                % if everything checks out, load the data from the file
                timeByRoisInitial(ff) = lastRoi.timeByRoisInitial;
                epochList = lastRoi.epochList;
                %                         params = lastRoi.params;
                for k = 1:size(stim, 1)
                    stim{k, ff} = lastRoi.stim;
                end
                %  stim{ff} = lastRoi.stim;
                runDetails{ff} = lastRoi.runDetails;
                roiMaskInitial = lastRoi.roiMaskInitial;
                epochDurations = lastRoi.epochDurations;
                epochStartTimes = lastRoi.epochStartTimes;
                if isfield(lastRoi, 'movieSizeFull')
                    movieSizeFull = lastRoi.movieSizeFull;
                else
                    % So that we don't have to rerun extraction on all the
                    % files we've done 'til now, we momentarily use the
                    % fact that all 2D sweeps were taken with a 256 x-axis
                    % value. movieSizeFull is only used for
                    % RemoveMotionArtifacts, and that only needs the number
                    % of columns in the movie. For now.
                    movieSizeFull = [1 256];
                end
            end
        end


        %% load image description
        imageDescription = LoadImageDescription(dataPath{ff});
        if isempty(imageDescription)
            forceRois = varargin{[false strcmp(varargin, 'forceRois')]};
            continue
        else
            zoomLevel = imageDescription.acq.zoomFactor;
            linescan = ~imageDescription.acq.scanAngleMultiplierSlow;
            if linescan
                dataRate = imageDescription.acq.frameRate; % imaging frequency
            else
                dataRate = imageDescription.acq.frameRate; % imaging frequency
            end
        end


        %% Read in photodiode
        % Discarding the flyback line means the lines per frame go from,
        % say, 128 to 127, because that last line happens when the mirrors
        % are repositioning to the top corner of the frame
        [photodiodeData, highResLinesPerFrame] = ReadInPhotodiode(imageDescription, dataPath{ff});

        %% get epoch list
        [epochBegin, epochEnd, endFlash, flashBeginInd] = GetStimulusBounds(photodiodeData, highResLinesPerFrame, dataRate, linescan);

        %% Get alignment information
        filesInMainDirectory = dir(dataPath{ff});
        fileNames = {filesInMainDirectory.name};
        alignmentFile = fileNames(~cellfun('isempty', strfind(fileNames, 'disinterleaved_alignment')));
        alignmentData = dlmread(fullfile(dataPath{ff}, alignmentFile{1}), '\t');
        alignmentData = alignmentData(round(epochBegin):round(epochEnd),:);

        %% get stimulus file
        stimPath = fullfile(dataPath{ff},'stimulusData','stimdata.mat');
        try
            stimImage = load(stimPath);
        catch loadError
            if strcmp(loadError.identifier, 'MATLAB:load:couldNotReadFile')
                [~, stimImage.stimData] = GrabStimulusData(dataPath{ff}, imageDescription);
            end
        end

        %% extract ROIs
        if forceRois
            extraVars = struct();
            lastRoiPath = fullfile(dataPath{ff},'savedAnalysis',[roiExtractionFile datestr(now,'_dd_mm_yy') '.mat']);
            %% load movie data
            [filteredMovie, movieSizeFull, extraVarsOut] = LoadAndProcessMovieData(dataPath{ff}, alignmentData, zoomLevel, linescan, filterMovie, backgroundSubtractMovie, useAlignedData, percMotionThresh, varargin{:});
            extraVars = CombineStructures(extraVars, extraVarsOut);

            %% Check to see if there was odd noise at the end of the stimulus
            if length(endFlash)>1
                warning(['Something might be wrong because more than one flash was 20 projector\n'...
                    'frames long--a length which typically indicates the end of the stimulus.\n'...
                    'This happened with the data path for fly %d:\n\n'...
                    '%s \n\n'...
                    'The image frames found as ending frames were [%s] and the first one was counted,\n'...
                    'unless there was lots of spacing between the first and second, as the actual end frame'], ff, dataPath{ff}, num2str(flashBeginInd(endFlash)'/highResLinesPerFrame));
            end

            epochTimes = stimImage.stimData(:,1);
            epochVals = stimImage.stimData(:,3);

            epochTimes(epochVals==0) = [];
            epochVals(epochVals==0) = [];
            % Get rid of any stimData epochs that occurred past the end of
            % the last flash in the recording
            epochVals(epochTimes>(epochEnd-epochBegin)/dataRate) = [];
            epochTimes(epochTimes>(epochEnd-epochBegin)/dataRate) = [];

            epochList = round(interp1(epochTimes,epochVals,linspace(epochTimes(1),epochTimes(end),round(epochEnd)-round(epochBegin)+1),'nearest'))';

            %% cut out beginning and end of recording where there was no stimulus
            filteredMovie = filteredMovie(:,:,round(epochBegin):round(epochEnd));


            %% get epoch durations
            % these may fluctuate a bit so save the duration of each trial
            epochStartTimes = cell(numEpochs,1);
            epochDurations = cell(numEpochs,1);

            for ee = 1:length(epochStartTimes)
                chosenEpochs = [0; epochList==ee; 0];
                startTimes = find(diff(chosenEpochs)==1);
                endTimes = find(diff(chosenEpochs)==-1)-1;

                epochStartTimes{ee} = startTimes;
                epochDurations{ee} = endTimes-startTimes+1;
            end

            %% takes in a spatially and temporally aligned movie and
            % converts it to delta F over F
            %             interleaveEpoch = [];
            deltaFOverF = CalcDeltaFOverF(filteredMovie,epochStartTimes,epochDurations,interleaveEpoch, takeSqrtICA, noTrueInterleave);

            %% remove motion artifacts for roi extraction
            %             deltaFOverFMotionFree = InterpolateHighMotionFrames(deltaFOverF,alignmentData,zoomLevel);
            deltaFOverFMotionFree = deltaFOverF;
            %% extract ROIs
            roiExtractionTime = tic;
            try
                [timeByRoisInitial{ff},roiMaskInitial,extraVarsOut] = roiExtractionFunction(filteredMovie,deltaFOverFMotionFree,epochStartTimes,epochDurations,params{ff},varargin{:});
                      extraVars = CombineStructures(extraVars, extraVarsOut);

                numRois = max(max(roiMaskInitial));
                movieSize = size(deltaFOverF);
                deltaFFlattened = reshape(deltaFOverF,movieSize(1)*movieSize(2),movieSize(3));

                timeByRoisInitial{ff} = zeros(movieSize(3),numRois);
                for ii = 1:numRois
                    selection = (roiMaskInitial == ii);
                    timeByRoisInitial{ff}(:,ii) = mean(deltaFFlattened(selection(:),:),1)';
                end
            catch err
                if strcmp(err.identifier, 'MATLAB:eigs:ARPACKroutineErrorMinus14')
                    warning('ICA couldn''t find any ROIs because of the following error:\n%s', err.message);
                    timeByRoisInitial{ff} = [];
                    roiMaskInitial = zeros(size(filteredMovie,1), size(filteredMovie,2));
                else
                    keyboard;
                end
            end
            clear('deltaFOverFMotionFree','deltaFOverF','backgroundSubtractedMovie');

            %% If we calculate dF/F by ROI fitting instead of pixel-wise, do this
            if calcDFOverFByRoi
                timeByRoisInitial{ff} = perRoiDfOverFCalcFunction(filteredMovie, roiMaskInitial,epochStartTimes,epochDurations,interleaveEpoch, noTrueInterleave, linescan);
            end
            disp(['ROI extraction took ' num2str(toc(roiExtractionTime)) ' seconds']);
            
            %% Output stim data
            for k = 1:size(stim, 1)
                stim{k, ff} = stimImage.stimData;
            end

            %% save the last analysis performed on this data set
            lastRoi.timeByRoisInitial = timeByRoisInitial(ff);
            lastRoi.epochList = epochList;
            lastRoi.params = params;
            lastRoi.stim = stimImage.stimData;
            lastRoi.runDetails = runDetails{ff};
            lastRoi.roiExtractFile = roiExtractionFile;
            lastRoi.roiMaskInitial = roiMaskInitial;
            lastRoi.epochStartTimes = epochStartTimes;
            lastRoi.epochDurations = epochDurations;
            lastRoi.movieSizeFull = movieSizeFull;
            extraVars.takeSqrtICA = takeSqrtICA;
            extraVars.calcDFOverFByRoi = calcDFOverFByRoi;
            extraVars.noTrueInterleave = noTrueInterleave;
            extraVars.interleaveEpoch = interleaveEpoch;
            extraVars.perRoiDfOverFCalcFunction = perRoiDfOverFCalcFunction;
            extraVars.calcDFOverFByRoi = calcDFOverFByRoi;
            if ~isempty(extraVars)
                lastRoi.extraVars = extraVars;
            end

            if ~exist(fileparts(lastRoiPath),'dir')
                mkdir(fileparts(lastRoiPath));
            end
            save(lastRoiPath,'lastRoi');%% Calculate dF/F by ROI


        end



        %% Get rid of motion artifacts
        if ~isempty(timeByRoisInitial{ff})
            timeByRoisInitial{ff} = RemoveMotionArtifacts(timeByRoisInitial{ff}, alignmentData, zoomLevel, movieSizeFull, linescan, percMotionThresh);
        else
            fliesToUse(ff) = false;
        end
        
        



        %% select ROIs
        roiSelectionTime = tic;
        if ~isempty([timeByRoisInitial{ff}])
            if ~isempty(roiSelectionFunc)
                [timeByRois(:,ff),roiMask(:,ff)] = roiSelectionFunc(timeByRoisInitial{ff},roiMaskInitial,epochStartTimes,epochDurations,epochsForSelectionForFly,params{ff},interleaveEpoch,varargin{:});
                disp(['ROI selection took ' num2str(toc(roiSelectionTime)) ' seconds']);

                for ee = 1:size(epochsForSelectionForFly,1)
                    epochs{ee,ff} = repmat(epochList,[1 size(timeByRois{ee,ff},2)]);
                    flyEpochsForSelection(ee, ff) = {epochsForSelectionForFly(ee, :)};
                end
                if isempty([timeByRois{:,ff}])
                    disp(['fly #' num2str(ff) ' had no ROIs in any selection']);
                    fliesToUse(ff) = false;
                end
            else
                timeByRois(ff) = timeByRoisInitial(ff);
                epochs{ff} = repmat(epochList,[1 size(timeByRois{1,ff},2)]);
                flyEpochsForSelection(ff) = {epochsForSelectionForFly};
                roiMask{ff} = {roiMaskInitial};
            end
        else
            disp(['fly #' num2str(ff) ' had no ROIs in any selection']);
            fliesToUse(ff) = false;
        end
        
        %% Do alignment
		if ~isempty(cat(2, timeByRois{:, ff}))
            for selEpochs = 1:size(epochsForSelectionForFly, 1);
                roiTraces = timeByRois{selEpochs, ff};
                %% Calculate each ROIs center of mass in the frame of the original movie
                roiCenterOfMass = zeros(size(roiTraces, 2), 2);
                for i = 1:size(roiCenterOfMass,1)
                    [indRows, indCols] = find(roiMask{selEpochs, ff}{1}==i);
                    movieFrameSize = size(roiMask{selEpochs, ff}{1});
                    rowOffset = (movieSizeFull(1)-movieFrameSize(1))/2;
                    colOffset = (movieSizeFull(2)-movieFrameSize(2))/2;
                    roiCenterOfMass(i, :) = [mean(indRows)+rowOffset mean(indCols)+colOffset];
                end
                
                %% Aligning response with stimulus
                % We can choose to run a high fidelity alignment of the time
                % trace with the stimulus (for such purposes as kernel
                % extraction, for example)
                if stimulusResponseAlignment
                    % This is for older data where movieSizeFull wasn't
                    % appropriately saved
                    if size(movieSizeFull,3)==1
                        movieSizeFull(3) = length(dlmread(fullfile(dataPath{ff}, alignmentFile{1}), '\t'));
                    end
                    if ~isempty(timeByRois{selEpochs, ff})
                        [timeByRois{selEpochs, ff}, roiStimIndexes{selEpochs, ff}, epochList, fliesToUse(ff)] = MapAlignedStimulusToResponse(timeByRois{selEpochs, ff}, stimImage.stimData, dataPath{ff}, roiCenterOfMass, movieSizeFull, dataRate, linescan, photodiodeData, highResLinesPerFrame);
                    end
                end
            end
        end


        disp(['fly ' num2str(ff) '/' num2str(numFlies) ' processed and total time was ' num2str(toc(totalProcessTime)) ' seconds']);
    end

    runDetails = runDetails(fliesToUse);
    epochs = epochs(:,fliesToUse);
    stim = stim(:,fliesToUse);
    timeByRois = timeByRois(:,fliesToUse);
    roiStimIndexes = roiStimIndexes(:, fliesToUse);
    flyEyes = repmat(flyEyes(fliesToUse), [size(timeByRois, 1), 1]);
    roiMask = roiMask(:, fliesToUse);
    flyEpochsForSelection = flyEpochsForSelection(:, fliesToUse);
    params = repmat(params(fliesToUse), [size(timeByRois, 1), 1]);
    dataPathsOut = repmat(dataPathsOut(fliesToUse), [size(timeByRois, 1), 1]);


    outArguments{1} = 'flyEyes';
    outArguments{end+1} = flyEyes;
    outArguments{end+1} = 'roiMask';
    outArguments{end+1} = roiMask;
    outArguments{end+1} = 'epochsForSelection';
    outArguments{end+1} = flyEpochsForSelection;
    outArguments{end+1} = 'dataPathsOut';
    outArguments{end+1} = dataPathsOut;
    outArguments{end+1} = 'roiStimIndexes';
    outArguments{end+1} = roiStimIndexes;

    if ~isempty(dataPathsOut)
        flyIds = GetFlyIds([dataPathsOut{1, :}]);
    else
        flyIds = [];
    end
end