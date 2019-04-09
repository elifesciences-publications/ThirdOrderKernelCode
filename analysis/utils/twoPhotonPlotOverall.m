function Z = twoPhotonPlotOverall( Z,titleText,  roiColor )
%TWOPHOTONPLOTOVERALL takes in Z and plots the overall traces and the ROIs
%   Detailed explanation goes here

if nargin>3
    tp_plotROIs( Z, roiColor )
else
    tp_plotROIs( Z )
end
title(titleText);


tp_plotROITraces( Z )
title(titleText);