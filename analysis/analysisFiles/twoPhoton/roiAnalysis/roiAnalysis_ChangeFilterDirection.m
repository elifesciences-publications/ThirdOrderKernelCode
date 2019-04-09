function roiData = roiAnalysis_ChangeFilterDirection(roiData,varargin)
% roiData = roiAnalysis_ChangeFilterDirection(roiData,'method','corChangeAndCentered','methodFilterCenter','prob')


method = 'corChangeAndCentered';
methodFilterCenter = 'prob';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{', num2str(ii + 1) '};']);
end
%
% the adjusted filter is the flipped version.
nRoi = length(roiData);
% before anything, but the kernel with the correct units...
stimHZ = 60; 
unitTime = 1/stimHZ;
for rr = 1:1:nRoi
    roiData{rr}.filterInfo.firstKernel.Original = roiData{rr}.filterInfo.firstKernel.Original./unitTime;
    roiData{rr}.filterInfo.secondKernel.dx1.Original = roiData{rr}.filterInfo.secondKernel.dx1.Original./(unitTime)^2;
    roiData{rr}.filterInfo.secondKernel.dx2.Original = roiData{rr}.filterInfo.secondKernel.dx2.Original./(unitTime)^2;
%     roiData{rr}.filterInfo.secondKernel.shuffle.gliderResp.resp = roiData{rr}.filterInfo.secondKernel.shuffle.gliderResp.resp/(unitTime)^2;

end
switch method
    case 'corChangeOnly'
        for rr = 1:1:nRoi
            roi = roiData{rr};
            flyEye = roi.flyInfo.flyEye;
            kernelType = roi.filterInfo.kernelType;
            % there are four filters to be changed.
            
            if strcmp(flyEye,'Right') || strcmp(flyEye,'right')
                roi.filterInfo.firstKernelAdjusted = fliplrKernel(roi.filterInfo.firstKernelOriginal,1);
                roi.filterInfo.secondKernelAdjusted = fliplrKernel(roi.filterInfo.secondKernelOriginal,2);
                roi.filterInfo.secondKernelAdjusted = fliplrKernel(roi.filterInfo.secondKernelOriginal,2);
            else
                roi.filterInfo.firstKernelAdjusted = roi.filterInfo.firstKernelOriginal;
                roi.filterInfo.secondKernelAdjusted = roi.filterInfo.secondKernelOriginal;
                roi.filterInfo.secondKernelAdjusted = roi.filterInfo.secondKernelOriginal;
            end
            roiData{rr} = roi;
        end
    case 'corChangeAndCentered'
        % the adjusted filter is the centered and flipped version.
        %         roiData = roiAnalysis_CorrectionWrongTrace(roiData);
        for rr = 1:1:nRoi
            roi = roiData{rr};
            flyEye = roi.flyInfo.flyEye;
            
            if strcmp(flyEye,'right') || strcmp(flyEye,'Right')
                % there are two first order filters you have to deal with.
                % you have to flip first, and then shift.
                
                barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter',methodFilterCenter);
                roi.filterInfo.barCenter = barCenter;
                % there are 6 things for every fly...
                firstFilterCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfo.firstKernel.Original,barCenter);
                roi.filterInfo.firstKernel.Adjusted = fliplrKernel(firstFilterCentered,1);
                
                % I want to change the structure to be more elegant.
%                 firstFilterZCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfo.firstKernel.Z,barCenter);
%                 roi.filterInfo.firstKernel.ZAdjusted = fliplrKernel(firstFilterZCentered,1);
%                 
%                 firstFilterSmoothZCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfo.firstKernel.smoothZ,barCenter);
%                 roi.filterInfo.firstKernel.smoothZAdjusted = fliplrKernel(firstFilterSmoothZCentered,1);
%                 
                
                
                roi.filterInfo.secondKernel.dx1.Adjusted = fliplrKernel(roi.filterInfo.secondKernel.dx1.Original,2);
%                 roi.filterInfo.secondKernel.dx1.ZAdjusted = fliplrKernel(roi.filterInfo.secondKernel.dx1.Z,2);
%                 roi.filterInfo.secondKernel.dx1.smoothZAdjusted = fliplrKernel(roi.filterInfo.secondKernel.dx1.smoothZ,2);
%                 
                roi.filterInfo.secondKernel.dx2.Adjusted = fliplrKernel(roi.filterInfo.secondKernel.dx2.Original,2);
%                 roi.filterInfo.secondKernel.dx2.ZAdjusted = fliplrKernel(roi.filterInfo.secondKernel.dx2.Z,2);
%                 roi.filterInfo.secondKernel.dx2.smoothZAdjusted = fliplrKernel(roi.filterInfo.secondKernel.dx2.smoothZ,2);
                
                
                roiData{rr} = roi;
            else
                barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter',methodFilterCenter);
                roi.filterInfo.barCenter = barCenter;
                  
                firstFilterCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfo.firstKernel.Original,barCenter);
                roi.filterInfo.firstKernel.Adjusted = firstFilterCentered;
                
%                 firstFilterZCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfo.firstKernel.Z,barCenter);
%                 roi.filterInfo.firstKernel.ZAdjusted = firstFilterZCentered;
%                 
%                 firstFilterSmoothZCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(roi.filterInfo.firstKernel.smoothZ,barCenter);
%                 roi.filterInfo.firstKernel.smoothZAdjusted = firstFilterSmoothZCentered;
%                 
                roi.filterInfo.secondKernel.dx1.Adjusted = roi.filterInfo.secondKernel.dx1.Original;
%                 roi.filterInfo.secondKernel.dx1.ZAdjusted = roi.filterInfo.secondKernel.dx1.Z;
%                 roi.filterInfo.secondKernel.dx1.smoothZAdjusted = roi.filterInfo.secondKernel.dx1.smoothZ;
%                 
                roi.filterInfo.secondKernel.dx2.Adjusted = roi.filterInfo.secondKernel.dx2.Original;
%                 roi.filterInfo.secondKernel.dx2.ZAdjusted = roi.filterInfo.secondKernel.dx2.Z;
%                 roi.filterInfo.secondKernel.dx2.smoothZAdjusted = roi.filterInfo.secondKernel.dx2.smoothZ;
                             
                roiData{rr} = roi;
            end
            % your function works perfectly... good...
            roiData{rr} = roiAnalysis_OneRoi_AlignSecondKernel(roiData{rr});
        end
end