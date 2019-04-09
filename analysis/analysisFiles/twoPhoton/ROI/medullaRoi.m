function ROI = medullaRoi( Z )
% Can we get direction selective regions in the medulla?

    activityType = 'mean';
    percentileLevel = .99;
    loadFlexibleInputs(Z);
    
    %%  Get indices associated with different edge presentations.
    epochs = { 'Square Left', 'Square Right', 'Square Up', 'Square Down',...
         'Left Light Edge','Right Light Edge','Left Dark Edge' ...
        'Right Dark Edge' };   
    % List in pairs with opposite direction-selectivity directly following
    
    % I'm not sure whether edges of square waves will give better
    % separation so trying both

    %% Activity image
    
    percentileImg = zeros(imgSize(1),imgSize(2),length(epochs));
    percentileDiff = zeros(imgSize(1),imgSize(2),length(epochs)/2); 
    for q = 1:length(epochs)
        inds{q} = getEpochInds(Z, epochs{q});
        indsCat{q} = [];
        for r = 1:length(inds{q})
            indsCat{q} = cat(1,indsCat{q},inds{q}{r});
        end
        meanImg(:,:,q) = mean(Z.grab.imgFrames(:,:,indsCat{q}),3);
        for m = 1:imgSize(1)
            for n = 1:imgSize(2)
                percentileImg(m,n,q) = activityFun(Z.grab.imgFrames(m,n,indsCat{q}), activityType, percentileLevel);
            end
        end           
    end
    for q = 1:length(epochs)/2
        percentileDiff(:,:,q) = percentileImg(:,:,2*q)-percentileImg(:,:,2*q-1);
        figure; colormap_gen;
        imagesc(percentileDiff(:,:,q));
        diffScale = max(max(abs(percentileDiff(:,:,q))));
        set(gca,'Clim',[-diffScale diffScale]); colormap(mymap); title([epochs{2*q} ' - ' epochs{2*q-1}]);
    end
    MakeFigure;
    
    % average together edge responses (light and dark)
    edgeResp = (percentileDiff(:,:,1) + percentileDiff(:,:,3) + percentileDiff(:,:,4))/3;
    figure;
    imagesc(edgeResp); title('All L - R');
    
    
    allScale = percentileThresh(abs(percentileImg(:)),.98);
    diffScale = percentileThresh(abs(percentileDiff(:)),.98);
    subplot(3,1,1); imagesc(percentileImg(:,:,1));  
    axis equal; axis off; set(gca,'Clim',[-allScale allScale]); colormap(mymap); title(epochs{1});
    subplot(3,1,2); imagesc(percentileImg(:,:,2));  
    axis equal; axis off; set(gca,'Clim',[-allScale allScale]); colormap(mymap); title(epochs{2});
    subplot(3,1,3); imagesc(percentileDiff(:,:));  
    axis equal; axis off; set(gca,'Clim',[-diffScale diffScale]); colormap(mymap); title([epochs{2} ' - ' epochs{1}]);

    ROI = [];


end

function activity = activityFun(data, activityType, percentileLevel )

    switch activityType
        case 'mean'
            activity = mean(data);
        case 'percentile'
            activity = percentileThresh(data,percentileLevel);
    end
    
end

