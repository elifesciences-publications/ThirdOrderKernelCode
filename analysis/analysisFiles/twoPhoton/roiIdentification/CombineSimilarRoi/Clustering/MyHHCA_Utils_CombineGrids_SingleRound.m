function [edgeTraceLargeGrid,roiMaskTLargeGrid,objNameLargeGrid,objNameNext]...
    = MyHHCA_Utils_CombineGrids_SingleRound(edgeTraceSmallGrid,roiMaskSmallGrid,objNameSmallGrid,objNameNext,varargin)
testing_mode = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

gridSize = 2; % combine 2 * 2 grids every time
[nGridVerSmall,nGridHorSmall] = size(edgeTraceSmallGrid);
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
        objNameThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(objNameSmallGrid(verInd,horInd),'objName');
        if ~isempty(objNameThisGrid)
            roiMaskThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(roiMaskSmallGrid(verInd,horInd),'roiMask');
            edgeTraceThisGrid =  MyHHCA_Utils_CombineGrids_SingleRound_CombineData(edgeTraceSmallGrid(verInd,horInd),'edgeTrace');
            
            % 
            [edgeTraceLargeGrid{ii,jj},roiMaskTLargeGrid{ii,jj},objNameLargeGrid{ii,jj},objNameNext, extraVarsOut]...
                = MyHHCA_Utils_ClusterInOneGrid(edgeTraceThisGrid,roiMaskThisGrid,objNameThisGrid,objNameNext,varargin{:});
            
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

% can you calculate the thing before even started? should be easy.

% 99.95 is a good threshold. because it is already high.
if testing_mode
    corr_vec_start = [];
    corr_vec_end = [];
   
    for jj = 1:1:nGridHorLarge
        for ii = 1:1:nGridVerLarge
            % for each one, ask whether it is empty
            if ~isempty(testing_corrVec{jj,ii}) && ~isempty(testing_corrVec{jj,ii}{1})
                corr_vec_start = [corr_vec_start;testing_corrVec{jj,ii}{1}];
                corr_vec_end =  [corr_vec_end;testing_corrVec{jj,ii}{end}];
            end
        end
    end
     MakeFigure;
    subplot(2,2,1);
    h{1} = histogram(corr_vec_start);
    hold on
    h{2}= histogram(corr_vec_end);
    Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);
end
end