function covMatrix = CovEstimation_SecondOrderKernel_Utils_CovFunToCovMat(covFunction,maxTau)

nEle = maxTau^2;
% treat each points in second order kernel as a elements. Each elements has
% its own position in a second order kernel.
[subI,subJ] = ind2sub([maxTau,maxTau],1:nEle);
subI  = subI'; subJ = subJ';


% only elements in the same diagonal line will correlate with each other. 
% within same diagonal line, the correlation between two elements depends on the two elements' distance in time 

% the covariance matrix is set to zeros by default.
covMatrix = zeros(nEle,nEle);
 
 % go through different diagonals
 diffIJ = subI - subJ; % 
for dd = -(maxTau - 1):1:maxTau - 1
    % oject here must be in the same diagnal line. dd
    eleInTheSameDiag = find(diffIJ == dd);
    % how many elements are in this diagnol line.?
    nEleThisDiag = length(eleInTheSameDiag);
    % compute the distance in time for all these elements. 
    % if there are more than 1 elements being selected, the pairwise
    % distance forms a matrix.
    %     dtMat = zeros(nEleThisDiag,nEleThisDiag);
    subIInTheSameDiag = subI(eleInTheSameDiag); % what is the x subindexes for the selected elements?
%     subJInTheSameDiag = subJ(eleInTheSameDiag); % should be used to double check. 
    % use subI to calculate this should be the same
    [meshx,meshy] = ndgrid(subIInTheSameDiag,subIInTheSameDiag);
    dtMat = meshy - meshx; % distance between two elements.
    
    % check whether there are distance 0, 1, ..., maxTau in the distrance
    % matrix, and 
    for dt = 1:1:nEleThisDiag
        [xx,yy] = ind2sub([nEleThisDiag,nEleThisDiag],find(abs(dtMat) == dt - 1));
        %% element mm and element nn has distance dt - 1 in them.
        mm = eleInTheSameDiag(xx); nn = eleInTheSameDiag(yy);
        covMatrix(sub2ind([nEle,nEle],mm,nn)) = covFunction(dt);
    end
    
end

end