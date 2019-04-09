function trimmedMap = TrimPowerMap(varargin)
    powerMap = zeros(length(varargin{1}.analysis{1}.respMatPlot),nargin,size(varargin{1}.analysis{1}.respMatPlot,3),size(varargin{1}.analysis{1}.respMatPlot,2));
    powerMapSem = zeros(length(varargin{1}.analysis{1}.respMatSemPlot),nargin,size(varargin{1}.analysis{1}.respMatPlot,3),size(varargin{1}.analysis{1}.respMatPlot,2));
    powerMapInd = cell(nargin,1);
    mapNames = cell(nargin,1);
    lambda = zeros(1,nargin);
    numFlies = zeros(1,length(varargin));
    numTotalFlies = zeros(1,length(varargin));
    
    for lam = 1:length(varargin);
        powerMap(:,lam,:,:) = permute(varargin{lam}.analysis{1}.respMatPlot,[1 4 3 2]);
        powerMapSem(:,lam,:,:) = permute(varargin{lam}.analysis{1}.respMatSemPlot,[1 4 3 2]);
        powerMapInd{lam} = varargin{lam}.analysis{1}.respMatIndPlot;
        
        mapNames{lam} = inputname(lam);
        
        tempLambda = mapNames{lam}(4:6);
        tempLambda(regexp(tempLambda,'\D')) = [];
        
        % try to determine if the map is turning or walking
        % unfortunately strfind is case sensitive so do both upper and
        % lower
        if ~isempty(strfind(mapNames{lam},'rot'))
            tw = [1 2];
        elseif ~isempty(strfind(mapNames{lam},'Rot'))
            tw = [1 2];
        else
            tw = 2;
        end
        
        % I usually name things 22 when they should be 22.5 so fix here
        switch tempLambda
            case '11'
                tempLambda = '11.25';
            case '22'
                tempLambda = '22.5';
        end
        
        lambda(lam) = str2double(tempLambda);
        
        numFlies(lam) = size(powerMapInd{lam},2);
        
        numTotalFlies(lam) = varargin{lam}.analysis{1}.numTotalFlies;
    end
    
    
    switch size(powerMap,1)
        case 5
            tf = [0.25 1 4 16 64]';
        case 15
            tf = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32]';
        case 17
            tf = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32 48 64]';
        otherwise
            error('TF not defined');
    end
    
    trimmedMap.powerMap = powerMap;
    trimmedMap.powerMapSem = powerMapSem;
    trimmedMap.powerMapInd = powerMapInd;
    trimmedMap.mapNames = mapNames;
    trimmedMap.lambda = lambda;
    trimmedMap.tf = tf;
    trimmedMap.tw = tw;
    trimmedMap.numFlies = numFlies;
    trimmedMap.numTotalFlies = numTotalFlies;
    trimmedMap.plotFigs = varargin{1}.analysis{1}.plotFigs;
end