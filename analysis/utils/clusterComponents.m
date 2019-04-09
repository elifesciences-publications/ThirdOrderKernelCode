function [ clusterMaps, clusterTraces ] = clusterComponents( components, movie, nClusters, varargin )
% Clusters the vectors (components) corresponding to the data set (movie)
% into a smaller number (nClusters) of related components. Method of
% clustering specified by type:
%   CoM: spatial center of mass of components
%   traces: similarity of time traces (in R^nFrames)

    % shared params
    type = 'CoM';
    seeClusters = 1;
    trunc = 1;
    scaleThresh = .2;
    binarizeMaps = 1;
    movieDims = size(movie);
    nFrames = movieDims(3);
    movieDims = movieDims(1:2);
    nComponents = size(components,3);
    
    % vararararararargin
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    % vectorize movie frames for projection into traces
    for q = 1:nFrames
        thisFrame = movie(:,:,q);
        movMatrix(:,q) = thisFrame(:);
    end
    
    if trunc
        % truncate components and scale them nonlinearly to
        % emphasize peak areas, rather than having low-level noise
        % drag the CoM.
        components_scale = (components .* ( components > scaleThresh )).^4;
    else
        components_scale = components;
    end 
            
    switch type
        case 'CoM'           
            CoM = centerOfMass(components_scale);
            [ clusterIDs clusterMeans ] = kmeans(CoM',nClusters);
        case 'traces'
            % vectorize components
            for q = 1:nComponents
                thisVector = components_scale(:,:,q);
                compVectors(:,q) = thisVector(:);
            end
            % compute time traces
            traces = movMatrix'*compVectors;
            % cluster time traces
            [ clusterIDs clusterMeans ] = kmeans(traces',nClusters);                                      
    end
    
    % get component clusters
    clusterMaps = zeros([ movieDims,nClusters ]);
    for q = 1:nComponents
        clusterMaps(:,:,clusterIDs(q)) = clusterMaps(:,:,clusterIDs(q)) + ...
            components_scale(:,:,q);
    end   
    if binarizeMaps
        clusterMaps = ( clusterMaps > 0 );
    end
    
    % get cluster traces
    for q = 1:nClusters
        thisCluster = clusterMaps(:,:,q);
        clusterTraces(:,q) = movMatrix'*thisCluster(:);
    end
    
    % visualize
    if seeClusters
        seqInd = 0;
        for q = 1:3:nClusters
            seeClusters = zeros([movieDims,3]);
            seqInd = seqInd + 1;
            for r = 1:3
                if  q+r-1 <= nClusters
                    binarizeThisCluster = (clusterMaps(:,:,q+r-1) > 0);
                    seeClusters(:,:,r) = binarizeThisCluster;
                end
            end
            figure; image(seeClusters); 
            thisTitle = sprintf('Clusters %i to %i',q,min(q+2,nClusters));
            title(thisTitle);
        end  

        for q = 1:nClusters
            modNum = 4;
            z = mod(q-1,modNum);
            if z == 0
                figure;
            end
            subplot(modNum,2,2*z+1); 
            mapTitle = sprintf('Cluster %i',q);
            traceTitle = sprintf('Trace %i',q);
            imagesc((clusterMaps(:,:,q)>0)); colormap(parula); title(mapTitle);
            subplot(modNum,2,2*(z+1)); plot(clusterTraces(:,q)); title(traceTitle);
        end
    end  
end

