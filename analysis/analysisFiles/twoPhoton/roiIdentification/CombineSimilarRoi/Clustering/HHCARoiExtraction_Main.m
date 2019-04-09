function roiMaskFinal_renamed = HHCARoiExtraction_Main(edgeTraceInitial, pixelInUse)
% this looks so clean now.
smoothEdgeFlag = true;

N = size(edgeTraceInitial,2) ;
roiMaskInitial = double(pixelInUse(:)); roiMaskInitial(roiMaskInitial(:) > 0) = 1:1:N; roiMaskInitial = reshape(roiMaskInitial, size(pixelInUse));
objNameNext = N + 1;
objNameInitial = 1:N;
%% first round clustering. clustering nearby pixels.
distThresh = 5;
corr_vec_all_initial = MyHHCA_Utils_AdaptiveCorrThresh_CalculateInitialCorrVec(edgeTraceInitial,roiMaskInitial,objNameInitial,'data_structure','grid_array','grid_is_initial_pixel', true,'gridSize', 4,'smoothEdgeFlag',smoothEdgeFlag);
corrThresh = prctile(corr_vec_all_initial,95);

[edgeTraceGrid,roiMaskGrid,objNameGrid,objNameNext] = ...
    MyHHCA_Utils_CombineGrids_SingleRound_General(edgeTraceInitial,roiMaskInitial,objNameInitial,objNameNext,...
    'corrThresh',corrThresh, 'distThresh',distThresh, 'plotFlag',false,' grid_is_initial_pixel', true,'gridSize', 4,'smoothEdgeFlag',smoothEdgeFlag);


%% second round clustering. clustering nearby grid.
distThresh = 10;
corr_vec_all_grid = MyHHCA_Utils_AdaptiveCorrThresh_CalculateInitialCorrVec(edgeTraceGrid,roiMaskGrid,objNameGrid,'data_structure','grid_array','grid_is_initial_pixel', false,'gridSize', 2,'smoothEdgeFlag',smoothEdgeFlag);
corrThresh = prctile(corr_vec_all_grid,99.95);

[edgeTraceLargeGrid,roiMaskTLargeGrid,objNameLargeGrid,objNameNext] ...
    = MyHHCA_Utils_CombineGrids_SingleRound_General(edgeTraceGrid,roiMaskGrid,objNameGrid,objNameNext,...
    'plotFlag',false,'corrThresh',corrThresh, 'distThresh',distThresh,'grid_is_initial_pixel', false,'gridSize', 2,'smoothEdgeFlag',smoothEdgeFlag);

%% third round clustering. clustering all of them.
roiMaskAll =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(roiMaskTLargeGrid,'roiMask');
edgeTraceAll = MyHHCA_Utils_CombineGrids_SingleRound_CombineData(edgeTraceLargeGrid ,'edgeTrace'); % 7798. clusters. not much have been combined. 100 of them. s
objNameAll = MyHHCA_Utils_CombineGrids_SingleRound_CombineData(objNameLargeGrid,'objName');

% truncate the roi which is too small
minRoiSize = 3;
[edgeTraceTrunc,roiMaskTrunc,objNameTrunc] = MyHHCA_Utils_CleanUpSmallRoi(edgeTraceAll,roiMaskAll,objNameAll,minRoiSize); % most of them are thrown. 442 is left it pixel is 1.

%% final round of clustering
distThresh = 15;
corr_vec_all_final = MyHHCA_Utils_AdaptiveCorrThresh_CalculateInitialCorrVec(edgeTraceTrunc,roiMaskTrunc,objNameTrunc,'data_structure','grid_single','smoothEdgeFlag',smoothEdgeFlag);
corrThresh = prctile(corr_vec_all_final, 97.5);

[edgeTraceFinal,roiMaskFinal,objNameFinal,objNameNextFinal] ...
    = MyHHCA_Utils_ClusterInOneGrid(edgeTraceTrunc,roiMaskTrunc,objNameTrunc,objNameNext,'corrThresh',corrThresh, 'distThresh',distThresh, 'plotFlag',false,'smoothEdgeFlag',smoothEdgeFlag);

%% 
roiMaskFinal_renamed = roiMaskFinal;
roiname = unique(roiMaskFinal_renamed(:));
for ii = 1:1:length(roiname) - 1
    roiMaskFinal_renamed(roiMaskFinal_renamed == objNameFinal(ii)) = ii;
end

% come back to debug on this tomorrow morning.