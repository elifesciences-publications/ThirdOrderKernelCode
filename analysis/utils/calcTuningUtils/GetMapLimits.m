function [mapLimits,mapLimitsCentered] = GetMapLimits(powerMap,tw,powerMapSem,mapCenterValue)
    numMaps = length(powerMap);

    if nargin<2
        tw = cell(numMaps,1);
        for mm = 1:numMaps
            tw{mm} = 1;
        end
    end
    
    if nargin<3 || isempty(powerMapSem)
        for mm = 1:numMaps
            powerMapSem{mm} = zeros(size(powerMap{mm}));
        end
    end
    
    if nargin<4 || isempty(mapCenterValue)
        mapCenterValue = [0 1]; % center maps around 0 for turning and 1 for walking
    end

    % map limits of the form [minTurn minWalk; maxTurn maxWalk];
    % just set the max min values to a very high / very low value that will
    % be overwritten
    tempMaxPlaceholder = 5000;
    mapLimits = [tempMaxPlaceholder tempMaxPlaceholder; -tempMaxPlaceholder -tempMaxPlaceholder];
        
    for mm = 1:numMaps
        %% set the maximum and minimum values of the power maps.
        % map limits is [turnMin walkMin; turnMax walkMax]

        % this gets the max / min values of the current power map. Compare
        % against the error added and subtracted matricies make sure it the limits
        % dont cut off errrobars
        tempMin = min(min([powerMap{mm}+powerMapSem{mm} powerMap{mm}-powerMapSem{mm}]));
        tempMax = max(max([powerMap{mm}+powerMapSem{mm} powerMap{mm}-powerMapSem{mm}]));

        if tempMin < mapLimits(1,tw{mm})
            mapLimits(1,tw{mm}) = tempMin;
        end

        if tempMax > mapLimits(2,tw{mm})
            mapLimits(2,tw{mm}) = tempMax;
        end
    end
    
    % round the mapLimits to give them wiggle room
    mapLimits(1,:) = floor(mapLimits(1,:)*10)/10;
    mapLimits(2,:) = ceil(mapLimits(2,:)*10)/10;
    
    % set the centered limits to center around mapCenterValue
    mapLimitsAbs = max(abs(bsxfun(@minus,mapLimits,mapCenterValue)));
    mapLimitsCentered = bsxfun(@plus,[-mapLimitsAbs; mapLimitsAbs],mapCenterValue);
end