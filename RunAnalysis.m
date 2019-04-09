function D = RunAnalysis(varargin)
    %% this was written by Matt Creamer the Great (praise him) and it is a
    % golden piece of glory in an otherwise dull world. This .m will call
    % the analysis function and determine if a meta analysis is performed
    % as well
          
    persistent dataPath flyResp epochs params stim argumentOut dataRate dataType interleaveEpoch numTotalFlies flyIdsSel vararginPrev

    D = [];
    analysisFile = [];
    selectedEpochs = {'' ''};

    sysConfig = GetSystemConfiguration();
    getUniqueFliesFlag = true;
    repeatDataPreprocess = true;
    if any(strcmp(varargin, 'repeatDataPreprocess'))
        repeatDataPreprocess = varargin{[false strcmp(varargin, 'repeatDataPreprocess')]};
        varargin([false strcmp(varargin, 'repeatDataPreprocess')]) = [];
        varargin(strcmp(varargin, 'repeatDataPreprocess')) = [];
    end
    
    vararginPrev = varargin;

    % randomize seedstate
    seedState = rng('shuffle');
    
    
    if isempty(flyResp) || ~isequal(varargin, vararginPrev) || repeatDataPreprocess
        
        vararginPrev = varargin;
        argumentOut = {};
        for ii = 1:2:length(varargin)
            eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
        end
        %% get path to the data if it doesn't exist
        dataFolderPath = sysConfig.dataPath;
        
        if isempty(dataPath)
            dataPath = UiPickFiles('FilterSpec',dataFolderPath,'Prompt','Choose folders containing the files to be analyzed');
        else
            if ~iscell(dataPath)
                dataPath = {dataPath};
            end
        end
        
        % check whether this is imaging or behavioral data
        behavioralData = 1;
        imagingData = 0;
        ephysData = 0;
        
        fullDirectory = cell(1,length(dataPath));
        
        for dd = 1:length(dataPath)
            if isempty(regexp(dataPath{dd}(1:3),'[A-z]\:[\\\/]','once')) && isempty(regexp(dataPath{dd}(1:2),'\\\\|\/[A-z]','once'))
                fullDirectory{dd} = fullfile(dataFolderPath,dataPath{dd});
            else
                fullDirectory{dd} = dataPath{dd};
            end
        end
        
        if ~isempty(DirRec(fullfile(fullDirectory{1},'alignedMovie.mat')))
            behavioralData = 0;
            imagingData = 1;
        end
        
        if ~isempty(DirRec(fullDirectory{1},'.abf'))
            behavioralData = 0;
            ephysData = 1;
        end
        
        
        
        %% organize the input data
        if behavioralData
            [flyResp,epochs,params,stim,flyIds,numTotalFlies] = ReadBehavioralData(fullDirectory,varargin{:});
            dataRate = 60;
            interleaveEpoch = 1;
            dataType = 'behavioralData';
        end
        if imagingData
            % read in imaging data by hacking Emilio's output
            flyResp = []; % If we ever get in here, we have to reset everything sadly.
            [flyResp,epochs,params,stim,flyIds,selectedEpochs,dataRate,interleaveEpoch,argumentOut] = ReadImagingData(dataPath,varargin{:});
            dataType = 'imagingData';
            numTotalFlies = size(flyResp,2);
            % 		[flyResp,epochs,params,stim,flyIds,selectedEpochs,argumentOut] = ReadImagingData(dataPath,varargin{:});
            %         varargin = [varargin argumentOut];
        elseif ephysData
            [flyResp,epochs,params,stim,flyIds,dataRate] = ReadEphysData(fullDirectory,varargin{:});
            interleaveEpoch = 1;
            dataType = 'ephysData';
            numTotalFlies = size(flyResp,2);
        end
        
        %% run each analysis file
        % get snips, do everything
        if isempty(flyResp)
            return
        end
        
        %     if any(strcmp(varargin, 'roiSizes'))
        %         roiMasksDd = varargin{find(strcmp(varargin,'roiSizes'))+1};
        %         [flyResp,stim,epochs, roiMasksDd] = GetUniqueFlies(flyResp,stim,epochs,flyIds, roiMasksDd);
        %         varargin{find(strcmp(varargin,'roiSizes'))+1} = roiMasksDd;
        %     else
        if getUniqueFliesFlag
            [flyResp,stim,epochs, params, argumentOut{2:2:end}] = GetUniqueFlies(flyResp,stim,epochs,flyIds, params, argumentOut{2:2:end});
            flyIdsSel = unique(flyIds, 'stable');
        else
            flyIdsSel = flyIds;
        end
        %     end
    else
        % Still want to evaluate varargins so we can get here...
        for ii = 1:2:length(varargin)
            eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
        end
    end
    
    %% get the path to the analysisFile
    if isempty(analysisFile)
        rootFolder = fileparts(which('RunStimulus'));
        
        analysisFile =  UiPickFiles('FilterSpec',fullfile(rootFolder,'analysis','analysisFiles'),'Prompt','Select parameter files to run');
        
        if isempty(analysisFile)
            error('no analysis file chosen');
        end
    end
    
    if ~iscell(analysisFile)
        analysisFile = {analysisFile};
    end

    % loop through variations of data to run the same analysis on
    a=tic;
    
    for dd = 1:size(flyResp,1)
        % loop through analysis files and run them
        for aa = 1:length(analysisFile)
            analysisFunction = str2func(analysisFile{aa});
            argumentInAnalysis = argumentOut;
            
            
            nonResponsiveFlies = cellfun('isempty', flyResp(dd, :));
            flyRespAnalysis = flyResp(dd, ~nonResponsiveFlies);
            epochsAnalysis = epochs(dd, ~nonResponsiveFlies);
            paramsAnalysis = params(dd, ~nonResponsiveFlies);
            stimAnalysis = stim(dd, ~nonResponsiveFlies);
            argumentInAnalysis(2:2:end) = cellfun(@(val) val(dd, ~nonResponsiveFlies), argumentOut(2:2:end), 'UniformOutput',false);
            fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
                
            if ~isempty(flyRespAnalysis)
                D.analysis{aa,dd} = analysisFunction(flyRespAnalysis,epochsAnalysis,paramsAnalysis,stimAnalysis,dataRate,dataType,interleaveEpoch,'numTotalFlies',numTotalFlies,varargin{:},argumentInAnalysis{:}, 'iteration', dd);
            else
                D.analysis{aa,dd} = [];
            end
            fliesUsed = flyIdsSel(~nonResponsiveFlies);
            D.analysis{aa, dd}.fliesUsed = fliesUsed;
%             D.analysis{aa} = analysisFunction(flyRespUnique(dd,:),epochsUnique(dd,:),params,stimUnique(dd,:),'selectedEpochs',selectedEpochs(dd,:),varargin{:});
        end
    end
    disp(['analysis file took ' num2str(toc(a)) ' seconds to run']);
    
    % Important script that must be run for analysis to succeed
    fourierGAL4SplineAnalysis;
end
