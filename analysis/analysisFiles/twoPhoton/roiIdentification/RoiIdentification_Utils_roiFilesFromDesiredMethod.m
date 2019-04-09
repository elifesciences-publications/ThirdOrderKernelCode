function roiFilesFromDesiredMethod = RoiIdentification_Utils_roiFilesFromDesiredMethod(roiFileName,roiMethod)
roiFilesFromDesiredMethod = false;
expression = '\d+_\d+_\d+';
% expression = '[0-9]'; % you should check for time, not only number...
[a] = regexp(roiFileName,expression); % a(1) is the first character of time.
if ~isempty(a)
    roiMethodThisFile = roiFileName(1:a - 2);
    if isequal(roiMethodThisFile ,roiMethod)
        roiFilesFromDesiredMethod = true;
    end
end
end