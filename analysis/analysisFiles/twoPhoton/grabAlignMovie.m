function [ Z ] = grabAlignMovie(Z)
% Add some comments about what this script does, inputs and outputs
 
    useTrap = 1;
    forceNewTrap = 0;
    saveROIdata = true; 
    loadFlexibleInputs(Z)
    
    %% Grab image from twoPhotonImageParser
    % We're loading into a variable K here because we don't want to
    % overwrite the parameters that Z has. We do, however, want to load
    % images from the mat file which requires certain parameters that a
    % precreated Z will have, and so we send this precreated Z (which is in
    % K) as an envoy to twoPhotonImageParser.
    if strcmp({matFiles.name}, 'alignedImageData.mat')
        imageDescStruct = load('alignedImageData.mat', 'imageDescription');
        Z.params.imageDescription = imageDescStruct.imageDescription ;
    elseif isfield(Z.params, 'matFiles') && ~isempty(Z.params.matFiles)
        if any(strcmp({matFiles.name}, [Z.params.name, '.mat']))
            matFileWithZ = matFiles(strcmp({matFiles.name}, [Z.params.name, '.mat'])).name;
            K = load(matFileWithZ, 'Z');
            if isfield(K, 'Z') && isfield(Z.params, 'imageDescription')
                Z.params.imageDescription = K.Z.params.imageDescription;
            end
            clear K
        end
    end
    [imgFrames, PDFrames, imageDescription, alignmentData] = twoPhotonImageParser(Z);
    Z.params.imageDescription = imageDescription;
    tifInfDescription = Z.params.imageDescription;
    acquiredChannelCell = regexp(tifInfDescription, 'saving.*(\d+)=[^0]', 'tokens');
    acquiredChannels = [acquiredChannelCell{~cellfun('isempty', acquiredChannelCell)}];
    acquiredChannels = [acquiredChannels{:}];
    
    if length(acquiredChannels) > 2
        acquiredChannels(strcmp(acquiredChannels, '3' )) = [];
        acquiredChannels(strcmp(acquiredChannels, channelDesired )) = [];
            
        tempRunPDAnalysis = Z.params.runPDAnalysis;
        tempChannelDesired = Z.params.channelDesired;
        Z.params.runPDAnalysis = 'No';
        for i = 1:length(acquiredChannels)
            Z.params.channelDesired = acquiredChannels{i};
            [~, ~, ~] = twoPhotonImageParser(Z);
        end
        Z.params.runPDAnalysis = tempRunPDAnalysis;
        Z.params.channelDesired = tempChannelDesired;
    end
        
    

    
    %Grab frame rate that capture occurred at
    fpsCell = regexp(imageDescription, 'frameRate=(\d+.*\d+)', 'tokens');
    fpsSmallCell = [fpsCell{~cellfun('isempty', fpsCell)}];
    fps = str2double(fpsSmallCell{:});

    imgSize = size(imgFrames);
    fs_pd = imgSize(1)*fps;
    

%     PDintensity = zeros(imgSize(1)*imgSize(3), imgSize(2));
    avg_linear_PDintensity = zeros(imgSize(1)*imgSize(3),1);
    
    for i = 1:size(PDFrames, 2)
        avg_linear_PDintensity = avg_linear_PDintensity + reshape(PDFrames(:, i, :), [imgSize(1)*imgSize(3), 1])/imgSize(2);
%         PDintensity(:, i) = reshape(imgData.PDFrames(:, i, :), [imgSize(1)*imgSize(3), 1]);
    end

    if Z.params.linescan;
        fs = fs_pd;
    else
        fs = fps;
    end
    
    Z.params.fps = fps;
    Z.params.imgSize = imgSize;
    Z.grab.avg_linear_PDintensity = avg_linear_PDintensity;
    
    if strcmp(Z.params.runPDAnalysis, 'Yes')
        Z = ExtractTriggersFromPhotodiode(Z);
%         roiImage = var(imgFrames, 0, 3);
%         averagedImage = mean(imgFrames, 3);
        
    end
    
    %% Draw a trapezoid around movie to cut out alignment border
        
    if ~useTrap || (isfield(Z.params, 'zstack') && Z.params.zstack)
        windowMask = ones(size(mean(imgFrames,3)));
    elseif ~forceNewTrap && any(strcmp([name '.mat'], {matFiles.name})) && any(strcmp(who('-file',[name '.mat']),'windowMask')) % does the .mat file exist? And does it have windowMask?
        load([name '.mat'], 'windowMask');
    else
        [ windowMask ] = windowMovie(mean(imgFrames,3), Z.params.linescan, alignmentData);
        windowMask = double(windowMask);
        saveVariables.windowMask = windowMask;
        saveOrAppendMatFile([name '.mat'], saveVariables);
    end
    Z.grab.windowMask = windowMask;
    
    if all(windowMask(:)==0)
        % Might *look* clunky, but for the moment this is the only good way
        % to quit out of everything else; if the alignment is such that
        % there is no appropriate window mask (i.e. the mask covers
        % everything), then we short circuit all other analysis
        Z.params.zstack = true;
    end
    

    %% Save important variables
    % add derived params
    Z.params.fs = fs;
    Z.params.name = name;
    Z.params.fn = fn;
    Z.params.pathName = pathName;
    
    % save Z.grab
%     Z.grab.PDintensity = PDintensity;
%     Z.grab.avg_PDintensity = avg_PDintensity;
    Z.grab.imgFrames = imgFrames;
    Z.grab.alignmentData = alignmentData;
    
    end