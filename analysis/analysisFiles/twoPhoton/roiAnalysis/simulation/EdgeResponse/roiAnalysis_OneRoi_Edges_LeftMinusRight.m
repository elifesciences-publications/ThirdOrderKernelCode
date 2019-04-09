function respDiff = roiAnalysis_OneRoi_Edges_LeftMinusRight(respIn)
respDiff = zeros(size(respIn));
% light:left - right;;
respDiff(:,1) = respIn(:,1) - respIn(:,2);
% light: right - left;
respDiff(:,2) = - respDiff(:,1);
% dark : left - right
respDiff(:,3) = respIn(:,3) - respIn(:,4);
% dark: right - left.
respDiff(:,4) = - respDiff(:,3);

end