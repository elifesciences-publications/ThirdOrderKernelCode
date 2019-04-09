function Z = twoPhotonMaster( varargin )
%
%   Do I contradict myself? 
%   Very well then . . . . I contradict myself; 
%   I am large . . . . I contain multitudes. 

    %% Load Parameters
    % defaults stored in matlab script
    twoPhotonDefaultParams
    % read varargin into Z.params structure
    for ii = 1:2:length(varargin)
        eval(['Z.params.' varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if Z.params.alignOnly
        Z.params.grabRoi = false;
        Z.params.mapsToRoiData=false;
        Z.params.filterRoiTraces = false;
        Z.params.saveROIdata = false;
        Z.params.stashROIdata = false;
    end
    %% Select File    
    if isfield(Z.params,'filename')
        Z.params.filename(Z.params.filename=='\') = '\';
        % file from varargin
        [pathName, name, ext] = fileparts(Z.params.filename);
        if ~strcmp(ext, '.tif')
            fn = [name ext '.tif'];
            pathName = [Z.params.filename filesep];
            name = [name ext];
        else
            fn = [name ext];
            pathName = [pathName filesep];
        end
    else
        % or else grab the file
        [fn, pathName] = uigetfile('*.tif;*.mat', 'Choose your tif file');
        [~, name, ~] = fileparts([pathName fn]);
    end
    pathName(pathName == '\') = '\';
    Z.params.pathName = pathName;
    Z.params.fn = fn;
    Z.params.name = name;
    cd(pathName)
    Z.params.matFiles = dir('*.mat');
    tic
    
    fprintf('File: %s\n', pathName);
    %% Pre-analysis: run or bypass   
    if Z.params.alignOnly
        Z.params.grabRoi = false;
        Z.params.mapsToRoiData=false;
        Z.params.filterRoiTraces = false;
        Z.params.cullRoiTraces = false;
    end
    
    if Z.params.force_new_ROIs || ~any(strcmp([name '.mat'], {Z.params.matFiles.name})) || (any(strcmp([name '.mat'], {Z.params.matFiles.name})) && isempty(whos('-file', [name '.mat'], 'Z')))
        fprintf('Running pre-analysis.\n'); toc
        
        if ~isfield(Z.params, 'zstack') || ~Z.params.zstack
            %% Get stimulus data
            Z.stimulus = loadStimulusData(Z);
        end
        
        %% input pathName -> movie saved in Z
        Z = grabAlignMovie(Z);   
       
%         Z = CorrectPDWithStimData(Z);
        % save Z before ROI selection
        saveVariables.Z = Z;
%         saveOrAppendMatFile([name '.mat'], saveVariables);
        fprintf('Z saved up through aligned movie.\n'); toc
%         
%         %% Look at "pre-stimulus" cardinal directions
%        % TO DO WE NEED TO GENERALIZE THIS!!!!!!!! (It's currently only good for T4T5)
%         if isfield(Z.params,'differentialEpochs') && ~Z.params.linescan && (~isfield(Z.params, 'zstack') || (isfield(Z.params, 'zstack') && ~Z.params.zstack))
%             Z = diffEp(Z);
%         end 

        %% Create ROIs
        if Z.params.grabRoi
            Z = grabRoi(Z);
        end
        
        %% Create ROI traces
        if Z.params.mapsToRoiData
            Z = mapsToRoiData(Z);
        end

        %% Save      
        if Z.params.saveROIdata 
            saveVariables.Z = Z;
            saveOrAppendMatFile([name '.mat'], saveVariables);
            fprintf('Z saved up through filtered traces.\n'); toc
        else
            fprintf('Filtered traces extracted but not saved in Z.\n'); toc
        end
        
        if Z.params.stashROIdata
            if ~isempty(Z.params.roiStashName)
                Z.params.roiStashName = [ '_' Z.params.roiStashName ];
            end                
            saveROI.ROI = Z.ROI;
            saveROI.params = Z.params;
            saveROI.rawTraces = Z.rawTraces;
            saveName = [ Z.params.ROImethod datestr(now,'_dd_mm_yy') Z.params.roiStashName  ];
            if ~isdir('/ROIs')
                mkdir('ROIs');
            end
            currDir = cd;
            cd ROIs
            save(saveName,'saveROI');
            cd(currDir)
        end
        

        %% Save control figure analysis%% Filter ROI traces
        try 
            if Z.params.filterRoiTraces
                Z = filterRoiTraces(Z);
                if Z.params.controlFigs
                    tp_controlFigs(Z);
                end
                fprintf('Control figures created and saved.\n');
            end
        catch err
            warning('Error with control figures: %s', err.identifier);
        end
        toc

    else  
        fprintf('Bypassing pre-analysis. \n'); toc
        load([name '.mat'],'Z'); 
        % unfortunately we have to read in varargin again here because we
        % just overwrote Z.params
        twoPhotonDefaultParams
        for ii = 1:2:length(varargin)
            eval(['Z.params.' varargin{ii} '= varargin{' num2str(ii+1) '};']);
        end
        Z.params.pathName = pathName;
        Z.params.fn = fn;
        Z.params.name = name;
        Z.params.matFiles = dir('*.mat');
        currDir = cd;
        roiFilesDir = fullfile(currDir, 'ROIs');
        roiFiles = dir(roiFilesDir);
        roiFileNames = {roiFiles.name};
        roiFilesFromDesiredMethod = ~cellfun('isempty', strfind(roiFileNames, Z.params.ROImethod));
%         strcmp({roiFilesDir.name})
        if isfield(Z.params, 'loadDifferentROIs') && Z.params.loadDifferentROIs
%             fprintf('Z loaded. Please select which ROI set to use.\n'); 
            while ~exist('roiPathCell','var') || length(roiPathCell) ~= 1
                fprintf('\n\nPlease select one ROI file.')
                roiPathCell = UiPickFiles('FilterSpec',fullfile( currDir, 'ROIs' ),'Prompt','Select ROI set to use.');
            end
            roiPath = roiPathCell{1};
            load(roiPath);
            Z.ROI = saveROI.ROI;
            Z.rawTraces = saveROI.rawTraces;
        elseif isfield(Z.params, 'roiPath')
            load(Z.params.roiPath);
            Z.ROI = saveROI.ROI;
            Z.rawTraces = saveROI.rawTraces;
            fprintf('\n\nLoaded ROIs from roiPath.\n');
        elseif any(roiFilesFromDesiredMethod)
            roiFiles = roiFileNames(roiFilesFromDesiredMethod);
            correctParameters = false;
            % We grab the latest ROIs saved using this method
            while ~correctParameters
                if isempty(roiFiles)
                    % Otherwise we've gotta rerun twoPhotonMaster and get some new
                    % ROIs!
                    Z = twoPhotonMaster(varargin{:}, 'force_new_ROIs', true);
                    % We return here because we don't want to rerun anymore
                    % twoPhotonMaster things!
                    return;
                end
                [~, newestInd] = max(cellfun(@(fname) datenum(fname(regexp(fname, '\d+_\d+_\d+', 'start'):regexp(fname, '\d+_\d+_\d+', 'end')), 'dd_mm_yy'),roiFiles));
                roiPath = fullfile(roiFilesDir, roiFiles{newestInd});
                roiFile = roiFiles(newestInd);
                roiFiles(newestInd) = [];
                oldestAllowedDatenum = datenum(Z.params.oldestAllowedRoiFile, 'dd_mm_yy');
                currFileDatenum = datenum(roiFile{1}(regexp(roiFile{1}, '\d+_\d+_\d+', 'start'):regexp(roiFile{1}, '\d+_\d+_\d+', 'end')), 'dd_mm_yy');
                if oldestAllowedDatenum>currFileDatenum
                    continue;
                end
                load(roiPath);
                if strcmp(Z.params.ROImethod, 'edgeTypeRoi')
                    correctParameters = true;
                    for i = 1:2:length(Z.params.edgeTypes)
                        if all(ismember(Z.params.edgeTypes(i:i+1), saveROI.params.edgeTypes))
                            inds = find(ismember(saveROI.params.edgeTypes, Z.params.edgeTypes(i:i+1)));
                            if any(diff(inds)==1)
                                adjacentInds = find(diff(inds)==1);
                                if ~any(mod(inds(adjacentInds), 2)==1)
                                    correctParameters = false;
                                end
                            else
                                correctParameters = false;
                            end
                        else
                            correctParameters = false;
                        end
                    end
%                     if isequal(saveROI.params.edgeTypes, Z.params.edgeTypes)
%                         correctParameters = true;
%                     end
                else
                    correctParameters = true;
                end
            end
            Z.ROI = saveROI.ROI;
            Z.rawTraces = saveROI.rawTraces;
        elseif ~isfield(Z, 'ROI') || ~isfield(Z, 'rawTraces') || ~any(roiFilesFromDesiredMethod)
            % Otherwise we've gotta rerun twoPhotonMaster and get some new
            % ROIs!
            Z = twoPhotonMaster(varargin{:}, 'force_new_ROIs', true);
            % We return here because we don't want to rerun anymore
            % twoPhotonMaster things!
            return;
        end   
    end  
    
    if isfield(Z.params, 'viewROIs') && Z.params.viewROIs
        ROIview = zeros(Z.params.imgSize(1),Z.params.imgSize(2));
        for q = 1:size(Z.ROI.roiMasks,3)-1
            ROIview = ROIview + Z.ROI.roiMasks(:,:,q) * (mod(q,10)+1);
        end
        imagesc(ROIview);
        title('ROIs');
    end
            
    
        
    %% Filter ROI traces
    if Z.params.filterRoiTraces
        Z = filterRoiTraces(Z);
    else
        % We don't want to run any analyses if we haven't filtered the
        % ROIs!
        if isfield(Z.params, 'whichAnalyses')
            Z.params = rmfield(Z.params, 'whichAnalyses');
        end
    end
    
    if Z.params.cullRoiTraces
        Z = CullRoiTraces(Z);
    end
    
    %% Adjust data if necessary
    try 
        DataAdjustments
    catch err
    end
    
    %% Individual analyses 
    if isfield(Z.params,'whichAnalyses')
        for q = 1:size(Z.params.whichAnalyses,2)
            eval(['Z = ' Z.params.whichAnalyses{q} '(Z);' ]);
            fprintf('Completed analysis: %s\n',Z.params.whichAnalyses{q}); toc            
            % SHOULD WE ADD IN APPENDING EVERY ANALYSIS TO MAT FILE?
        end
    end
    
    %% Final steps
    fourierGAL4SplineAnalysis

end

