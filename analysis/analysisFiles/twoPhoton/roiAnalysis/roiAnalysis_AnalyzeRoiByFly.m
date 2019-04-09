function roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData)
nRoi = length(roiData);
roiByFly = [];
filepathAll = []; % how do you search? for loop...
clear flyThis
% continue your work, after group meeting, go to the gym. or now? not right
% after lunch...

%
cfile = 0;
for rr = 1:1:nRoi
    filepathThis = roiData{rr}.stimInfo.filepath;
    newFileFlag = isempty(strfind(filepathAll,filepathThis));
    % search, whether this name has already been there before.
    if newFileFlag
        cfile = cfile + 1;
        if exist('flyThis','var')
            roiByFly = [roiByFly; flyThis];
            clear flyThis;
        end
        filepathAll = [filepathAll,'; ',filepathThis];
        flyThis.filepath = filepathThis;
        flyThis.roiUse  = cell(1,1);
        flyThis.roiUse = rr;
        
    else
        flyThis.roiUse = [flyThis.roiUse;rr];
    end
    
end
% last one.
roiByFly = [roiByFly; flyThis];

% there are 32 flies in this file....
% do you want to get the thing out? why not...
% first, plot the roi, for one fly and one kernel...

% what do you need? roiData itself, and roiByFly, that structure....c
% something wrong in the code. fix it...
% roiDataByFly = size(cfile,1);
% % do you only store the roiUse?
% % it will be fine...
% for ff = 1:1:cfile
%     % get all the roiUse out.
%     % forget about his countour... might be bad idea...
%     roiUseThisFile = roiByFly(ff).roiUse;
%     filepathThisFile = roiByFly(ff).filepath;
% %     roiMethod = 'ICA_NNMF';
% %     
% %     % what is your worry? you think the double lobe comes from the nearby two
% %     % cells.
% %     
% %     % get another function to do this. now, using the function to return
% %     % you the roi in one fly...
% %     FigPlot_MeanImgWithRoiMaskPerFly(roiData,roiUseThisFile,filepathThisFile,'roiMethod',roiMethod);
% %     roiDataThisFile = roiData(roiUseThisFile);
% %     ViewFirstOrderKernelsByType(roiDataThisFile);
% end
end
% you just have to show the kernel, that is all, so easy.
% given roiUse, give map...
% just show mean image, countour on them, and show the filter and
% traces...% all in one figure;;; 30 rois and 30 traces in one fly......






