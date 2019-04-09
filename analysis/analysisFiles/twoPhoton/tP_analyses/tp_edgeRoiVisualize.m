function tp_edgeRoiVisualize( Z )
% Make plots to visualize how edgeTypeRoi was working.

    loadFlexibleInputs(Z);
    MakeFigure;
    
    meanImg = sum(Z.ROI.percentileImg,3);
    scaleDS = Z.eval.direction_selectivity;
    scaleDS = scaleDS / max(abs(scaleDS));
    scaleLeft = scaleDS .* (scaleDS > 0);
    scaleRight = -scaleDS .* (scaleDS < 0);
  
    %% Top Row - Direction Selectivity Considerations
    thisImg = repmat(meanImg/max(meanImg(:)),[1 1 3]);
    whichAssign = [ 2 3; 1 2 ]; 
    for r = 1:size(Z.ROI.roiMasks,3)-1
        for q = 1:2
            assign1 = whichAssign(q,1);
            assign2 = whichAssign(q,2);
            thisImg(:,:,assign1) = thisImg(:,:,assign1) - (Z.ROI.roiMasks(:,:,r) * scaleLeft(r));
            thisImg(:,:,assign2) = thisImg(:,:,assign2) - (Z.ROI.roiMasks(:,:,r) * scaleRight(r));
        end
    end 
    subplot(3,3,1); image(thisImg); axis square; axis off;
    
    
    
        keyboard

end

