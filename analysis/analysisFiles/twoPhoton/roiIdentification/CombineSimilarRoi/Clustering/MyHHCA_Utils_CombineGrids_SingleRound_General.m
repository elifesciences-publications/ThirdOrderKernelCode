function [edgeTraceLargeGrid,roiMaskTLargeGrid,objNameLargeGrid,objNameNext] = ...
    MyHHCA_Utils_CombineGrids_SingleRound_General(edgeTraceSmallGrid,roiMaskSmallGrid,objNameSmallGrid,objNameNext,varargin)

gridSize = 2; % combine 2 * 2 grids every time, if each grid is a single pixel, grid size would be 4 * 4.
testing_mode = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% this would determined by
if grid_is_initial_pixel
    [nGridVerSmall,nGridHorSmall] = size(roiMaskSmallGrid);
else
    [nGridVerSmall,nGridHorSmall] = size(edgeTraceSmallGrid);
end
gridIndStartVer = 1:gridSize:nGridVerSmall;
gridIndStartHor = 1:gridSize:nGridHorSmall;
nGridVerLarge = length(gridIndStartVer); nGridHorLarge = length(gridIndStartHor);
% prepare the edgeTraces, roiMask, that is all? do you need objname? yes yes yes... everthing still... hard? or recompute. nice! do not
% do not store them? too much space?

% do this for several grids.
edgeTraceLargeGrid = cell(nGridVerLarge,nGridHorLarge);
roiMaskTLargeGrid = cell(nGridVerLarge,nGridHorLarge);
objNameLargeGrid = cell(nGridVerLarge,nGridHorLarge);

if testing_mode
    testing_corrVec = cell(nGridHorLarge,nGridVerLarge);
end
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
                roiMaskThisGrid = roiMaskSmallGrid.* roiWindowThisGrid; % if each grid is a single pixel, then the roiMaskSmallGrid would be initial roiMaskInitial.
            else
                roiMaskThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(roiMaskSmallGrid(verInd,horInd),'roiMask');
                edgeTraceThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(edgeTraceSmallGrid(verInd,horInd),'edgeTrace');
            end
            
            
            [edgeTraceLargeGrid{ii,jj},roiMaskTLargeGrid{ii,jj},objNameLargeGrid{ii,jj},objNameNext, extraVarsOut]...
                = MyHHCA_Utils_ClusterInOneGrid(edgeTraceThisGrid,roiMaskThisGrid,objNameThisGrid,objNameNext,varargin{:});
        end
        
        
        if testing_mode
            if ~isempty(extraVarsOut)
                extraVarNames = fieldnames(extraVarsOut);
                for extraVarNameInd = 1:length(extraVarNames)
                    extraVars.(extraVarNames{extraVarNameInd}) = extraVarsOut.(extraVarNames{extraVarNameInd});
                end
            end
            % for each individual one. preserve them.
            testing_corrVec{jj,ii} = extraVars.testing_corrVec;
            
        end
        
    end
end
end% judge wether it is zeros.