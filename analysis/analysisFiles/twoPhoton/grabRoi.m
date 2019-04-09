function Z = grabRoi( Z, varargin )
% Takes the output of grabAlignMovie and checks whether ROIs exist for this
% movie already. If they do, loads these ROIs. If they do not, or if the
% user choses to force new ROIs, runs one of the ROI-creation scripts. In
% either case, outputs ROI maps in Z.ROI.

%% Default variables
ROItype = 'differentialWatershed';
BGtype = 'lowVar';

loadFlexibleInputs(Z)

%% Pick up relevant variables from
imgFrames = Z.grab.imgFrames;

%% Decide whether to make new ROIs or load saved ones

makeROIs = 1;
if exist([name '.mat'],'file')
    matVars = who('-file',[name '.mat']);
    if any(strcmp('roiMasks',matVars)) && ~force_new_ROIs
        makeROIs = 0;
        load([name '.mat'], 'roiMasks');
    end
end

%% If you're making new ROIs, make new ROIs

if makeROIs
    if linescan
        intensity = zeros(imgSize(1)*imgSize(3), imgSize(2));
        
        %We're grabbing each pixel of the line individually and plotting it
        %down! (Probably gonna change this to an ROI at some point)
        for i = 1:size(imgFrames, 2)
            intensity(:, i) = reshape(imgFrames(:, i, :), [imgSize(1)*imgSize(3), 1]);
        end
        
        
        roi_selection_lines = imgSize(1);
        roiImage = repmat(mean(intensity), roi_selection_lines, 1);
        
%         if false
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
            ROI.roiMasks = [];
            
            for i=1:num_rois
                roi_data.points{i} = [roi_x(2*i-1:2*i) [0; 0]; roi_x(2*i:-1:2*i-1) [roi_selection_lines+1; roi_selection_lines+1]; roi_x(2*i-1) 0];
                roi_data.roi_x = roi_x;
                blankMask = logical(zeros(size(roiImage)));
                blankMask(:, roi_x(2*i-1):roi_x(2*i)) = true;
                ROI.roiMasks = cat(3, ROI.roiMasks, blankMask);
            end
            
            title('Choose your rectangular ROI for background signal--left side first');
            [bkgd_x, bkgd_y] = ginput(2);
            cols_bkgd = round(bkgd_x);
            rows_bkgd = round(bkgd_y);
            
            roi_data.points{end+1} = [cols_bkgd(1:2) [0; 0]; cols_bkgd(2:-1:1) [roi_selection_lines+1; roi_selection_lines+1]; cols_bkgd(1) 0];
            roi_data.cols_bkgd = cols_bkgd;
            blankMask = logical(zeros(size(roiImage)));
            blankMask(:, cols_bkgd(1):cols_bkgd(2)) = true;
            ROI.roiMasks = cat(3, ROI.roiMasks, blankMask);
            
            close
%         else
%             ROI.roiMasks = ...
%                     watershedCluster( Z );
%         end
        
    else
        switch ROImethod
            case 'manual'
                ROI = manualRoi(Z);
                %                 case 'diffRoi'
                %                     ROI = diffRoi(Z);
                %                 case 'diffRoiPix'
                %                     ROI = diffRoiPix(Z);
                %                 case 'gridRoi'
                %                     ROI = gridRoi(Z);
            case 'edgeTypeRoi'
                ROI = edgeTypeRoi(Z);
                %                 case 'edgeTypePreAna'
                %                     edgeTypePixel(Z);
                %                 case 'medullaRoi'
                %                     ROI = medullaRoi(Z);
            case 'edgeTypeRoiCorr'
                ROI = edgeTypeRoiCorr(Z);
            case 'RoiIsBackGround'
                ROI = RoiIsBackGround(Z);
            case 'VarianceBasedWaterShed'
                ROI = VarianceBasedWaterShed(Z);
            case 'waterShed_NNMF'
                ROI = waterShed_NNMF(Z);
            case 'test'
                %                     ROI = waterShed_NNMF_CheckOneRoi(Z);
                ROI = MovementCheck_Juyue(Z);
            case 'ICA'
                ROI = ICA_Juyue(Z);
            case 'ICA_NNMF'
                ROI = ICA_NNMF(Z);
            case 'ICA_NNMF_DFOVERF'
                ROI = ICA_NNMF_DFOVERF(Z);
            case 'HCA'
                ROI = HCA_ROIIdentification(Z);
            otherwise
                ROI.roiMasks = ...
                    watershedCluster( Z );
        end
    end
else
    ROI.roiMasks = [];
    for q = 1:size(roiMasks,3)
        ROI.roiMasks = cat(3,ROI.roiMasks,roiMasks(:,:,q));
    end
end

%Make sure you've only got logical ROI masks!!
ROI.roiMasks = logical(ROI.roiMasks);
Z.params.nRoi = size(ROI.roiMasks,3)-1;

%% Compute their centers of mass, used in non-linescan alignment

roiCenterOfMass = zeros(size(ROI.roiMasks,3), 2);
for i = 1:size(ROI.roiMasks,3)
    [indRows, indCols] = find(ROI.roiMasks(:,:,i));
    ROI.roiCenterOfMass(i, :) = [mean(indRows) mean(indCols)];
end

%% Get out
Z.ROI = ROI;
fprintf('ROIs grabbed.\n'); toc

end

