function planeAngle = CalculatePowermapAngle(powerMapInd,xMesh,yMesh,tw,numBootstrap)

    %% bootstrap flies to create different powermaps and measure their angle
    planeCoef = MattBootstrap(@(varsToResample)FitPlaneToPowermap(xMesh,yMesh,varsToResample),numBootstrap,powerMapIndFit);
        
    %% calculate average plane angle from plane Coef
    planeAngle = atan2(planeCoef(3,:),planeCoef(2,:))';

    planeAngle = planeAngle(~isnan(planeAngle));
end