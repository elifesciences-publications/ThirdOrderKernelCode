function isoLines = GetIsolines(TW,numIsoLines,mapLimits,numLam,tfLog,varargin)
    % varargin is a set of lambdas, measured by multiple flies. average
    % across flies and combine into a powermap
    powerMap = zeros(size(varargin{1},1),length(varargin));
    
    for vv = 1:length(varargin);
        powerMap(:,vv) = mean(varargin{vv},2);
    end
    
    % find the max of the response. for turning this is a max, for
    % walking this is a min
    if TW == 1
        [~,maxLoc] = max(powerMap);
    else
        [~,maxLoc] = min(powerMap);
    end
    
    isoLinesToExtract = linspace(mapLimits(1),mapLimits(2),numIsoLines);

    % rows are different lambda, columns are different isolines
    isoLines = zeros(numLam,numIsoLines);

    % run through each lambda and interpolate to get the isoline
    % measured at one of the isoLineToExtract
    % only take values below the maximum TF (force it to be a function,
    % we're only investigating the tuned part of the curve)
    for lam = 1:numLam
        isoLines(lam,:) = interp1(powerMap(1:maxLoc(lam),lam),tfLog(1:maxLoc(lam)),isoLinesToExtract);
    end
end