function dataOut = MyHHCA_Utils_CombineGrids_SingleRound_CombineData(dataIn,type)
% data will be x by y grids... always go from
switch type
    case 'edgeTrace'
        data = dataIn(:)';
        dataOut = cell2mat(data);
    case 'roiMask'
        data = dataIn(:)';
%         nGridNonEmpty = length(data);
        nonEmptyData = cellfun(@(x) ~isempty(x),data);
        nData = sum(nonEmptyData); oneNonEmptyData = find(nonEmptyData);
        dataMat = cell2mat(data);
        dataMat= reshape( dataMat,[size(data{oneNonEmptyData(1)}),nData]);
        dataOut = sum( dataMat,3);
    case 'objName'
        data = dataIn(:);
        dataOut = cell2mat(data);
        
end