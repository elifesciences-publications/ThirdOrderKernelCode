function plotTracesAndMaps( Z, ID, traceData, overlay, titles )
% Plots ROI maps on top of original image corresponding to a set of traces
% (or kernels, etc.) in traceData.
% 
%   Inputs
%       Z: master variable for two photon analysis
%       ID: ROI IDs corresponding to the traces being plotted.
%       traceData: traces to plot (in columns, ID along rows)
%       titles: optional, titles for left and right plots

    if nargin < 4
        overlay = zeros(size(traceData,1),1);
    end
    
    if nargin < 5
        titles = {'Maps','Traces'};
    end
    
    figure; 
    
    %%  Concatenate masks
    movieMean = Z.rawTraces.movieMean;
    movieMean = movieMean / max(movieMean(:));
    seeChosen = repmat(movieMean,[1 1 3]);
    for q = 1:length(ID)
        layerInd = mod(q,3)+1;
        seeChosen(:,:,layerInd) = seeChosen(:,:,layerInd) + ...
            .3*Z.ROI.roiMasks(:,:,ID(q));
    end

    %% Plot Masks
    subplot(1,2,1);
    seeChosenCut = seeChosen .* (seeChosen > 0) .* (seeChosen <= 1);
    image(seeChosenCut);
    for q = 1:length(ID)
        thisCOM = centerOfMass(Z.ROI.roiMasks(:,:,ID(q)));
        text(thisCOM(1),thisCOM(2),num2str(ID(q)));
    end
    title(titles{1});
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    
    %% Create stagger indices
    staggerHeight = percentileThresh( traceData, .999 );
    staggerInd = [1:1:length(ID)]*staggerHeight; 
    staggerInd = repmat(staggerInd,[size(traceData,1) 1]);
    
    %% Plot Traces
    subplot(1,2,2);
    overlayImage = repmat(overlay',[round((length(ID)+1)*staggerHeight),1]);
    overlayImage = -.1*overlayImage + ones(size(overlayImage));
    overlayMap = cat(3,overlayImage,overlayImage);
    overlayMap = cat(3,overlayMap,overlayImage);
    image(overlayMap);
    axis xy
    hold all;
    plot((traceData + staggerInd));
    for q = 1:length(ID)
        text(5,q*staggerHeight+1,num2str(ID(q)));
    end
    axis xy
    set(gca,'YTick',[]);
    title(titles{2}); 
    
    
end

