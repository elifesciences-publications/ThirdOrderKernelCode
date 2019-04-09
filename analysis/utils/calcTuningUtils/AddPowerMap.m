function AddPowerMap(tw,varargin)
    numMaps = length(varargin);
    
    pm = num2cell(sign(tw));
    tw = num2cell(abs(tw));
    
    
    
    powerMap = cell(numMaps,1);
    powerMapIntTf = cell(numMaps,1);
    
    sfLog = cell(numMaps,1);
    tfLog = cell(numMaps,1);
    velLog = cell(numMaps,1);
    
    numLam = cell(numMaps,1);
    numTf = cell(numMaps,1);
    numVel = cell(numMaps,1);
    
    sfMeshLog = cell(numMaps,1);
    tfMeshLog = cell(numMaps,1);
    velMeshLog = cell(numMaps,1);
    
    for mm = 1:numMaps
        %% read in varargin input
        % but only taking turning or walkign depending on tw

        powerMap{mm} = varargin{mm}.powerMap(:,:,tw{mm});

        if tw{mm} == 2
            powerMap{mm} = 1-powerMap{mm};
        end
        
        lambda = varargin{mm}.lambda;

        tf = varargin{mm}.tf;
        
        %% define the sf, tf, log, and velocity values the data was measured at
        sf = 1./lambda;
        sfLog{mm} = log(sf);
        numLam{mm} = size(lambda,2);
        
        tfLog{mm} = log(tf);
        numTf{mm} = size(tf,1);
        
        velMesh = tf*lambda;
        vel = [flipud(velMesh(1,:)'); velMesh(:,1)];
        vel(numLam{mm}) = [];
        numVel{mm} = length(vel);
        velLog{mm} = log(vel);
        
        sfMeshLog{mm} = repmat(sfLog{mm},[numTf{mm} 1]);
        tfMeshLog{mm} = repmat(tfLog{mm},[1 numLam{mm}]);
        velMeshLog{mm} = log(velMesh);
    end
    
    combMap = zeros(size(powerMap{1}));
    
    for mm = 1:numMaps
        combMap = combMap + pm{mm}*powerMap{mm};
    end
    
    combMap = combMap/numMaps;
    
    [~,mapLimitsCentered] = GetMapLimits(powerMap,tw,[],[0 0]);

    %% linearly interpolate the powermaps so they are plotted properly
    for mm = 1:numMaps
        powerMapIntTf{mm} = InterpolatePowerMap(powerMap{mm},sfMeshLog{mm},tfMeshLog{mm},numLam{mm},numTf{mm});
    end
    
    powerMapIntTfComb = InterpolatePowerMap(combMap,sfMeshLog{1},tfMeshLog{1},numLam{1},numTf{1});

    
    %% plotting
    
    numContours = 20;
    
    for mm = 1:numMaps
        MakeFigure;
        PlotPowerMap(pm{mm}*powerMapIntTf{mm},mapLimitsCentered(:,tw{mm}),numContours,sfLog{mm},tfLog{mm});
    end
    
    MakeFigure;
    PlotPowerMap(powerMapIntTfComb,mapLimitsCentered(:,tw{mm}),numContours,sfLog{mm},tfLog{mm});
end