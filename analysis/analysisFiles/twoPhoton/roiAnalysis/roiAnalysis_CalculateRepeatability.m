function roiData = roiAnalysis_CalculateRepeatability(roiData)

nRoi = length(roiData);
for rr = 1:1:nRoi
    roi = roiData{rr};
    trace = roi.typeInfo.trace;
    nEdge = 8;
    trace1 = [];
    trace2 = [];
    for qq = 1:1:nEdge
        trace1 = [trace1;trace{1,qq}];
        trace2 = [trace2;trace{2,qq}];
    end
    if find(isnan(trace1) == 1)
    keyboard;
    end
    roi.typeInfo.ccWholeTrace = corr(trace1,trace2);
    roiData{rr} = roi;
end


end