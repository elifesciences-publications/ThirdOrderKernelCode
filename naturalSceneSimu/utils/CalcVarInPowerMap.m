function powerVar = CalcVarInPowerMap(inX,inY,outX,outY,varargin)
    numVar = length(varargin);
    powerMap = zeros(size(varargin{1},1),numVar);
    
    for vv = 1:numVar
        powerMap(:,vv) = mean(varargin{vv},2);
    end
    
    powerMap = griddata(inX,inY,powerMap,outX,outY);
    
    powerVar = sum(nanvar(powerMap,[],2));
end