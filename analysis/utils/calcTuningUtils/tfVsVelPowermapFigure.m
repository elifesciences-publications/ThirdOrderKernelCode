function ComparePowermapFigure(powerMapIntTf,powerMapIntVel,sfMeshLog,tfMeshLog,velMeshLog,pTfVsVelSvd)
    numMaps = length(powerMapIntTf); % the number of power maps to deal with
    
    % tw is a variable that determines whether the corresponding map is
    % turning or walking data. If this array is too small, assume the data
    % is for walking
    tw = cell(numMaps,1);
    tw = cellfun(@(x){2},tw); % initialize cell array to assume walking data
    
    for in = 1:length(twIn)
        tw{in} = twIn(in);
    end
    
    powerMap = cell(numMaps,1);
    powerMapSem = cell(numMaps,1);
    powerMapInd = cell(numMaps,1);
    
    for mm = 1:numMaps
        %% read in varargin input
        % but only taking turning or walkign depending on tw

        powerMap{mm} = varargin{mm}.powerMap(:,:,tw{mm});
        powerMapSem{mm} = varargin{mm}.powerMapSem(:,:,tw{mm});

        powerMapInd{mm} = cell(length(varargin{mm}.powerMapInd),1);
        for ii = 1:length(varargin{mm}.powerMapInd)
            powerMapInd{mm}{ii} = varargin{mm}.powerMapInd{ii}(:,:,tw{mm});
        end

        lambda{mm} = varargin{mm}.lambda;

        tf{mm} = varargin{mm}.tf;

        % count the number of flies in each powerMap
        numFlies{mm} = varargin{mm}.numFlies;
        numTotalFlies{mm} = varargin{mm}.numTotalFlies;
    end
end