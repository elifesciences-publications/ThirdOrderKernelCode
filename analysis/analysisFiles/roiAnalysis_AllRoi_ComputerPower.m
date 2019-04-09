function roiData = roiAnalysis_AllRoi_ComputerPower(roiData)
    nRoi = length(roiData);
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_OneRoi_OLS_ComputePower(roiData{rr});
    end
end