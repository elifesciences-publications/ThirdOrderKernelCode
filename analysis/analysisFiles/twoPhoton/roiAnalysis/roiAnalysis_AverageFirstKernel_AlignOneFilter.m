function kernelCentered = roiAnalysis_AverageFirstKernel_AlignOneFilter(kernel,center)

kernelLong = repmat(kernel,[1,2]);

if center <= 10
    center = center + 20;
end
range = center - 10:1:center +9;
kernelCentered = kernelLong(:,range);
end