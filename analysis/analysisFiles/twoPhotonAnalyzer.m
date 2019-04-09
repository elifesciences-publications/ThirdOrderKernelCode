function output = twoPhotonAnalyzer(varargin)

align = true;
linescan = false;
filter = true;
low_frequency = .1;
high_frequency = 100;
force_new_ROIs = false;
baseline_lowpass_filter_frequency = .001;
analysis_method = 'none';
existingOutputIn = '';
ROImethod = 'pca';
segType = 'grid';
stimulusDataCols = [];
truncLen = 350;
scaleThresh = .2;
plotOut = true;
plotOverall = true;
recordComments = true;

% ICA-specific defaults
nIC = 6; 
nPC = 100; 
seeICs = 0; 
PCuse = [2:50]; 

% Watershed-specific defaults
keepSheds = Inf;
nClusters = 6; 
seeClusters = 0;
blurShed = 0;
analysisLevel = 'watershed';

% Kernel defaults
nMultiBars = 4; 
maxTau = 50;
kernelOrder = 1;

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
 
if baseline_lowpass_filter_frequency > low_frequency
    baseline_lowpass_filter_frequency = low_frequency;
end

%grab image
[imgFrames, fn, path, imgData] = twoPhotonImageParser(varargin{:});

[~, name, ext] = fileparts(fn);
matFiles = dir('*.mat');
selectROIs = true;
saveROIdata = false;
%If this flag is set, new ROIs will be made
if force_new_ROIs
    selectROIs = true;
    saveROIdata = true;
elseif any(strcmp([name '.mat'], {matFiles.name}))
    if ~isempty(existingOutputIn)
        load([name '.mat'], existingOutputIn);
        eval(['roi_data = ' existingOutputIn '.roi_data;']);
    else
        load([name '.mat'], 'roi_data');
    end
    if exist('roi_data', 'var')
        selectROIs = false;
    else
        saveROIdata = true;
    end
end



%Grab frame rate that capture occurred at
fpsCell = regexp(imgData.description, 'frameRate=(\d+.*\d+)', 'tokens');
fpsSmallCell = [fpsCell{~cellfun('isempty', fpsCell)}];
fps = str2double(fpsSmallCell{:});

imgSize = size(imgFrames);
fs_pd = imgSize(1)*fps;
%The 60 is for 60Hz; fs samples/sec over 60 frames/sec should give
%samples/frame
expected_flash_length = fs_pd/60;

PDintensity = zeros(imgSize(1)*imgSize(3), imgSize(2));
PDFrames = imgData.PDFrames;
avg_PDintensity = zeros(size(PDFrames, 3), 1);
for i = 1:size(PDFrames, 3)
    avg_PDintensity(i) = mean(mean(PDFrames(:, :, i)));
end
keep_PDintensity = avg_PDintensity;

for i = 1:size(PDFrames, 2)
    PDintensity(:, i) = reshape(PDFrames(:, i, :), [imgSize(1)*imgSize(3), 1]);
end

fs = fps;
%For non-linescans, we just take the average across the entire line as
%a PD data point
avg_linear_PDintensity = mean(PDintensity, 2);
    
[trigger_inds] = twoPhotonPhotodiodeAnalyzer(avg_linear_PDintensity, expected_flash_length, imgSize, varargin{:});

%Linescan processing's gonna be much different...
if linescan
    intensity = zeros(imgSize(1)*imgSize(3), imgSize(2));
    
    %We're grabbing each pixel of the line individually and plotting it
    %down! (Probably gonna change this to an ROI at some point)
    for i = 1:size(imgFrames, 2)
        intensity(:, i) = reshape(imgFrames(:, i, :), [imgSize(1)*imgSize(3), 1]);
    end
    
    PDintensity = zeros(imgSize(1)*imgSize(3), imgSize(2));
    PDFrames = imgData.PDFrames;
    for i = 1:size(PDFrames, 2)
        PDintensity(:, i) = reshape(PDFrames(:, i, :), [imgSize(1)*imgSize(3), 1]);
    end
    
    %We get rid of these data points because scanimage starts recording
    %potentially before the mirrors are fully up and running; hard to tell
    %exactly how many lines this gets rid of, but 20 should be about right.
    %Also, DON'T FORGET TO GET RID OF THE PDintensity VALUES, TOO!
    %Otherwise you misalign everything -.-
    startup_data_end = 0; %
    intensity(1:startup_data_end, :) = [];
    PDintensity(1:startup_data_end, :) = [];
    
    roi_selection_lines = 100;
    roiImage = repmat(mean(intensity), roi_selection_lines, 1);
    
    if selectROIs
        figure
        
        imagesc(roiImage);
        imshow(roiImage/max(roiImage(:)), 'InitialMagnification', 'fit');
        
        num_rois_cell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
        num_rois_str = num_rois_cell{1};
        num_rois = str2num(num_rois_str);
        
        %linear ROI
        title(['Select your ROI bounds for the ' num_rois_str ' ROI(s). Select left to right.']);
        [roi_x, roi_y] = ginput(2*num_rois);
        roi_x = round(roi_x);
        
        
        %         roi_data=cell(0);
        
        for i=1:num_rois
            roi_data.points{i} = [roi_x(2*i-1:2*i) [0; 0]; roi_x(2*i:-1:2*i-1) [roi_selection_lines+1; roi_selection_lines+1]; roi_x(2*i-1) 0];
            roi_data.roi_x = roi_x;
            blankMask = logical(zeros(size(roiImage)));
            blankMask(:, roi_x(2*i-1):roi_x(2*i)) = true;
            roi_data.mask{i} = blankMask;
        end
        
        title('Choose your rectangular ROI for background signal--left side first');
        [bkgd_x, bkgd_y] = ginput(2);
        cols_bkgd = round(bkgd_x);
        rows_bkgd = round(bkgd_y);
        
        roi_data.points{end+1} = [cols_bkgd(1:2) [0; 0]; cols_bkgd(2:-1:1) [roi_selection_lines+1; roi_selection_lines+1]; cols_bkgd(1) 0];
        roi_data.cols_bkgd = cols_bkgd;
        blankMask = logical(zeros(size(roiImage)));
        blankMask(:, cols_bkgd(1):cols_bkgd(2)) = true;
        roi_data.mask{end} = blankMask;
        
        close
    end
    
    %Take the mean across the line for the ROI
    roi_points = [roi_data.points{:}];
    %This indexing looks random. It works :D
    roi_x = roi_points(1:2, 1:2:end);
    roi_x = roi_x(:);
    for i = 1:2:length(roi_x)-2 %-2 to exclude the background columns
        roi_intensities(:, (i+1)/2) = mean(intensity(:, roi_x(i):roi_x(i+1)), 2);
        if ~isfield(roi_data, 'mask') || length(roi_data.mask) < (i+1)/2
            blankMask = logical(zeros(size(roiImage)));
            blankMask(:, roi_x(i):roi_x(i+1)) = true;
            roi_data.mask{(i+1)/2} = blankMask;
        end
    end
    
    roi_avg_intensity = mean(roi_intensities, 2);
    
    cols_bkgd = roi_x(end-1:end);
    % This is i+3 because it's two above the i from the above for loop; a
    % little tacky, I suppose
    if ~isfield(roi_data, 'mask') || length(roi_data.mask) < (i+3)/2
        blankMask = logical(zeros(size(roiImage)));
        blankMask(:, cols_bkgd(1):cols_bkgd(2)) = true;
        roi_data.mask{end+1} = blankMask;
    end
    bkgd_intensity = mean(intensity(:, cols_bkgd(1):cols_bkgd(2)), 2);
    
    
    %Take the mean across the line for the ROI
    for i = 1:2:length(roi_x)
        roi_PDintensities(:, (i+1)/2) = mean(PDintensity(:, roi_x(i):roi_x(i+1)), 2);
    end
    
    fs = imgSize(1)*fps;
    
    avg_PDintensity = mean(roi_PDintensities, 2);
    avg_linear_PDintensity = avg_PDintensity;
    
else
    %flatten image
    %     image = max(imgFrames, [], 3) - min(imgFrames, [], 3);
    %     h = fspecial('gaussian', 10);
    %     sigma = 10/2.355;%half width distance is 10 pixels and 2.355*\sigma
    %     h = fspecial('gaussian', 20, sigma);
    h = fspecial('gaussian', 5, 1);
    imgFrames = imfilter(imgFrames, h);
    %LOOK BELOW for the median filtering
    roiImage = var(imgFrames, 0, 3);
    %     roiImage = mean(imgFrames, 3);
averagedImage = mean(imgFrames, 3);
    
    
    
    switch ROImethod
        case 'watershed'
            tic;
            % Compute differential images for direction selective areas
            ROI.diffImg.differentialImages = triggeredResponseImages(imgFrames, trigger_inds, differentialEpochs);
            % Filter movie by cutting out non-directional regions
            [ watershedMovie, negMovie ] = differentialImageProject( imgFrames, ROI.diffImg.differentialImages, 0, 0 );
%             watershedMovie = imgFrames;
            [  ROI.diffImg.upperInds, ROI.diffImg.lowerInds ] = differentialEpochIndices(trigger_inds, differentialEpochs, 1, 0);    
            % Cluster based on time traces of movie filtered this way  
            frameRange = [ min(ROI.diffImg.upperInds{1}):max(ROI.diffImg.lowerInds{size(differentialEpochs,2)}) ]; 
            [ ROI.clusterMaps, ROI.shedMaps, ROI.shedIDs, ROI.bkgdMask ] = ...
                watershedCluster( watershedMovie(:,:,frameRange), 'seeClusters',seeClusters, ...
                'nClusters',nClusters,'keepSheds',keepSheds,'blurShed',blurShed);
            % Select response traces to use
%             ROI.useClusters = input('Which clusters should be retained?\n'); 
            % Compute traces of each watershed region
            [ ROI.shedIntensities, ROI.bkgdIntensity ] = ...
                mapsToRoiData( ROI.shedMaps, imgFrames, ROI.bkgdMask );
            % Compute sum traces for each cluster
            ROI.clusterIntensities = zeros(size(imgFrames,3),nClusters);
            for q = 1:nClusters
                shedIndsThisCluster = find(ROI.shedIDs == q);
                nShedsThisCluster = length(shedIndsThisCluster);
                for r = 1:nShedsThisCluster
                    ROI.clusterIntensities(:,q) = ROI.shedIntensities(:,shedIndsThisCluster(r));
                end
            end
            toc;
            % covariance visualization
%             traceCovariance(ROI);
%             % spatial coherence
%             spatialCovariance(ROI, watershedMovie); 
%             
%             figure; 
            
%             keyboard
            roi_intensities = ROI.shedIntensities;
            bkgd_intensity = ROI.bkgdIntensity;
            for i = 1:size(ROI.shedMaps, 3)
                roi_data.mask{i} = logical(ROI.shedMaps(:, :, i));
            end
            roi_data.mask{end+1} = logical(ROI.bkgdMask);
%                         mapsToRoiData( outputRegions, watershedMovie ); 
%             % output response traces
%             switch analysisLevel
%                 case 'cluster'
%                     outputRegions =  clusterMaps(:,:,useClusters);
%                     [ bg_roi, roi_intensities, bkgd_intensity, roi_data ] = ...
%                         mapsToRoiData( outputRegions, watershedMovie ); 
%                 case 'watershed'
%                     outputRegions = [];
%                     for q = 1:length(useClusters)
%                         whichShedsThisCluster = find( shedIDs == useClusters(q) );
%                         numShedsThisCluster = length(whichShedsThisCluster);
%                         for r = 1:numShedsThisCluster
%                             getShed = shedMaps(:,:,whichShedsThisCluster(r));
%                             outputRegions = cat(3,outputRegions,getShed);
%                         end
%                     end
%                     [ bg_roi, roi_intensities, bkgd_intensity, roi_data ] = ...
%                         mapsToRoiData( outputRegions, watershedMovie ); 
%                 case 'pixel'
%                     error('Pixel-level analysis not yet implemented.');
%             end

        case 'ICA'
            if selectROIs
                % Because the cellSort toolbox runs by reading in a tif
                % file, rather then accepting an array, it is most
                % convenient to do ICA on the aligned and disinterleaved
                % but non-filtered image. Then the components can be
                % applied to the processed image. In the course of running
                % ICA, will save an intermediate tif image of the movie
                % with median filtering.
                
                nameStub = strsplit(fn,'.');
                nameStub = nameStub{1};
                
                if align
                    nameEnd = sprintf('%s_ch%i_disinterleaved_aligned',nameStub,channelDesired);
                else
                    nameEnd = sprintf('%s_ch%i_disinterleaved.tif',fn,channelDesired);
                end
                
                %% run the ICA package                 
                [ cut_ica_filters ] = cellSort_run( path, nameEnd,'nPC',nPC,...
                    'nIC',nIC,'PCuse',PCuse,'see',seeICs,'truncLen',truncLen );               
                
                %% reshape to full size
                % border pixels were cut out by median filtering
                cut_ica_filters = permute(cut_ica_filters,[2 3 1]);
                fullSize = size(imgFrames);
                fullSize = fullSize(1:2);
                ica_filters = zeros([ fullSize nIC ]);
                ica_filters(2:end-1,2:end-1,:) = cut_ica_filters;
                
                % use top left corner as bg roi
                bg_roi = zeros(size(imgFrames));
                bg_roi(1:10,1:10) = ones(10,10);
                ica_filters = cat(3,ica_filters,bg_roi);
               
                %% clustering
                [ clusterMaps, clusterTraces ] = ...
                    clusterComponents(ica_filters, imgFrames, nClusters,...
                    'type', clusterType, 'seeClusters', seeClusters,...
                        'scaleThresh',scaleThresh);
                
                for q = 1:nClusters
                    roi_data.mask{q} = clusterMaps(:,:,q);
                end

                roi_intensities = clusterTraces(:,1:end-1);
                roi_data = []; % Blank roi_data for the moment
                bkgd_intensity = clusterTraces(:,end);
               
            end           
        case 'manual'
            if selectROIs
                figure
                %A little wonky, but imshow has a bad habit of showing minified images;
                %we ensure a big image by using imagesc, and then use imshow to create
                %a well displayed image
                imagesc(roiImage);
                imshow(roiImage/max(roiImage(:)), 'InitialMagnification', 'fit');
                
                num_rois_cell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
                num_rois_str = num_rois_cell{1};
                num_rois = str2num(num_rois_str);
                
                %linear ROI
                title(['Create a polygon surrounding your ROI for the ' num_rois_str ' ROI(s). Double click twice to finish each one.']);
                
                %We're gonna store these rois in a cell
                %     roi_data = cell(0);
                for i = 1:num_rois
                    [roi_mask x y] = roipoly;
                    roi_data.mask{i} = roi_mask;
                    roi_data.points{i} = [x y];
                end
                
                title('Choose your polygonal ROI for the background signal. Double click twice when you are done.');
                [roi_mask x_back y_back] = roipoly;
                roi_data.mask{i+1} = roi_mask;
                roi_data.points{i+1} = [x_back y_back];
            end
            
            
            numFrames = size(imgFrames, 3);
            roi_intensities = zeros(numFrames, 1);
            
            bkgd_intensity = zeros(numFrames, 1);
            
            stdImage = std(imgFrames(:));
            for frame = 1:numFrames
                %         imgFrames(:, :, frame) = imguidedfilter(imgFrames(:, :, frame), mean(imgFrames, 3));
                currFrame = imgFrames(:, :, frame);
                for roi = 1:length(roi_data.points)-1
                    imageROI = currFrame(roi_data.mask{roi});
                    imageROI = imageROI(averagedImage(roi_data.mask{roi})>stdImage);
                    roi_intensities(frame, roi) = mean(imageROI(:));
                end
                backgroundROI = currFrame(roi_data.mask{end});
                bkgd_intensity(frame) = mean(backgroundROI(:));
            end
        case 'PCA'
            if selectROIs
                % defaults to PCA-based selection
                %% shape movie into matrix of pixels(1) x time(2)
                imgSize = size(imgFrames);
                % We're gonna cut this up into 4x4 checkerboards
                gridRatX = 4;
                gridRatY = 4;
                extraRows = mod(imgSize(1), gridRatX);
                extraCols = mod(imgSize(2), gridRatY);
                % Slash the image here to get rid of boundary abnormalities
                % caused by alignment/image filtering (mostly that last
                % one)
                boxBoundaryRow = 0;
                boxBoundaryCol = 3;
                imgFrames = imgFrames(floor(extraRows/2)+1+boxBoundaryRow*gridRatY:end-ceil(extraRows/2)-boxBoundaryRow*gridRatY,...
                    floor(extraCols)+1+boxBoundaryCol*gridRatX:end-ceil(extraCols/2)-boxBoundaryCol*gridRatX, :);
                newImgSize = size(imgFrames);
                movMat = reshape(imgFrames,[size(imgFrames,1)*size(imgFrames,2),size(imgFrames,3)]);
                %% Establish segments
                switch segType
                    case 'water'
                        
                        smallGauss = gaussFun(gridX,gridY,1.5);
                        smallGauss = smallGauss - mean(smallGauss(:));
                        smallGaus = smallGauss / sqrt(smallGauss(:)'*smallGauss(:));
                        meanImg = filter2(mean(pcaImgFrames,3),smallGaus);
                        seg = zeros(size(imgFrames(:,:,1)));
                        seg(5:244,5:244) = watershed(meanImg,26);
                    otherwise
                        numGridX = ceil(newImgSize(2)/gridRatX);
                        numGridY = ceil(newImgSize(1)/gridRatY);
                        xGrid = [1:numGridX];
                        xGrid = repmat(xGrid,[gridRatX 1]);
                        xGrid = reshape(xGrid,[numGridX*gridRatX, 1]);
                        yGrid = [0:numGridY-1]*numGridX;
                        yGrid = repmat(yGrid,[gridRatY 1]);
                        yGrid = reshape(yGrid,[numGridY*gridRatY, 1]);
                        [xMesh, yMesh] = meshgrid(xGrid,yGrid);
                        seg = xMesh + yMesh;
                end
                %% Average into bins
                numSegs = max(seg(:));
                tDur = size(imgFrames,3);
                for q = 1:numSegs
                    allsegs{q} = ( seg == q );
                    % We divide by the sum here so the matrix
                    % multiplication below ends up outputing the average in
                    % the defined region
                    segvect(:,q) = allsegs{q}(:)/sum(allsegs{q}(:));
                end
                traces = (movMat'*segvect)';
                %% PCA
                [ U,S,V ] = svds(traces,6);
                %% Convert PCS back into visualizable parts of image
                figure;
                for q = 1:6
                    pctoimg{q} = segvect*U(:,q);
                    visMax = max(abs(pctoimg{q}(:)));
                    subplot(2,3,q);
                    imagesc(reshape(pctoimg{q},newImgSize(1:2)));
                    set(gca,'Clim',[-visMax visMax]);
                    theTitle = sprintf('PC #%i',q);
                    title(theTitle);
                    colormap(gray);
                end
                %% Watch PCs evolve over time
                figure;
                Uprime = U(:,2:5); % selecting 4 most interesting PCs
                Vprime = V(:,2:5);
                Vlim = max(Vprime(:));
                Sprime = S(2:5,2:5);
                pcmovie = Uprime*Sprime*Vprime';
                pcmoviemax = max(abs(pcmovie(:)));
                imframesmax = max(abs(imgFrames(:)));
                %                 for q = 1:imgSize(3);
                %                     subplot(3,1,2);
                %                     thisFrame = pcmovie(:,q);
                %                     thisFrame = reshape(thisFrame,[ numGridX numGridY ])';
                %                     set(gca,'Clim',[-100 100]);
                %                     imagesc(thisFrame);
                %                     subplot(3,1,1);
                %                     imagesc(imgFrames(:,:,q));
                %                     set(gca,'Clim',[0 100]);
                %                     subplot(3,1,3);
                %                     vTraces = Vprime(1:q,:);
                %                     plot(vTraces);
                %                     axis([0 imgSize(3) -Vlim Vlim]);
                %                     legend('pc1','pc2','pc3','pc4');
                %                     pause(0.001);
                %                 end
                
                roi_intensities = Vprime;
                roi_data = []; % Blank roi_data for the moment
                bkgd_intensity = V(:, 1);
            end
        otherwise %default to differentialEpochs
            if ~exist('differentialEpochs', 'var');
                error(['When analyzing with triggeredResponseDifferentialAnalysis, '...
                    'you need to provide a differentialEpochs varargin with the epochs '...
                    'you wish to compare against each other--one row with a base epoch '...
                    'and the second row with the corresponding opposite epoch']);
            end
            %         [epoch_avg_triggered_intensities, steps_back] = triggeredResponseAnalysis(roi_avg_intensity_filtered_normalized, trigger_inds, fn, fs, varargin{:}, 'roi_image', roiImage, 'roi_data', roi_data, 'plot_figs', false);
            % This is the border around the image that we ignore--the
            % reason for ignoring it is that post-filtering it often has a
            % lot of noise...
            imageCropPixelBorder = 8;
            roi_data = triggeredResponseDifferentialROIDetection(imgFrames, trigger_inds, differentialEpochs, varargin{:}, 'name', name, 'imageCropPixelBorder', imageCropPixelBorder);
            
            %Rerun twoPhotonAnalyzer to see what epochs did... not the best, I
            %suppose...
%             if resaveROIs
%                 analysisMethodInd = find(strcmp('analysis_method', varargin))+1;
%                 varargin{analysisMethodInd} = 'triggeredResponseAnalysis';
%                 twoPhotonAnalyzer('filename', fullfile(path, fn), varargin{:});
%                 %We'll only care about this second twoPhotonAnalyzer run at
%                 %that point, so we close out the initial function call
%                 return;
%             end
            %         triggeredResponseDifferentialAnalysis(epoch_avg_triggered_intensities, differentialEpochs);
            
            numFrames = size(imgFrames, 3);
            roi_intensities = zeros(numFrames, 1);
            
            bkgd_intensity = zeros(numFrames, 1);
            
            imgFramesCropped = imgFrames(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder, :);
            stdImage = std(imgFramesCropped(:));
            for frame = 1:numFrames
                %         imgFrames(:, :, frame) = imguidedfilter(imgFrames(:, :, frame), mean(imgFrames, 3));
                currFrame = imgFrames(:, :, frame);
                % This is tacky because it happens on every run even though
                % we only need it the first run before the bad points are
                % deleted, but whatevs for now.
                roiRemoval = false;
                for roi = 1:length(roi_data.points)-1
                    imageROI = currFrame(roi_data.mask{roi});
                    imageROI = imageROI(averagedImage(roi_data.mask{roi})>stdImage);
                    if isempty(imageROI)
                        roiRemoval(roi) = true;
                    end
                    roi_intensities(frame, roi) = mean(imageROI(:));
                end
                roi_data.points(roiRemoval) = [];
                roi_data.mask(roiRemoval) = [];
                roi_intensities(:, roiRemoval) = [];
                backgroundROI = currFrame(roi_data.mask{end});
                bkgd_intensity(frame) = mean(backgroundROI(:));
            end
            output.roi_data = roi_data;
        
            
    end
            
    roi_avg_intensity = mean(roi_intensities, 2);
    roiCenterOfMass = zeros(length(roi_data.mask), 2);
    for i = 1:length(roi_data.mask)
        [indRows, indCols] = find(roi_data.mask{i});
        roiCenterOfMass(i, :) = [mean(indRows) mean(indCols)];
    end
    roi_data.centerOfMass = roiCenterOfMass;
    
    
end

%This is to close the original ROI figure, which should only happen if you
%had to select them! Doy!
if selectROIs && strcmp(ROImethod, 'manual');
    close
end

if saveROIdata
    saveVariables.roi_data = roi_data;
    saveOrAppendMatFile([name '.mat'], saveVariables);
end



%Do some o' dat FILTERING!
if filter
    low_freq = 2*low_frequency/fs;
    high_freq = 2*high_frequency/fs;
    if low_freq <= 0
        [z,p,k] = butter(2, high_freq, 'low');
        [sos, g] = zp2sos(z,p,k);
    elseif high_freq >= 1
        [z,p,k] = butter(2, low_freq, 'high');
        [sos, g] = zp2sos(z,p,k);
    else
        [z,p,k] = butter(2, [low_freq high_freq]);
        [sos, g] = zp2sos(z,p,k);
    end
    
    background_subtracted = [roi_avg_intensity roi_intensities]-repmat(bkgd_intensity, [1 1+size(roi_intensities,2)]);
    
    baseline_low_pass_filter_freq = 2*baseline_lowpass_filter_frequency/fs;
    
    %NOTE the padding: we're taking the median along the entire stimulus
    %run because unless this neuron spends more time depolarized than not,
    %that should be a valid point of zero.
    padding_beginning = repmat(median(background_subtracted(:, :)), round(fs/baseline_lowpass_filter_frequency), 1);
    padding_end = repmat(median(background_subtracted(:, :)), round(fs/baseline_lowpass_filter_frequency), 1);
    background_subtracted = [padding_beginning; background_subtracted; padding_end];
    
    [bl_z,bl_p,bl_k] = butter(2, baseline_low_pass_filter_freq, 'low');
    [bl_sos, bl_g] = zp2sos(bl_z,bl_p,bl_k);
    
    low_pass_overall_signal = filtfilt(bl_sos, bl_g, background_subtracted);
    roi_avg_intensity_filtered=filtfilt(sos,g,background_subtracted);
    
    %Get rid of that padding!
    low_pass_overall_signal(1:length(padding_beginning),:) = [];
    low_pass_overall_signal(end-length(padding_end)+1:end, :) = [];
    roi_avg_intensity_filtered(1:length(padding_beginning),:) = [];
    roi_avg_intensity_filtered(end-length(padding_end)+1:end,:) = [];
    
    
    if any(roi_avg_intensity==0)
        disp('Note! Trying to get rid of 0 values in the roi_avg_intensity that will get in the way of the baseline signal calculation.');
        zeroValIndexes = find(roi_avg_intensity==0);
        zeroValIndexesDist = diff(zeroValIndexes);
        for i = length(zeroValIndexes):-1:1
            if zeroValIndexes(i) == length(roi_avg_intensity)
                diffInd = i-1;
                replaceInds = zeroValIndexes(i);
                zeroValIndexes(i) = [];
                while diffInd ~= 0 && zeroValIndexesDist(diffInd) == 1 %this will break if your data is only one point >.>
                    replaceInds = [replaceInds zeroValIndexes(diffInd)]
                    zeroValIndexes(diffInd) = [];
                    diffInd = diffInd - 1;
                    if diffInd == 0
                        if replaceInds(end)==1
                            error('No way about it, your background signal doesn''t exist!');
                        else
                            break;
                        end
                    end
                end
                roi_avg_intensity(replaceInds) = roi_avg_intensity(replaceInds(end)-1);
            else
                boundaryEnd = zeroValIndexes(i) + 1;
                diffInd = i-1;
                replaceInds = zeroValIndexes(i);
                zeroValIndexes(i) = [];
                while diffInd ~= 0 && zeroValIndexesDist(diffInd) == 1
                    replaceInds = [replaceInds zeroValIndexes(diffInd)]
                    zeroValIndexes(diffInd) = [];
                    diffInd = diffInd - 1;
                    if diffInd==0
                        break;
                    end
                end
                if replaceInds(end)==1
                    boundaryStart = boundaryEnd;
                else
                    boundaryStart = replaceInds(end)-1;
                end
                roi_avg_intensity(replaceInds) = mean(roi_avg_intensity([boundaryStart, boundaryEnd]));
            end
        end
    end
    log_average = log(roi_avg_intensity);
                
                
    
    eval_pts = (1:length(log_average))';
    polyfit_average = polyfit(eval_pts, log_average, 1);
    low_pass_overall_signal = exp(polyval(polyfit_average, eval_pts));
    low_pass_overall_signal = repmat(low_pass_overall_signal, [1, size(background_subtracted, 2)]);
    
    % roi_avg_intensity_filtered_normalized includes the roi_avg_intensity
    % as the first entry! Often you'll likely only want cols >1
    roi_avg_intensity_filtered_normalized = roi_avg_intensity_filtered./low_pass_overall_signal;
else
    roi_avg_intensity_filtered_normalized=[roi_avg_intensity roi_intensities];
    roi_avg_intensity_filtered_normalized=roi_avg_intensity_filtered_normalized-repmat(mean(roi_avg_intensity_filtered_normalized), size(roi_avg_intensity_filtered_normalized, 1), 1);
end



output.fs = fs;
output.roi_data = roi_data;
output.roi_image = roiImage;

try paramVar = load('stimulusData/chosenparams.mat', 'params');
catch err
    if strcmp(err.identifier, 'MATLAB:load:couldNotReadFile')
        try 
            [allStimulusBehaviorData] = grabStimulusData(fullfile(path, fn));
            paramVar = load('stimulusData/chosenparams.mat', 'params');
        catch err2
            if strcmp(err2.identifier, 'MATLAB:AddField:InvalidFieldName')
                paramVar = load('chosenparams.mat', 'params');
                cd(path);
            else
                rethrow(err)
            end
        end
    else
        rethrow(err)
    end
end
        
params = paramVar.params;
output.params =  params;
% keyboard
switch analysis_method
    case 'decomposePhases'
        if ~strcmp(ROImethod,'watershed')
            error([ 'Aborting: decomposePhases analysis can only be ' ...
                'performed with watershed ROI selection' ]);
        end
        useEpoch = input('Which direction?\n1 = Left, 2 = Right, 3 = Up, 4 = Down.\n');
        [  upperInds, lowerInds ] = differentialEpochIndices(trigger_inds, differentialEpochs, size(imgFrames,1));
        % break these indices into contiguous chunks - otherwise splicing
        % together the traces will create artifacts in frequency
        cutStarts = [1 (find(diff(upperInds{useEpoch}) > 1) + 1)];
        numCuts = length(cutStarts);
        for q = 1:numCuts
            if q == numCuts
                cutEnd = length(upperInds{useEpoch});
            else
                cutEnd = cutStarts(q+1)-1;
            end
            upperIndCuts{q} = upperInds{useEpoch}(cutStarts(q):cutEnd);
            lowerIndCuts{q} = lowerInds{useEpoch}(cutStarts(q):cutEnd);
        end  
        % Cut out relevant parts and reshape movie for easy projection
        for p = 1:numCuts
            numFramesCut = length(lowerIndCuts{p});
            movieCut{p} = imgFrames(:,:,lowerIndCuts{p});
            for q = 1:length(lowerIndCuts{p})
                thisFrame = movieCut{p}(:,:,q);
                movieCutRoll{p}(:,q) = thisFrame(:);
            end
        end
        % Get all watershed regions in clusters specified by useCluster
        nRegions = size(outputRegions,3);
        for q = 1:nRegions
            thisFrame = outputRegions(:,:,q);
            regionRoll(:,q) = thisFrame(:);
        end
        % Get traces for all of these regions
        catPlotAll = [];
        catPlotDeMean = [];
        catPlotSphere = [];
        for p = 1:numCuts
            for q = 1:nRegions
                watershedTraces{q}(:,p) = movieCutRoll{p}'*regionRoll(:,q);          
                watershedTracesDeMean{q}(:,p) = watershedTraces{q}(:,p) - ...
                    mean(watershedTraces{q}(:,p));
                watershedTracesSphered{q}(:,p) = watershedTracesDeMean{q}(:,p) / ...
                    sqrt(watershedTracesDeMean{q}(:,p)'*watershedTracesDeMean{q}(:,p));
                catPlotAll = cat(2,catPlotAll,watershedTraces{q}(:,p));
                catPlotDeMean = cat(2,catPlotDeMean,watershedTracesDeMean{q}(:,p));
                catPlotSphere = cat(2,catPlotSphere,watershedTracesSphered{q}(:,p));
            end
        end
        
        figure; 
        subplot(2,1,1); plot(catPlotAll); title('Watershed Region Traces - Raw');
        subplot(2,1,2); plot(catPlotSphere); title('Watershed Region Traces - Sphered');
        
            % take Fourier transform of each
            N = 1e4+1;
            fftAxis = linspace(-(N-1)/2*fs/N,(N-1)/2*fs/N,N);
            watershedTracesFFT = fft(catPlotDeMean,N,1);
%             watershedTracesFFT = fft(catPlotDeMean,[],1);
            watershedTracesPwr = watershedTracesFFT .* conj(watershedTracesFFT);
            figure; plot(fftAxis,fftshift(watershedTracesPwr));
%             figure; plot(fftshift(watershedTracesPwr));
            xlabel('hz'); ylabel('magnitude (non-sphered)'); title('Power Spectrum of Watershed Traces');

        keyboard
        
        plusTraces = zeros(1,size(imgFrames,3));
        plusTraces(lowerInds{useEpoch}) = 1;
        figure; plot(plusTraces);
               
    case 'triggeredResponseAnalysis'
        triggeredResponseAnalysis(roi_avg_intensity_filtered_normalized, trigger_inds, fn, fs, varargin{:}, 'roi_image', roiImage, 'roi_data', roi_data, 'params', params);
        output.roi_avg_intensity_filtered_normalized = roi_avg_intensity_filtered_normalized;
        output.trigger_inds = trigger_inds;
    case 'extractKernels'
        [allStimulusBehaviorData] = grabStimulusData(fullfile(path, fn));
        if ~isempty(stimulusDataCols)
            stimulusData = allStimulusBehaviorData.StimulusData(:,stimulusDataCols);
        else
            stimulusData = allStimulusBehaviorData.StimulusData;
        end
        
        if ~linescan            
            [alignedStimulusData(:,1), responseData(:, 1)] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData.Flash, roi_avg_intensity_filtered_normalized(:, 1), trigger_inds);
            % Skip the background!
            for roi = 1:size(roiCenterOfMass,1)-1
                [alignedStimulusData(:, roi+1), responseData(:, roi+1), fsFactor] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData.Flash, roi_avg_intensity_filtered_normalized(:, roi+1), trigger_inds, roiCenterOfMass(roi)/imgSize(1));
            end
        else
            [alignedStimulusData, responseData, fsFactor] = alignStimulusAndResponse(stimulusData, allStimulusBehaviorData.Flash, roi_avg_intensity_filtered_normalized, trigger_inds, Z);
        end
        output.kernels = extractKernels(alignedStimulusData, responseData, fs*fsFactor, fn, varargin{:}, 'params', params);
        output.stimulusData = alignedStimulusData;
        output.responseData = responseData;
    case 'multiKernels'
        keyboard
        % read in data cols
        [allStimulusBehaviorData] = grabStimulusData(fullfile(path, fn));
        if ~isempty(stimulusDataCols)
            stimulusData = allStimulusBehaviorData.StimulusData(:,stimulusDataCols);
        else
            stimulusData = allStimulusBehaviorData.StimulusData;
        end
        
        % create aligned traces for all bars of multiflicker
        for q = 1:nMultiBars
            if ~linescan
                % Skip the background!
                for roi = 1:size(roiCenterOfMass,1)-1
                    [alignedStimulusData(:, q), responseData(:, roi)] = alignStimulusAndResponse(stimulusData(:, q), allStimulusBehaviorData.Flash, roi_avg_intensity_filtered_normalized(:, roi+1), trigger_inds, roiCenterOfMass(roi,1)/imgSize(1));
                end
            else
                [stimulusDataTemp, responseData] = alignStimulusAndResponse(stimulusData(:,q), allStimulusBehaviorData.Flash, roi_avg_intensity_filtered_normalized(2:end), trigger_inds);
                %             [stimulusDataTemp, responseData] = hollyAlign60hz(stimulusData(:,q), allStimulusBehaviorData.Flash, roi_intensities, trigger_inds, fs);
                responseData = responseData - repmat(mean(responseData,1),[size(responseData,1), 1]);
                stimulusDataOut(:,q) = stimulusDataTemp;
            end
        end
        % cut out kernel extraction segment
        if ~exist('cutInit','var')
            cutInit = find(allStimulusBehaviorData.Epoch == 9,1,'first') - 2;
            cutEnd = find(allStimulusBehaviorData.Epoch == 9,1,'last') - 2;           
        end   
        % loop through extraction
        for r = 1:nMultiBars
            for q = 1:size(responseData,2)
                firstInd = r;
                secondInd = r+1;
                if secondInd > 4
                    secondInd = 1;
                end
                x = stimulusDataOut(cutInit:cutEnd,firstInd);
                y = stimulusDataOut(cutInit:cutEnd,secondInd);
                resp = responseData(cutInit:cutEnd,q);
%                 resp = responseData(cutInit-maxTau/2:cutEnd-maxTau/2,q) - mean(responseData(cutInit-maxTau/2:cutEnd-maxTau/2,q));
                filtersOut{r,q} = kernelSwitch( x, y, resp, maxTau, kernelOrder);                             
            end
        end    
        % visualize
        switch kernelOrder
            case 1
                stackLinearFilters(filtersOut);
            case 2
                see2pfilters(filtersOut);
            case 3
        end
    case 'triggeredResponseDifferentialAnalysis'
        if ~exist('differentialEpochs', 'var');
            error(['When analyzing with triggeredResponseDifferentialAnalysis, '...
                'you need to provide a differentialEpochs varargin with the epochs '...
                'you wish to compare against each other--one row with a base epoch '...
                'and the second row with the corresponding opposite epoch']);
        end
        %         [epoch_avg_triggered_intensities, steps_back] = triggeredResponseAnalysis(roi_avg_intensity_filtered_normalized, trigger_inds, fn, fs, varargin{:}, 'roi_image', roiImage, 'roi_data', roi_data, 'plot_figs', false);
        roi_data = triggeredResponseDifferentialROIDetection(imgFrames, trigger_inds, differentialEpochs, varargin{:}, 'name', name, 'params', params);
        output.roi_data = roi_data;
        %Rerun twoPhotonAnalyzer to see what epochs did... not the best, I
        %suppose...
        if resaveROIs
            analysisMethodInd = find(strcmp('analysis_method', varargin))+1;
            varargin{analysisMethodInd} = 'triggeredResponseAnalysis';
            twoPhotonAnalyzer('filename', fullfile(path, fn), varargin{:});
            %We'll only care about this second twoPhotonAnalyzer run at
            %that point, so we close out the initial function call
            return;
        end
        %         triggeredResponseDifferentialAnalysis(epoch_avg_triggered_intensities, differentialEpochs);
    case 'averageEpochResponseAnalysis'
        roiIndsOfInterest = extractROIsBySelectivity(roi_avg_intensity_filtered_normalized, trigger_inds, varargin{:});
        roiIndsOfInterest(1) = true; %Because the first column is the average >.>
        [dFFEpochValues, epochsOfInterest] = averageEpochResponseAnalysis(roi_avg_intensity_filtered_normalized(:, roiIndsOfInterest), trigger_inds, varargin{:}, 'name', name, 'roi_data', roi_data);
        output.dFFEpochValues = dFFEpochValues;
        output.epochsOfInterest = epochsOfInterest;
        if plotOut
            plotAverageEpochResponse(dFFEpochValues, params, roiImage, roi_data, epochsOfInterest);
        end
        roi_avg_intensity_filtered_normalized = [roi_avg_intensity_filtered_normalized(:, roiIndsOfInterest)];
end



if plotOverall
    
    trace_dists = diff(roi_avg_intensity_filtered_normalized');
    plot_sep = 2*mean(max(trace_dists)-min(trace_dists));
    
    makeFigure
    colors = jet( size(roi_avg_intensity_filtered_normalized, 2));
    time_vals = linspace(0, imgSize(3)/fps, length(roi_avg_intensity));
    % Average ROI plot
    % legend_plots(1) = plot(time_vals, bkgd_intensity(:, 1), 'Color', colors(1, :));
    hold on;
    if size(roi_avg_intensity_filtered_normalized, 2)-1 < 10
        % Individual ROI intensities
        for i = 2:size(roi_avg_intensity_filtered_normalized, 2)
            legend_plots(i) = plot(time_vals, roi_avg_intensity_filtered_normalized(:, i)+(i-1)*plot_sep, 'Color', colors(i-1, :));
            plot(time_vals, (i-1)*plot_sep*ones(size(time_vals)), ':', 'Color', colors(i-1, :));
        end
        %Normalize and shift up the PD signal
        max_signal = max(max([roi_avg_intensity_filtered_normalized]));
        min_signal = min(min([roi_avg_intensity_filtered_normalized]));
        % max_diff = max_signal - min_signal;
        max_diff = max_signal+i*plot_sep-min_signal;
        time_vals_PD = linspace(0, imgSize(3)/fps, length(avg_linear_PDintensity));
        legend_plots(end+1) = plot(time_vals_PD,avg_linear_PDintensity/max(avg_linear_PDintensity)*max_diff+min_signal, 'Color', colors(2, :));
        
        title(sprintf('%s\n%s', fn));
        xlabel('Time (s)');
        ylabel('Total F');
        legend_entries = cell(1, size(roi_avg_intensity_filtered_normalized, 2)-1);
        % legend_entries(1) = {'Background ROI'};
        for i = 2:size(roi_avg_intensity_filtered_normalized, 2)
            legend_entries(i-1) = {['ROI ' num2str(i-1)]};
        end
        legend_entries(end+1) = {'PD Data'};
        legend_entries(1)=[];
        legend_plots(1) = [];
        legend(legend_plots, legend_entries);
    else
        [ttime rrois] = meshgrid(time_vals, 1:size(roi_avg_intensity_filtered_normalized, 2)-1);
        
%         surf(ttime, rrois, roi_avg_intensity_filtered_normalized(:, 2:end)', 'EdgeColor', 'none');
        % Normalize to the max of each trace here
        roiValsForPlotting = (roi_avg_intensity_filtered_normalized(:, 2:end)./(repmat(max(roi_avg_intensity_filtered_normalized(:, 2:end)), [size(roi_avg_intensity_filtered_normalized, 1), 1])))';
        surf(ttime, rrois, roiValsForPlotting, 'EdgeColor', 'none');
        view(2);
        colormap(b2r(min(roiValsForPlotting(:)), max(roiValsForPlotting(:))))
        colorbar
    end
    
    
    
    epochs = fields(trigger_inds);
    colors = bone(length(epochs));
            ylim = get(gca, 'ylim');
    for epoch = 1:length(epochs)
        epoch_bounds = trigger_inds.(epochs{epoch}).bounds;
        %     legend_patch_entries(epoch) = {epochs{epoch}};
        for j = 1:size(epoch_bounds,2)
            x = [epoch_bounds(:, j)', epoch_bounds(end:-1:1, j)']/fps;
            y = [ylim(1)-1 ylim(1)-1 diff(ylim) diff(ylim)];
            legend_patch(epoch) = patch(x, y, [1 1 1], 'FaceColor', 'none');
            xText(epoch, j) = mean(x);
            %         yText = max(y) - .1*(max(diff(y)));
            if epoch<=length(params) && isfield(params(epoch), 'epochName') && ~isempty(params(epoch).epochName)
                %             hText = text(xText, yText, params(epoch).epochName, 'FontUnits', 'normalized', 'Rotation', 90, 'HorizontalAlignment', 'left');
                hText{epoch, j} = params(epoch).epochName;
            else
                %             hText = text(xText, yText, sprintf('%d', epoch), 'FontUnits', 'normalized', 'Rotation', 0, 'HorizontalAlignment', 'center');
                hText{epoch, j} = sprintf('Epoch %d', epoch);
            end
            %         set(hText, 'FontSize', .02);
        end
    end
    
    xTextLin = xText(xText~=0);
    hTextLin = hText(xText~=0);
    [xTextSort, sortInd] = sort(xTextLin);
    hTextSort = hTextLin(sortInd);
    
    currentAx = gca;
    if verLessThan('matlab', '8.4')
%         position = get(currentAx, 'position');
        xlim = get(currentAx, 'xlim');
        ylim = get(currentAx, 'ylim');
        epochAx =axes('units','normalized','xlim',xlim,'ylim', ylim, 'xtick', xTextSort, 'xticklabel', hTextSort, 'color', 'none', 'ycolor', [0 0 0], 'XAxisLocation', 'top', 'TickLength', [0 0]);
        rotateticklabel(epochAx, 90);
    else
        epochAx =axes('units','normalized','position',currentAx.Position,'xlim',currentAx.XLim,'ylim', currentAx.YLim, 'xtick', xTextSort, 'xticklabel', hTextSort, 'color', 'none', 'ycolor', 'none', 'XAxisLocation', 'top', 'TickLength', [0 0], 'XTickLabelRotation', 90);
    end
    
    linkaxesProperties([currentAx, epochAx], 'xy', 'Position');
    % xlabel(a,'Inches')
    % b=axes('units','normalized','position',[.1 .1 .8 0.000001],'xlim',[0 12],'color','none')
    % xlabel(b,'Feet')
    % if verLessThan('matlab', '8.4')
    %         set(gca, 'XTick', 1:length(epochsOfInterest));
    %         set(gca,'XTickLabel',epochNames);
    %         rotateticklabel(gca, 45);
    %     else
    %         set(gca, 'XTick', 1:length(epochsOfInterest));
    %         set(gca,'XTickLabel',epochNames);
    %         set(gca, 'XTickLabelRotation', 45);
    %     end
    % ax2 = axes('Position',get(gca,'Position'),...
    %            'xlim',get(gca,'xlim'),...
    %            'ylim',get(gca,'ylim'),...
    %            'Color','none',...
    %            'Visible', 'off');
    % lgnd_handle = legend(legend_patch, legend_entry);
    % set(lgnd_handle, 'Color', 'none', 'Location', 'SouthEast')
    % legend([legend_plots legend_patch], [legend_entries legend_patch_entries]);
    
    hold off;
    
    figure
    colormap(gray(256))
    imagesc(roiImage);
    axis off
    hold on
    colors = jet(length(roi_data.mask));
    
    roiDisplayImage = zeros([size(roiImage), 3]);
    alph = zeros(size(roiImage));
    for i = 1:length(roi_data.mask)
        roiMask = logical(roi_data.mask{i});
        otherLayerMask = logical(zeros(size(roiMask)));
        alph = alph | roiMask;
        roiDisplayImage(cat(3, roiMask, otherLayerMask, otherLayerMask)) = colors(i, 1);
        roiDisplayImage(cat(3, otherLayerMask, roiMask, otherLayerMask)) = colors(i, 2);
        roiDisplayImage(cat(3, otherLayerMask, otherLayerMask, roiMask)) = colors(i, 3);
        %     x = roi_data.points{i}(:, 1);
        %     y = roi_data.points{i}(:, 2);
        %It's colors(i+2) because of how the plotting works later on;
        %this allows the roi colors to match the signal trace colors
        %     plot(x, y, 'Color', colors(i,:));
    end
    h = imagesc(roiDisplayImage);
    set(h, 'AlphaData', .5*alph);
    for i = 1:length(roi_data.mask)
        text(roi_data.centerOfMass(i, 2), roi_data.centerOfMass(i, 1), num2str(i), 'HorizontalAlignment', 'center');
    end
    
    roi_legend_entry = {};
    for i = 2:size(roi_avg_intensity_filtered_normalized, 2)
        roi_legend_entry{i-1} = ['ROI ' num2str(i)];
    end
    roi_legend_entry{end+1} = 'Background ROI';
    legend(roi_legend_entry);

end

if recordComments
    %NOTE: Should we go through available flags (i.e. 'channelDesired' and add
    %them? Problem is that flags in inner functions won't be revealed in this
    %one :/ Doing 'filename' at least here
    if ~any(strcmp(varargin,'filename'))
        filename = fullfile(path, [name, '.tif']);
        varargin = ['filename', filename, varargin];
    end
    %If for example, twoPhotonAnalyzer was called with a preexisting outputVar,
    %we wouldn't want to rewrite a new one, and twoPhotonAnalyzer will give us
    %the name of the outputVar instead of the structure output.
    if isempty(existingOutputIn)
        date = datestr(now, 'mmm_dd_yyyy_HH_MM_SS');
        outputVar = ['output_' date];
    else
        sameOutput = eval(['isequal(' existingOutputIn ', output)']);
        if sameOutput
            outputVar = existingOutputIn;
        else
            date = datestr(now, 'mmm_dd_yyyy_HH_MM_SS');
            outputVar = ['output_' date];
        end
    end
    functionCallString = functionCallAsString(mfilename, nargout, varargin{:}, 'existingOutputIn', outputVar);
    dataCommentRecorder(name, path, analysis_method, functionCallString, outputVar, output);
end

