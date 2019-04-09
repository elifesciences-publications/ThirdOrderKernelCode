function Y = tp_clusterKernels( Y )
% Clusters extracted kernels and maps back to their spatial locations. 

    clusterType = 'kmeans';
    normKernels = 0;
    nKernelClusters = 15;
    
    %%%% RRRR
%     if isfield(Y,'params')
%         paramsFields = fieldnames(Y.params);
%         thisField =  Y.params.(paramsFields{ii});
%         for ii = 1:length(paramsFields)
%             assignin('caller', paramsFields{ii}, thisField);
%         end
%     end
    
    allKernels = Y.allKernels;
    kernelStack = [];
    for q = 1:size(allKernels,2)
        for r = 1:size(allKernels,3)
            getKernel = allKernels(:,q,r);
            if normKernels
                getMean = mean(getKernel);
                getKernel = getKernel - getMean;
                getNorm = norm(getKernel);
                getKernel = getKernel / getNorm;
            end
            kernelStack = cat(2,kernelStack,getKernel);
        end
    end 
    
    switch clusterType
        case 'kmeans'
            [ clusterIDs, clusterMeans ] = ...
                    kmeans(kernelStack',nKernelClusters);
    end
%             
% 
%     for q = 1:nKernelClusters
%         figure; plot(clusterMeans(:,q));
%     end
    
    Y.cluster.clusterIDs = clusterIDs;
    Y.cluster.clusterMeans = clusterMeans;
%     for q = 1:size(kernelStack,2)
% %         figure;
%         for r = 1:nKernelClusters
%             nCols = 3;
%             nRows = ceil(nKernelClusters/nCols);
%             subplot(nRows,nCols,r);
%             quickKernelPlot(clusterMeans(r,:));
%         end
%     end
    
    %% Visualize cluster locations
    % Issue with this is that each ROI lives multiple times so can exist in
    % different direction selectivity clusters. Not sure if there's a fix
    % for this, leaving it for now.
    % Actually, in retrospect, this whole analysis is not exactly what it
    % needed here. Want to see spatially which areas correlate most
%     % strongly with which bar pairs. 
%     if withinClusters
%         for q = 1:size(kernelStack,2);
%             figure;
%             clusterImage = zeros(size(mean(Z.ROI.clusterMasks,3)));
%             for r = 1:length(kernelIDsCat)
%                 origID = kernelIDs(kernelIDsCat(r));
%                 clusterImage = clusterImage + clusterIDs(r) * Z.ROI.roiMasks(:,:,origID);
%             end
%             imagesc(clusterImage); colormap(gray);
%         end
%     end
    
end

