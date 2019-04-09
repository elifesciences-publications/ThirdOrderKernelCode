function WriteXtPlot(bitMap,Q)
    % print out the bitmap values for each frame

    for ii = 1:Q.stims.currParam.framesPerUp
        fprintf(Q.handles.xtPlot,'%.3f,%d,',[Q.timing.flipt-Q.timing.t0+(ii-1)/(Q.stims.currParam.framesPerUp*60),Q.timing.framenumber]);
        fprintf(Q.handles.xtPlot,'%d,',Q.stims.currStimNum); % prints epoch data was gathered at
        fprintf(Q.handles.xtPlot,'%.2f,',bitMap(:,:,ii));
        fprintf(Q.handles.xtPlot,'\n');
    end
end