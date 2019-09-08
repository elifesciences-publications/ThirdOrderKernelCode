function meanSubtractedTraces = MeanSubtractTraces(snipMat)
    meanSubtractedTraces = cell(size(snipMat));

    for ee = 1:size(snipMat,1)
        for ff = 1:size(snipMat,2)
            meanSubtractedTraces{ee,ff} = bsxfun(@minus,snipMat{ee,ff},mean(snipMat{ee,ff}));
        end
    end
end