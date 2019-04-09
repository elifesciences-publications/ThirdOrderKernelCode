function newROIData = triggeredResponseDifferentialROIDetection(imgFrames, trigger_inds, differentialEpochs, varargin)
% This function will highlight epochs by looking at how the average image
% fluorescence shifts between two antagonizing stimuli (say, for T4T5, a
% stimulus in a preferred direction versus a null direction)

resaveROIs = false;
imageCropPixelBorder = 8;

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

imgSize = size(imgFrames);
meanImageFrames = mean(imgFrames, 3);
epochs = fields(trigger_inds);
epoch_nums = cellfun(@(epoch) str2num(epoch(epoch>='0' & epoch<='9')), epochs);

differentialImages = zeros(imgSize(1), imgSize(2), size(differentialEpochs, 2));

for diffEpochInd = size(differentialEpochs, 2):-1:1
    if ~any(epoch_nums==differentialEpochs(1, diffEpochInd))
        warning(['Epoch ' num2str(differentialEpochs(1, diffEpochInd)) ' not found in the photodiode data']);
        differentialImages(:, :, diffEpochInd) = [];
        continue;
    end
    if ~any(epoch_nums==differentialEpochs(2, diffEpochInd))
        warning(['Epoch ' num2str(differentialEpochs(2, diffEpochInd)) ' not found in the photodiode data']);
        differentialImages(:, :, diffEpochInd) = [];
        continue;
    end
    epochBase = differentialEpochs(1, diffEpochInd);
    epochOpposite = differentialEpochs(2, diffEpochInd);
    
    boundsBase = trigger_inds.(['epoch_' num2str(epochBase)]).bounds/imgSize(1);
    boundsOpposite = trigger_inds.(['epoch_' num2str(epochOpposite)]).bounds/imgSize(1);
    
    % Take ceil and floor because the full image won't see the stimulus
    % until after the frame that got the PD signal and it will have lost
    % the stimulus right before the frame that got the PD signal
    finalBoundsBase = zeros(size(boundsBase));
    finalBoundsBase(1, :) = ceil(boundsBase(1, :));
    finalBoundsBase(2, :) = floor(boundsBase(2, :));
    finalBoundsOpposite = zeros(size(boundsOpposite));
    finalBoundsOpposite(1, :) = ceil(boundsOpposite(1, :));
    finalBoundsOpposite(2, :) = floor(boundsOpposite(2, :));
    
    % Works because we'll take all the indexes between the top row values
    % and the bottom row values; add one for each column because
    % subtraction isn't inclusive of both bounds
    indexesBase = zeros(sum(diff(finalBoundsBase))+size(finalBoundsBase, 2), 1);
    indexesOpposite = zeros(sum(diff(finalBoundsOpposite))+size(finalBoundsOpposite, 2), 1);
    
    % Loop through to create the base indexes
    indexInd = 1;
    for boundsBaseLoop = finalBoundsBase
        bounds = boundsBaseLoop(1):boundsBaseLoop(2);
        indexesBase(indexInd:indexInd+length(bounds)-1) = bounds;
        indexInd = indexInd + length(bounds);
    end
    
    % Loop through to create the opposite indexes
    indexInd = 1;
    for boundsOppositeLoop = finalBoundsOpposite
        bounds = boundsOppositeLoop(1):boundsOppositeLoop(2);
        indexesOpposite(indexInd:indexInd+length(bounds)-1) = bounds;
        indexInd = indexInd + length(bounds);
    end
%     
%     indexesBaseRef = logical([diff(indexesBase)>1; 1]+[diff(indexesBase(2:end))>1; 1; 0]+[diff(indexesBase(3:end))>1; 1; 0; 0]);
    indexesBaseRef = indexesBase;
    epochImageBaseMean = mean(imgFrames(:, :, indexesBaseRef), 3)+1;
    epochImageOppositeMean = mean(imgFrames(:, :, indexesOpposite), 3)+1;
%     epochImageBase = min(imgFrames(:, :, indexesBase), [], 3);
%     epochImageOpposite = max(imgFrames(:, :, indexesOpposite), [], 3);
    epochImageBase = epochImageBaseMean - 1;
    epochImageOpposite = epochImageOppositeMean - 1;
%     epochImageBase = var(imgFrames(:, :, indexesBase), 0, 3)./epochImageBaseMean;
%     epochImageOpposite = var(imgFrames(:, :, indexesOpposite), 0, 3)./epochImageOppositeMean;
    
%     differentialImages(:, :, diffEpochInd) = epochImageOpposite - epochImageBase;
%     differentialImages(:, :, diffEpochInd) = (epochImageOpposite - epochImageBase)./(0.5*(epochImageOpposite + epochImageBase) + 0.1*mean([epochImageBase(:);epochImageOpposite(:)]));
    responseDifference = (epochImageOpposite-epochImageBase)./epochImageBase;
    
    % For when epochImageBase=0, we assume that this pixel is very
    % different
    responseDifference(abs(responseDifference) == Inf) = max(responseDifference(abs(responseDifference)~=Inf));
    % For when both epochImageBase=0 and epochImageOpposite = 0, we assume
    % that they two pixels are pretty similar
    responseDifference(isnan(responseDifference)) = 0;
    differentialImages(:, :, diffEpochInd) = responseDifference;
    
    figure
    %Get rid of annoying image alignment artifact
    differentialImagesCroppedHere = differentialImages(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder, :);
    differentialImagesCropped(:, :, diffEpochInd) = differentialImagesCroppedHere (:, :, diffEpochInd);
    diffImageHere = differentialImagesCroppedHere(:, :, diffEpochInd);
    stdImage = std(diffImageHere(:));
    maxImage = max(abs(diffImageHere(:)));
    cmin = min(diffImageHere(:));
    cmax = max(diffImageHere(:));
    cmap = b2r(cmin, cmax);
    
    normalizedVals = diffImageHere/maxImage;
    zeroShift = min(normalizedVals(:));
    positiveShiftedVals = normalizedVals-zeroShift;
    cmapIndScale = length(cmap)/max(positiveShiftedVals(:));
    cmapInds = round(positiveShiftedVals*cmapIndScale);
    colorDiffImageHere = ind2rgb(cmapInds, cmap);
    alph = double(abs(diffImageHere)<1*stdImage);
    alph(alph==0) = 0.5;
    meanImageFramesHere = meanImageFrames(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder)/max(max(meanImageFrames(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder)));
    %Repmat makes it into a 3D image array, instead of an intensity array
    %whose colormap can be shifted
    meanImageFramesHere = repmat(meanImageFramesHere, [1 1 3]);
%     diffImageHere(diffImageHere<maxImage) = meanImageFramesHere(diffImageHere<maxImage);
    imagesc(colorDiffImageHere);
    colormap(cmap);
    caxis([cmin cmax])
    colorbar
    hold on
    h = imagesc(meanImageFramesHere);
    set(h, 'AlphaData', alph);
    title(['Differential Analysis of Epochs ' num2str(epochBase) ' and ' num2str(epochOpposite)]);
    hold off
end

% figure
% imagesc(meanImageFrames)
% colormap('gray');


% if resaveROIs
%     load([name '.mat'], 'roi_data');
    
    figure
    gleanedImages = zeros(size(differentialImages));
    for diffImageInd = 1:size(differentialImages, 3)
        currImage = differentialImages(:, :, diffImageInd);
        currImageCropped = differentialImagesCropped(:, :, diffImageInd);
        stdImage = std(currImageCropped(:));
        cutoff = 2*stdImage;
        % 100 is just a value that can be noticed...
        currImage(abs(currImage)<=cutoff) = 0;
        %Either -100 or 100
        indsOfInterest = abs(currImage)>cutoff;
        currImage(indsOfInterest) = currImage(indsOfInterest)./abs(currImage(indsOfInterest))*100;
        gleanedImages(:, :, diffImageInd) = currImage;
    end
    % We show the sum so multiply-important regions gain importance, and we
    % make it the absolute value so if for whatever reason the regions are
    % multiply used but opposite in importance, they don't get deleted
    gleanedImagesCropped = gleanedImages(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder, :);
    imageSummed = sum(gleanedImagesCropped, 3);
    maxImage = max(abs(imageSummed(:)));
    stdImage = std(imageSummed(:));
    normalizedVals = imageSummed/maxImage;
    zeroShift = min(normalizedVals(:));
    positiveShiftedVals = normalizedVals-zeroShift;
    cmapIndScale = length(cmap)/max(positiveShiftedVals(:));
    cmapInds = round(positiveShiftedVals*cmapIndScale);
    colorDiffImageHere = ind2rgb(cmapInds, cmap);
    alph = double(abs(imageSummed)<1);
    alph(alph==0) = 0.5;
    meanImageFramesHere = meanImageFrames(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder)/max(max(meanImageFrames(imageCropPixelBorder+1:end-imageCropPixelBorder, imageCropPixelBorder+1:end-imageCropPixelBorder)));
    %Repmat makes it into a 3D image array, instead of an intensity array
    %whose colormap can be shifted
    meanImageFramesHere = repmat(meanImageFramesHere, [1 1 3]);
%     diffImageHere(diffImageHere<maxImage) = meanImageFramesHere(diffImageHere<maxImage);
    imagesc(colorDiffImageHere);
    colormap(cmap);
    caxis([cmin cmax])
    colorbar
    hold on
    h = imagesc(meanImageFramesHere);
    set(h, 'AlphaData', alph);
    
%     num_rois_cell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
%     if ~isempty(num_rois_cell)
%         num_rois_str = num_rois_cell{1};
%         num_rois = str2num(num_rois_str);
%     else
%         num_rois=0;
%     end
    num_rois = 1;

    
    
    if num_rois==0
        warning('No ROIs selected; old ROIs are being maintained');
        newROIData = roi_data;
    else
        erodeStructure = strel([1 1 1; 1 1 1; 1 1 1]);
        nextComponent = 1;
        for i = 1:size(gleanedImagesCropped, 3)
            ROIImage = gleanedImagesCropped(:, :, i);
            erodedImage = imerode(logical(ROIImage), erodeStructure);
            
            connectedComponents = bwconncomp(logical(erodedImage));
            componentSize = cellfun(@length, connectedComponents.PixelIdxList);
            
            blankROI = logical(zeros(size(ROIImage)));
            componentsOfInterest = connectedComponents.PixelIdxList(componentSize > .5*std(componentSize));
            for j = 1:length(componentsOfInterest)
                roiMask = blankROI;
                roiMask(componentsOfInterest{j}) = true;
                roiMaskWithBorder = logical(zeros(size(meanImageFrames)));
                roiMaskWithBorder(imageCropPixelBorder+1:imageCropPixelBorder+size(meanImageFramesHere, 1), imageCropPixelBorder+1:imageCropPixelBorder+size(meanImageFramesHere, 2)) = roiMask;
                polygon = mask2poly(roiMaskWithBorder, 'Exact', 'CW');
                distTest = sqrt(polygon(:,1).^2+polygon(:, 2).^2);
                polygon(abs(distTest-mean(distTest))>std(distTest), :) = [];
                tempROIData.mask{j+nextComponent-1} = roiMaskWithBorder;
                tempROIData.points{j+nextComponent-1} = polygon;
                tempROIData.diffComparison{j+nextComponent-1} = i;
            end
            nextComponent = nextComponent + j;
            
            %         %linear ROI
            %         title(['Create a polygon surrounding your ROI for the ' num_rois_str ' ROI(s). Double click twice to finish each one.']);
            %
            %         %We're gonna store these rois in a cell
            %         %     roi_data = cell(0);
            %         for i = 1:num_rois
            %             [roi_mask x y] = roipoly;
            %             roiMaskWithBorder = logical(zeros(size(meanImageFrames)));
            %             roiMaskWithBorder(imageCropPixelBorder+1:imageCropPixelBorder+size(meanImageFramesHere, 1), imageCropPixelBorder+1:imageCropPixelBorder+size(meanImageFramesHere, 2)) = roi_mask;
            %             newROIData.mask{i} = roiMaskWithBorder;
            %             newROIData.points{i} = [x+imageCropPixelBorder y+imageCropPixelBorder];
            %         end
        end
        
        maskArray = zeros(size(tempROIData.mask{1}, 1), size(tempROIData.mask{1}, 2), length(tempROIData.mask));
        % Could do with a reshape, didn't want to think about it
        for tempDataInd = 1:length(tempROIData.mask)
            maskArray(:, :, tempDataInd) = tempROIData.mask{tempDataInd};
        end
        
        for tempDataInd = 1:length(tempROIData.mask)
            newMask = logical(prod(cat(3, maskArray(:, :, tempDataInd), ~gleanedImages(:, :, [1:tempROIData.diffComparison{tempDataInd}-1, tempROIData.diffComparison{tempDataInd}+1:end])), 3));
            polygon = mask2poly(newMask, 'Exact', 'CW');
            distTest = sqrt(polygon(:,1).^2+polygon(:, 2).^2);
            polygon(abs(distTest-mean(distTest))>std(distTest), :) = [];
            newROIData.mask{tempDataInd} = newMask;
            newROIData.points{tempDataInd} = polygon;
        end
        
        erodedImage = imerode(logical(imageSummed), erodeStructure);
        % Resave the background because you basically can't see it in the new
        % image
        bkgdSize = round(size(erodedImage)./8);
        bkgdMaskBase = ones(bkgdSize(1), bkgdSize(2));
        bkgdCheck = conv2(double(erodedImage), double(bkgdMaskBase), 'same');
        bkgdCheckOfInterest = bkgdCheck(ceil(bkgdSize(1)/2):end-floor(bkgdSize(1)/2), ceil(bkgdSize(2)/2):end-floor(bkgdSize(2)/2));
        [~, inds] = sort(bkgdCheckOfInterest(:));
        topLeftCornerRow = floor((inds(1)-1)/size(bkgdCheckOfInterest, 1))+1;
        topLeftCornerCol = mod(inds(1)-1, size(bkgdCheckOfInterest,1))+1;
        bkgdMask = zeros(size(meanImageFrames));
        bkgdMask(topLeftCornerRow:bkgdSize(1)+topLeftCornerRow-1,topLeftCornerCol:bkgdSize(2)+topLeftCornerCol-1) = bkgdMaskBase;
        bkgdPoints = mask2poly(bkgdMask, 'Exact', 'CW');

        newROIData.mask{end+1} = logical(bkgdMask);
        newROIData.points{end+1} = bkgdPoints;
        
        saveVariables.roi_data = newROIData;
        saveOrAppendMatFile([name '.mat'], saveVariables);
    end
% end