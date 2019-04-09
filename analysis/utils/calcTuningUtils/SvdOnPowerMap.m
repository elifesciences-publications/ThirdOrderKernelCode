function [u,s,v,varianceExplained,components] = SvdOnPowerMap(bootedPowerMaps,normType,svdSize)
    if nargin < 2
        normType = 'none';
    end

    
    
    
    % initialize all variables
    % remove nans from powermap
    bootedPowerMaps = bootedPowerMaps(~sum(isnan(bootedPowerMaps(:,:,1)),2),:,:);
    
    % svdSize determines how big the matrix should be that you perform SVD
    % on. Make sure it is not bigger than this by removing elements from
    % the top and bottom
    topTrim = ceil((size(bootedPowerMaps,1) - svdSize)/2);
    bottomTrim = floor((size(bootedPowerMaps,1) - svdSize)/2);
    
%     bootedPowerMaps = bootedPowerMaps((bottomTrim+1):(end-topTrim),:,:);
    
    [numTf,numLam,numBoot] = size(bootedPowerMaps);
    numComponents = min([numTf numLam]);
    u = zeros(numTf,numTf,numBoot);
    s = zeros(numTf,numLam,numBoot);
    v = zeros(numLam,numLam,numBoot);
    varianceExplained = zeros(numComponents,1,numBoot);
    components = zeros(numTf,numLam,numComponents,numBoot);
    
    % decide which normalization to pefform
    switch normType
        case 'none'
            scaledPowerMap = bootedPowerMaps;
            rowMean = 0;
            rowStd = 1;
        case 'mean'
            rowMean = mean(bootedPowerMaps,2);
            scaledPowerMap = bsxfun(@minus,bootedPowerMaps,rowMean);
            rowStd = 1;
        case 'meanAndVariance'
            rowMean = mean(bootedPowerMaps,2);
            centerPowerMap = bsxfun(@minus,bootedPowerMaps,rowMean);
            rowStd = sqrt(sum(centerPowerMap.^2,2));
            scaledPowerMap = bsxfun(@rdivide,centerPowerMap,rowStd);
    end
    
    % perform SVD on each of the booted powermaps
    for bb = 1:numBoot
        % perform SVD
        [u(:,:,bb),s(:,:,bb),v(:,:,bb)] = svd(scaledPowerMap(:,:,bb));

        % extract singular values and convert to percent variance explained
        varianceExplained(:,1,bb) = diag(s(:,:,bb)).^2/sum(diag(s(:,:,bb)).^2);
        
        for ll = 1:numComponents
            components(:,:,ll,bb) = u(:,ll,bb)*v(:,ll,bb)';
        end
    end
    
    % add back in any normalizations performed
    components = bsxfun(@times,components,rowStd);
    components = bsxfun(@plus,components,rowMean);
end