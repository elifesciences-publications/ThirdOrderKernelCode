function [powerMap,powerMapSem] = GetSingleFlyPowerMap(powerMapInd)
    powerMap = zeros(size(powerMapInd{1},1),length(powerMapInd));
    powerMapSem = zeros(size(powerMapInd{1},1),length(powerMapInd));

    for lam = 1:length(powerMapInd);
        powerMap(:,lam) = powerMapInd{lam}(:,1);
        powerMapSem(:,lam) = ones(size(powerMapInd{lam}(:,1)));
    end
end