function powerSEM = calcSemInPowerMap(inX,inY,outX,outY,varargin)
    numVar = length(varargin);
    powerMap = zeros(size(varargin{1},1),numVar);
    
    for vv = 1:numVar
        powerMap(:,vv) = mean(varargin{vv},2);
    end
    
    powerMap = griddata(inX,inY,powerMap,outX,outY);
    
    powerSEM = mean(nanstd(powerMap,[],2))./sqrt(numVar);
end