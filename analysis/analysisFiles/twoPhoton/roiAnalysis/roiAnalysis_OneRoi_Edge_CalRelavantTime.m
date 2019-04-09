function ind = roiAnalysis_OneRoi_Edge_CalRelavantTime(respLinear)
respDiff = zeros(size(respLinear,1),2);
respDiff(:,1) = respLinear(:,1) - respLinear(:,2);
respDiff(:,2) = respLinear(:,3) - respLinear(:,4);
tol = 1e-5;
indStatic = abs(respDiff(:,1)) < tol;
ind = ~indStatic;
end