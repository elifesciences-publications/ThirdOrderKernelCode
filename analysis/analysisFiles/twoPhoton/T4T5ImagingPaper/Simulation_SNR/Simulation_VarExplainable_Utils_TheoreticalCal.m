function varExp = Simulation_VarExplainable_Utils_TheoreticalCal(NSR,nSeg,mode)
% varExp = Simulation_VarExplainable_Utils_TheoreticalCal(NSR,nSeg,'respRespNoiseless')
switch mode
    case 'respRespNoiseless'
        varExp = 1./sqrt(1 + NSR.^2/nSeg);
    case 'respResp'
        varExp = 1./(sqrt(1 + NSR.^2) * sqrt(1 + NSR.^2/nSeg));
end
end