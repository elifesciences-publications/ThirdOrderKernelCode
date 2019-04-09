function [edgeTrace,roiMask ,objName] =  MyHHCA_Utils_CleanUpSmallRoi(edgeTrace,roiMask,objName,minRoiSize)

    % finish this code...
    nRoi = length(objName);
    objDelete = [];
    for rr = 1:1:nRoi
        nameThis = objName(rr);
        indThis = find(objName == nameThis);
        if sum(sum(roiMask == nameThis)) <= minRoiSize
            roiMask(roiMask == nameThis) = 0;
            objDelete = [objDelete;indThis];
        end
    end
    edgeTrace(:,objDelete) = [];
    objName(objDelete) = [];
    
end