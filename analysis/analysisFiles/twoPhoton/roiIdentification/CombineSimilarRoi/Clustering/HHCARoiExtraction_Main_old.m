function roiMaskFinal_renamed = HHCARoiExtraction_Main_old(edgeTraceInitial, pixelInUse,varagin)

[nPixelVer,nPixelHor ]= size(pixelInUse);

gridSizeInit = 4; % that is 4 * 4.
gridIndStartVer = 1:gridSizeInit:nPixelVer;
gridIndStartHor = 1:gridSizeInit:nPixelHor;
nGridVer = length(gridIndStartVer); nGridHor = length(gridIndStartHor);

N = size(edgeTraceInitial,2) ;
% indPixelInUse = find(pixelInUse > 0);
% centerOfMAssInitial = zeros(2,N);
% [centerOfMAssInitial(1,:),centerOfMAssInitial(2,:)] = ind2sub([nPixelVer,nPixelHor],indPixelInUse);
roiMaskInitial = double(pixelInUse(:)); roiMaskInitial(roiMaskInitial(:) > 0) = 1:1:N; roiMaskInitial = reshape(roiMaskInitial,[nPixelVer,nPixelHor ]);
% do this for several grids.pixelInUse

edgeTraceGrid = cell(nGridVer,nGridHor);
roiMaskGrid = cell(nGridVer,nGridHor);
objNameGrid = cell(nGridVer,nGridHor);

% parameter for the first round.
% the threshold hold will be changing all the time. look at the
% distribution
objNameNext = N + 1;
corrThresh = 0.4;
distThresh = 5;
% tic
for jj = 1:1:nGridHor
    for ii = 1:1:nGridVer
        roiWindowThisGrid = false(nPixelVer,nPixelHor);
        roiWindowThisGrid(gridIndStartVer(ii):min([gridIndStartVer(ii)+gridSizeInit - 1,nPixelVer]),gridIndStartHor(jj):min([gridIndStartHor(jj)+gridSizeInit - 1,nPixelHor])) = true;
        pixelInUseThisGrid = roiMaskInitial(roiWindowThisGrid);
        objNameThisGrid = pixelInUseThisGrid(pixelInUseThisGrid > 0);
        
        % there are more than one edgeTrace
        if ~isempty(objNameThisGrid)
            % if it is only one object in it. it is okay..
            edgeTraceThisGrid = edgeTraceInitial(:,objNameThisGrid);
            roiMaskThisGrid = roiMaskInitial.* roiWindowThisGrid;
            % this things can be calculated inside your function....
            [edgeTraceGrid{ii,jj},roiMaskGrid{ii,jj},objNameGrid{ii,jj},objNameNext] ...
                = MyHHCA_Utils_ClusterInOneGrid(edgeTraceThisGrid,roiMaskThisGrid,objNameThisGrid,objNameNext, 'corrThresh',corrThresh, 'distThresh',distThresh, 'plotFlag',false);
        end
        
    end
end

%% second round clustering. clustering nearby grid.
K = 2; corrThresh = 0.7; distThresh = 10;
[edgeTraceLargeGrid,roiMaskTLargeGrid,objNameLargeGrid,objNameNext] ...
    = MyHHCA_Utils_CombineGrids_SingleRound(edgeTraceGrid,roiMaskGrid,objNameGrid,objNameNext,'plotFlag',false,'corrThresh',corrThresh, 'distThresh',distThresh);

%% third round clustering. clustering all of them.
roiMaskAll =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(roiMaskTLargeGrid,'roiMask');
edgeTraceAll = MyHHCA_Utils_CombineGrids_SingleRound_CombineData(edgeTraceLargeGrid ,'edgeTrace'); % 7798. clusters. not much have been combined. 100 of them. s
objNameAll = MyHHCA_Utils_CombineGrids_SingleRound_CombineData(objNameLargeGrid,'objName');

% truncate the roi which is too small
minRoiSize = 3;
[edgeTraceTrunc,roiMaskTrunc,objNameTrunc] = MyHHCA_Utils_CleanUpSmallRoi(edgeTraceAll,roiMaskAll,objNameAll,minRoiSize); % most of them are thrown. 442 is left it pixel is 1.

% final round of clustering
corrThresh = 0.75;
distThresh = 15;
[edgeTraceFinal,roiMaskFinal,objNameFinal,objNameNextFinal] ...
    = MyHHCA_Utils_ClusterInOneGrid(edgeTraceTrunc,roiMaskTrunc,objNameTrunc,objNameNext,'corrThresh',corrThresh, 'distThresh',distThresh, 'plotFlag',false);

%% 
roiMaskFinal_renamed = roiMaskFinal;
roiname = unique(roiMaskFinal_renamed(:));
for ii = 1:1:length(roiname) - 1
    roiMaskFinal_renamed(roiMaskFinal_renamed == objNameFinal(ii)) = ii;
end

