function  alignRespStim = filterRoiTrace_Utils_SubtractBleedThrough_ForMultiBarFlicker(alignRespStim,stimData, Z)
  % read the background kernel from the datafile. 
    % it will be stored in the ROIs. 
    filename = Z.params.filename;
    bckgkernel = filterRoiTraces_Utils_GetBackgroundKernel(filename);
    
    % calculate the proper subtract off from each roi.roiTrace,stimulusIndexesForRoi,stimData,bckgkernel
     bt_subtracted = filterRoiTrace_Utils_CalculateBleedThroughTimeTraces(alignRespStim.resp,alignRespStim.stimIndexes,stimData,bckgkernel);
     
     nRoi = length(bt_subtracted);
     bt_subtracted_normalized = cell(nRoi,1);
     for rr = 1:1:nRoi
        bt_subtracted_normalized{rr} =  filterRoiTraces_Utils_FitExpAndNormalize(bt_subtracted{rr},bt_subtracted{rr},1,length(bt_subtracted{rr}));
     end
     
     alignRespStim.resp = bt_subtracted_normalized;
end