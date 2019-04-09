function [ ROI ] = spatialCovariance( ROI, movie )
% Calculates the correlation between nearby pixels for each watershed, each
% cluster, and each region of interest

    nSheds = length(ROI.shedIDs);
    nClusters = max(ROI.shedIDs);
    nPix = size(movie,1) * size(movie,2);
    nFrames = size(ROI.shedIntensities,1);
    nBins = 30;
    
    %% covariance of watershed regions versus center of mass distance
    
    % calculate center of mass of each watershed region
    ROI.shedCOM = centerOfMass(ROI.shedMaps,0,0);
    
    COMdistance = zeros(nSheds);
    for q = 2:nSheds
        for r = 1:q
            COMdistance(q,r) = norm(ROI.shedCOM(:,q) - ROI.shedCOM(:,r));
        end
    end
    COMdistance = COMdistance + COMdistance';
    watershedTracesSphere = spherize(ROI.shedIntensities);
    watershedCov = watershedTracesSphere'*watershedTracesSphere;
    
    % how are they functions of each other?
    COMdistance = COMdistance(:);
    watershedCov = watershedCov(:);
    
    % compute means
    [ distMeans, distAxis, distSD, distN ] = meanBins( COMdistance, watershedCov, nBins );
    distSEM = distSD ./ sqrt(distN);
    
    % plot
    figure; plot(distAxis,distMeans,'k');
    hold all; plot(distAxis,distMeans+distSEM,':k'); 
    plot(distAxis,distMeans-distSEM,':k');
    title('Watershed covariance versus COM distance');
    xlabel('COM distance'); ylabel('R');
    
    %% watershed covariance broken up by cluster
    
    figure; suptitle('Within-cluster covariance (R)');
    nRows = ceil(nClusters / 3);
    for q = 1:nClusters
        nPix = sum(sum((ROI.clusterMaps(:,:,q) > 0)));
        internalInds = double(ROI.shedIDs == q);
        internalInds = internalInds*internalInds';
        internalInds = find(internalInds(:));
        cluster.COMdistance{q} = COMdistance(internalInds);
        cluster.watershedCov{q} = watershedCov(internalInds);
        [ cluster.distMeans{q}, cluster.distAxis{q}, cluster.distSD{q}, cluster.distN{q} ] = ...
            meanBins( cluster.COMdistance{q}, cluster.watershedCov{q}, nBins );
        cluster.distSEM{q} = cluster.distSD{q} ./ sqrt(cluster.distN{q});
        subplot(nRows,3,q);
        plot(cluster.distAxis{q},cluster.distMeans{q},'k');
        hold all; plot(cluster.distAxis{q},cluster.distMeans{q}+cluster.distSEM{q},':k'); 
        plot(cluster.distAxis{q},cluster.distMeans{q}-cluster.distSEM{q},':k');
        thisTitle = sprintf('Cluster %i, %i pix',q,nPix); title(thisTitle);
    end   

    %% Cluster covariance
    
    clusterTracesSphere = spherize(ROI.clusterIntensities);
    clusterTracesCov = clusterTracesSphere'*clusterTracesSphere;
    clusterTracesCov = clusterTracesCov .* (ones(nClusters) - eye(nClusters));
    
    % plot
    colormap_gen;
    figure;
    suptitle('Cluster Covariance (R)');
    majorIndices = [];
    for q = 1:nClusters
        subplot(nClusters+1,nClusters+1,q+1);
        imagesc(ROI.clusterMaps(:,:,q)); 
        set(gca,'XTickLabel','','YTickLAbel','','Clim',[-1e-7 1e-7]);
        subplot(nClusters+1,nClusters+1,q*(nClusters+1)+1)
        imagesc(-ROI.clusterMaps(:,:,q));
        set(gca,'XTickLabel','','YTickLAbel','','Clim',[-1e-7 1e-7]);
        majorIndices = cat(2,majorIndices,[(q)*(nClusters+1)+2:(q+1)*(nClusters+1)]);
    end
    subplot(nClusters+1,nClusters+1,majorIndices);
    imagesc(clusterTracesCov);
    maxAbs = max(abs(clusterTracesCov(:)));
    set(gca,'Clim',[-maxAbs maxAbs]);
    colormap(mymap);

end

