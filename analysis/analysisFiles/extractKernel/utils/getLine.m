function [ locVect ] = getLine( maxTau,dispSide,dispVert,visualize )
% Gets lines off-diagonal of a 3D object. Returns as a vector.

if nargin < 4
    visualize = 0;
end

axis = linspace(1,maxTau,maxTau);
[ X1 X2 X3 ] = ndgrid(axis, axis, axis);

seqInd = 0;
for diagInd = 1:maxTau
    if (diagInd + dispSide < maxTau) && (diagInd + dispVert < maxTau) ...
            && (diagInd + dispVert > 0) && (diagInd + dispSide > 0)
        seqInd = seqInd + 1;
        locs3(1,seqInd) = diagInd;
        locs3(2,seqInd) = diagInd + dispSide;
        locs3(3,seqInd) = diagInd + dispVert;
    end
end

% visualize
kernelClone = zeros(maxTau,maxTau,maxTau);
for q = 1:seqInd
    x1 = locs3(1,q);
    x2 = locs3(2,q);
    x3 = locs3(3,q);
    kernelClone(x1,x2,x3) = kernelClone(x1,x2,x3) + 1;
end

if visualize
    for q = 1:maxTau
        visClone(q,q,q) = 10;
    end
    visClone = visClone + kernelClone;
    threeDvisualize_gobs(visClone,0);
end

locVect = kernelClone(:);
end

