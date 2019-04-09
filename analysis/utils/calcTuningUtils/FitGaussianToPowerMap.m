function [planeAngle,rmse] = FitGaussianToPowerMap(sfMeshLog,tfMeshLog,bootedPowerMaps,bootedPowerMapsSem,angle)
    if nargin < 5
        angle = [];
    end

    numBoot = size(bootedPowerMaps,3);
    planeAngle = zeros(numBoot,1);
    rmse = zeros(numBoot,1);
    
    
    
    parfor bb = 1:numBoot
        % fitresult is [amplitude xStd yStd xOffset yOffset zOffset angle]
        [fitResult, zfit, fiterr, zerr, resnorm, rr] = fmgaussfit(sfMeshLog,flipud(tfMeshLog),flipud(bootedPowerMaps(:,:,bb)),angle);
        
        if isempty(angle)
            planeAngle(bb) = mod(fitResult(7),90)*pi/180*4;
        else
            planeAngle(bb) = 0;
        end
        
        gausFit = gaussian2D(fitResult,{sfMeshLog flipud(tfMeshLog)},angle);
        
        rmse(bb) = sqrt(mean(mean((gausFit - flipud(bootedPowerMaps(:,:,bb))).^2)));
    end
end