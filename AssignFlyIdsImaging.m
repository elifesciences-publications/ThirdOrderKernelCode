function AssignFlyIdsImaging(relativeDataPaths, forceResave)

    %%
    sysConfig = GetSystemConfiguration();
    connDb = connectToDatabase(sysConfig.databasePathLocal);
    %%
    if nargin < 1
        dataReturn = fetch(connDb, 'select relativeDataPath, flyId from stimulusPresentation as sP join fly as f on sP.fly=f.flyId');
        dataReturn = flipud(dataReturn);
        relativeDataPaths = dataReturn(:, 1);
        twoPhotonIds = dataReturn(:, 2);
        twoPhotonIds = cell2mat(twoPhotonIds);
        maxId = max(twoPhotonIds);
        
        pathToRunDetails = cell(length(relativeDataPaths),1);
        
        
        
        for rr = 1:length(relativeDataPaths)
            pathToRunDetails{rr} = fullfile(sysConfig.dataPath,fileparts(relativeDataPaths{rr}),'stimulusData','runDetails.mat');
        end
    end
    
    if nargin < 2
        forceResave = false;
    end
    %% assign fly ids
%     for mm = 1:maxId
%         idInd = find(twoPhotonIds==mm);
%         
%         if ~(exist(pathToRunDetails{idInd(1)},'file') == 2)
%             flyId = AssignFlyId(0);
% 
%             for ind = 1:length(idInd)
%                 save(pathToRunDetails{idInd(ind)},'flyId');
%             end
%         end
%     end
flBad = 0;
badFilesOut = {};
    fprintf('\n\n\n\n\n');
    for dd = 1:length(relativeDataPaths)
        fprintf('\b\b\b\b%0.4d', dd);
        try
            % try to save all the data but skip the folders where it doesn't
            % work.
            [strt,~,ending] = fileparts(relativeDataPaths{dd});
            if strcmp(ending, '.tif')
                relativeDataPaths{dd} = strt;
            end
            
            relativeDataPaths{dd}(relativeDataPaths{dd}=='\') = '/';
            
            if ~any(strfind( relativeDataPaths{dd}, sysConfig.twoPhotonDataPathServer)) && ~any(strfind( relativeDataPaths{dd}, sysConfig.twoPhotonDataPathLocal))
                thisFolder = fullfile(sysConfig.twoPhotonDataPathLocal,relativeDataPaths{dd}); % default to a local path
                if isempty(dir(thisFolder))
                    thisFolder = fullfile(sysConfig.twoPhotonDataPathServer,relativeDataPaths{dd}); % default to a local path
                end
            else
                thisFolder = relativeDataPaths{dd};
            end
            
            if ~(exist(fullfile(thisFolder,'alignedMovie.mat'),'file')==2) || forceResave
                if forceResave
                    delete(fullfile(thisFolder,'alignedMovie.mat'));
                    delete(fullfile(thisFolder,'highResPd.mat'));
                    delete(fullfile(thisFolder,'imagingResPd.mat'));
                    delete(fullfile(thisFolder,'imageDescription.mat'));
                end
                try
                    load(fullfile(thisFolder,'alignedImageData'));
                catch loadErr
                    if strcmp(loadErr.identifier, 'MATLAB:load:couldNotReadFile')
                        matFileData = dir(fullfile(thisFolder, '*.mat'));
                        clear imgData
                        load(fullfile(thisFolder, matFileData.name), 'imgFrames_ch1', 'imgData', 'windowMask');
                        if exist('imgData', 'var')
                            PDFrames = imgData.PDFrames;
                            imageDescription = imgData.description;
                            save(fullfile(thisFolder, 'alignedImageData'), 'PDFrames', 'imageDescription', 'imgFrames_ch1')
                            % This is really painful, but I'm going to be
                            % deleting the old mat file so I HAVE to make
                            % sure the new one's save appropriately--best
                            % way to do it is to delete all the variables
                            % and check they exist when reloaded
                            clear imgFrames_ch1 PDFrames imageDescription
                            load(fullfile(thisFolder,'alignedImageData'));
                            if exist('imgFrames_ch1', 'var') && exist('PDFrames', 'var') && exist('imageDescription', 'var')
                                load(fullfile(thisFolder, matFileData.name), 'Z', 'fn', 'pathName', 'windowMask');
                                delete(fullfile(thisFolder, matFileData.name));
                                save(fullfile(thisFolder, matFileData.name), 'Z', 'fn', 'pathName', 'windowMask');
                            else
                                keyboard
                            end
                        end
                    else
                        rethrow(loadErr)
                    end
                end
                eval([strjoin(imageDescription, ';\n') ';']); % checking the state to see what channels were recorded
                channelsPossiblyRecorded = '12';
                channelsRecorded = channelsPossiblyRecorded(logical([state.acq.savingChannel1 state.acq.savingChannel2]));
                imgFramesToLoad = strsplit(sprintf('imgFrames_ch%c ', channelsRecorded));
                save(fullfile(thisFolder,'alignedMovie.mat'),imgFramesToLoad{:});
                avePd = mean(PDFrames,2);
                highResPd = reshape(avePd,[numel(avePd) 1]);
                imagingResPd = mean(avePd);
                imagingResPd = reshape(imagingResPd,[numel(imagingResPd) 1]);
                save(fullfile(thisFolder,'highResPd'),'highResPd');
                save(fullfile(thisFolder,'imagingResPd'),'imagingResPd');

                for ii = 1:length(imageDescription)
                    eval([imageDescription{ii} ';']);
                end

                save(fullfile(thisFolder,'imageDescription'),'state');
%             else
%                 load(fullfile(thisFolder,'alignedImageData'), 'PDFrames');
%                 avePd = mean(PDFrames,2);
%                 highResPd = reshape(avePd,[numel(avePd) 1]);
%                 save(fullfile(thisFolder,'highResPd'),'highResPd');
            end
            
            if ~(exist(fullfile(thisFolder,'movieMask.mat'),'file')==2) || forceResave
                if forceResave
                    delete(fullfile(thisFolder,'movieMask.mat'));
                end
                tifFileRecording = dir(fullfile(thisFolder, '*.tif'));
                [~,thisFile, ~] = fileparts(tifFileRecording.name);
                load([fullfile(thisFolder,thisFile) '.mat'],'windowMask');
                if exist('windowMask', 'var')
                    save(fullfile(thisFolder,'movieMask'),'windowMask');
                end
            end
            clear imgFrames_ch1 PDFrames imageDescription windowMask
        catch err
            clear imgFrames_ch1 PDFrames imageDescription windowMask
            if dd>0
                if strcmp(err.identifier, 'MATLAB:load:cantReadFile')
                    badFilesOut(end+1) = relativeDataPaths(dd);
                    flBad = flBad+1;
                end
            end
        end
    end
    fprintf('\n');
end