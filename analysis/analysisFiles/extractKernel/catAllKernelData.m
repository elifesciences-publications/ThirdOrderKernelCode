function D = catAllKernelData(varargin)
    % cross-correlates a 2D flicker input with the turning response to
    % extract the Wiener kernel of whatever order. Defaults to second order.
    
    
    %% Set default parameters you may want to change with a varargin
 
         
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    dataFolder = C{1}{1};
    
    meanSubtract = 0;
    interp = 'linear';  
    
    %% Vararararararar
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Get data path
    
    if exist('testData','var')
        D = testData;    
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',meanSubtract,'normMouseRead',0,'rollSize',1);
    elseif exist('dataPath','var')
        D = grabData(dataPath);
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',meanSubtract);
    else
        D = grabData();
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',meanSubtract);
    end
    
    D.analysis.analysisParams.interp = interp;
    D.analysis.OD = OD;
    
    %% Loop through individual files (= a 20 min run) within the folders you chose, 
    %  extract individual kernels and save individually. Downscript files
    %  can then average and play with these kernels.
    
    allStimTraces = [];
    allTurnTraces = [];
    allWalkTraces = [];
    
    for q = 1:OD.numFiles

        D.kernelData.whichFile =  diff(OD.rig) < 1;
        D.kernelData.whichFile = [0 cumsum(D.kernelData.whichFile)] + 1;
        
        kernelData = getKernelData(D,OD,q);
        allStimTraces = [allStimTraces kernelData.stimTraces];
        allTurnTraces = [allTurnTraces kernelData.turnTraces];
        allWalkTraces = [allWalkTraces kernelData.walkTraces];
        
    end
    
    D.allStimTraces = allStimTraces;
    D.allTurnTraces = allTurnTraces;
    D.allWalkTraces = allWalkTraces;
                
end
