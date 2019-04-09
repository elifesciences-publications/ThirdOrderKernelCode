function  corr_all = MyHHCA_Utils_AdaptiveCorrThresh_CalculateInitialCorrVec(edgeTraceSmallGrid,roiMaskSmallGrid,objNameSmallGrid, varargin)
data_structure = 'grid_array';
gridSize = 2; % combine 2 * 2 grids every time, if each grid is a single pixel, grid size would be 4 * 4.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

switch data_structure
    case 'grid_array'
        % this would determined by
        if grid_is_initial_pixel
            [nGridVerSmall,nGridHorSmall] = size(roiMaskSmallGrid);
        else
            [nGridVerSmall,nGridHorSmall] = size(edgeTraceSmallGrid);
        end
        
        gridIndStartVer = 1:gridSize:nGridVerSmall;
        gridIndStartHor = 1:gridSize:nGridHorSmall;
        nGridVerLarge = length(gridIndStartVer); nGridHorLarge = length(gridIndStartHor);
        corr_all = [];
        
        % write a function to calculate it , do not mess it with other.
        
        for jj = 1:1:nGridHorLarge
            for ii = 1:1:nGridVerLarge
                verInd = gridIndStartVer(ii) : min(gridIndStartVer(ii) + gridSize - 1,nGridVerSmall);
                horInd = gridIndStartHor(jj) : min(gridIndStartHor(jj) + gridSize - 1,nGridHorSmall);
                
                % you would decide wether initialize the window or not.
                if grid_is_initial_pixel
                    roiWindowThisGrid = false(nGridVerSmall,nGridHorSmall);
                    roiWindowThisGrid(verInd,horInd) = true;
                    pixelInUseThisGrid = roiMaskSmallGrid(roiWindowThisGrid);
                    objNameThisGrid = pixelInUseThisGrid(pixelInUseThisGrid > 0);
                    
                else
                    objNameThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(objNameSmallGrid(verInd,horInd),'objName');
                end
                
                
                if ~isempty(objNameThisGrid)
                    if grid_is_initial_pixel
                        edgeTraceThisGrid = edgeTraceSmallGrid(:,objNameThisGrid); % if each grid is a single pixel, then the edgeTraceSmallGrid would be time by obejNameThisGrid.
                    else
                        edgeTraceThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(edgeTraceSmallGrid(verInd,horInd),'edgeTrace');
                    end
                    
                    
                    N = size(edgeTraceThisGrid,2);
                    if N > 1
                        if smoothEdgeFlag
                            edgeTraceSmoothThisGrid = smooth(edgeTraceThisGrid(:),5);
                            edgeTraceSmoothThisGrid = reshape(edgeTraceSmoothThisGrid ,size(edgeTraceThisGrid));
                            edgeTraceForCorrInit = edgeTraceSmoothThisGrid;
                        else
                            edgeTraceForCorrInit = edgeTraceThisGrid;
                        end
                        corrMatInit = corr( edgeTraceForCorrInit); % only 7 seconds! cool!
                        corrVec = corrMatInit(tril(true(N,N),-1));
                        
                        corr_all = [corr_all; corrVec];
                    end
                    
                    
                end
            end
        end
    case 'grid_single'
        edgeTraceThisGrid = edgeTraceSmallGrid; % all of
        N = size(edgeTraceThisGrid,2);
        
        if smoothEdgeFlag
            edgeTraceSmoothThisGrid = smooth(edgeTraceThisGrid(:),5);
            edgeTraceSmoothThisGrid = reshape(edgeTraceSmoothThisGrid ,size(edgeTraceThisGrid));
            edgeTraceForCorrInit = edgeTraceSmoothThisGrid;
        else
            edgeTraceForCorrInit = edgeTraceThisGrid;
        end
        corrMatInit = corr( edgeTraceForCorrInit); % only 7 seconds! cool!
        corrVec = corrMatInit(tril(true(N,N),-1));
        
        corr_all = corrVec;
end
end% judge wether it is zeros.