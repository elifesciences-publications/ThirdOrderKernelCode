function [ output_args ] = traceCovariance( ROI )
% View covariance matrix of all watershed traces. 

    nSheds = length(ROI.shedIDs);
    nClusters = max(ROI.shedIDs);
    
    % put shed traces in order of cluster
    orderedShedMat = zeros(size(ROI.shedIntensities));
    seqInd = 0;
    for q = 1:nClusters
        shedIDsThisCluster = find(ROI.shedIDs == q);
        nShedsThisCluster = length(shedIDsThisCluster);
        for r = 1:nShedsThisCluster
            seqInd = seqInd + 1;
            thisVect = ROI.shedIntensities(:,shedIDsThisCluster(r));
            thisVect = thisVect - mean(thisVect);
            thisVect = thisVect / norm(thisVect);
            orderedShedMat(:,seqInd) = thisVect;
        end
    end

    % create covariance matrix, remove diagonal for scaling
    orderedShedCov = orderedShedMat' * orderedShedMat;
    orderedShedCov = (ones(nSheds) - eye(nSheds)) .* orderedShedCov;
    
    % view
    figure; colormap_gen;
    imagesc(orderedShedCov);
    colormap(mymap);
    set(gca,'Clim',[-1 1]);
    
    figure; 
    imagesc(orderedShedMat');
    colormap(mymap);
    absMax = max(abs(orderedShedMat(:)));
    set(gca,'Clim',[-absMax absMax]);

end

