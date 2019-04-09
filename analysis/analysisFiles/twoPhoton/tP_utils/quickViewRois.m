function quickViewRois( ROI )

if ~isempty(ROI)
% Input is 127 x 256 x (nRoi + 1) matrix, different ROIs along third 
% dimension, last ROI the background.
  seeAll = zeros(size(ROI,1),size(ROI,2));
    for q = 1:size(ROI,3)-1
        seeAll = seeAll + (mod(q,5)+1)*ROI(:,:,q);
    end
    seeAll = seeAll + ROI(:,:,end)*10;
    figure;
    imagesc(seeAll);
    title('ROIs');
    set(gca,'XTick',[],'YTick',[]);
else
    return
end
    
end

