function [powerMap,powerMapSem] = GetAveragePowerMap(powerMapInd)
    powerMap = zeros(size(powerMapInd{1},1),length(powerMapInd));
    powerMapSem = zeros(size(powerMapInd{1},1),length(powerMapInd));

    for lam = 1:length(powerMapInd);
        powerMap(:,lam) = mean(powerMapInd{lam},2);
        powerMapSem(:,lam) = Sem(powerMapInd{lam},2);
    end
end