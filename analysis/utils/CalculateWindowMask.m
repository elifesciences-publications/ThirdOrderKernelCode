function movieMask = CalculateWindowMask(movieSize, alignmentData, zoomLevel, plotMask, linescan, percMotionThresh)
% We are calculating the motion window without regard to frames that are
% gonna get kicked out anyway because of motion

if nargin<4
    plotMask = true;
end


if movieSize(1) > 1
    motionRemovedAlignmentData = RemoveMotionArtifacts(alignmentData(:, [1 2]), alignmentData, zoomLevel, movieSize, linescan, percMotionThresh);
    
    movieMask = false(movieSize(1), movieSize(2));
    
    % If there's too much motion in the movie this'll turn out empty, at
    % which point we didn't want a movie mask anyway--I think it ends up
    % being a redundant way of getting rid of data when there's >5% motion
    if ~isempty(motionRemovedAlignmentData)
        xOffsetPos = max(motionRemovedAlignmentData(:, 1));
        xOffsetNeg =  min(motionRemovedAlignmentData(:, 1));
        yOffsetPos = max(motionRemovedAlignmentData(:, 2));
        yOffsetNeg =  min(motionRemovedAlignmentData(:, 2));
        
        cutoffBorderX = ceil(max(abs([xOffsetPos xOffsetNeg])));
        cutoffBorderY = ceil(max(abs([yOffsetPos yOffsetNeg])));
        
        movieMask(cutoffBorderY:end-cutoffBorderY+1, cutoffBorderX:end-cutoffBorderX+1, :) = 1;
    end
else %linescan regime
    motionRemovedAlignmentData = RemoveMotionArtifacts(alignmentData, alignmentData, zoomLevel, movieSize, true, percMotionThresh);
    
    movieMask = false(movieSize(1), movieSize(2));

    
    xOffsetPos = nanmedian(motionRemovedAlignmentData(motionRemovedAlignmentData(:, 1)>0, 1));
    xOffsetNeg = nanmedian(motionRemovedAlignmentData(motionRemovedAlignmentData(:, 1)<0, 1));
    cutoffBorderX = ceil(max(abs([xOffsetPos xOffsetNeg])));
    
    movieMask(:, cutoffBorderX:end-cutoffBorderX+1, :) = 1;
end

if plotMask
    MakeFigure;
    if movieSize(1) > 1
        subpltNums = {{3 1 1} {3 1 2}};
    else
        subpltNums = {{2 1 1} {2 1 2}};
    end
    subplot(subpltNums{1}{:});
    imagesc(movieMask);axis tight;
    if movieSize(1)>1
        axis equal;
    end
    subplot(subpltNums{2}{:});
    plot(alignmentData(:, 1));hold on;
    if isempty(motionRemovedAlignmentData)
        motionRemovedAlignmentData = nan(size(alignmentData,1), 2);
    end
    plot(find(isnan(motionRemovedAlignmentData(:, 1))), alignmentData(isnan(motionRemovedAlignmentData(:, 1)), 1), '*' );
    title('x alignment');
    
    if movieSize(1) > 1
        subplot(3, 1, 3);
        plot(alignmentData(:, 2));hold on;
        plot(find(isnan(motionRemovedAlignmentData(:, 2))), alignmentData(isnan(motionRemovedAlignmentData(:, 2)), 2), '*' );
        title('y alignment');
    end
    
end