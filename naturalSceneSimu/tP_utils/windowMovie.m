function [ windowMask ] = windowMovie( polygonImage, linescan, alignmentData )
% Draw a polygon, discard all movie information outside.
%   Inputs:
%       polygonImage: an image the same size as each inMovie frame on which
%           you will draw the polygon.
%       inMovie: the movie to be windowed.
%   Outputs:
%       outMovie: inMovie, but with all pixels outside the polygon set to
%           0.

    if nargin > 2
        if linescan
            % We're doing medians because maximums cut off most of the
            % image
            xOffsetPos = median(alignmentData(alignmentData(:, 1)>0, 1));
            xOffsetNeg = median(alignmentData(alignmentData(:, 1)<0, 1)); 
            cutoffBorderX = ceil(max(abs([xOffsetPos xOffsetNeg])));
%             cutoffBorderY = ceil(max(abs([yOffsetPos yOffsetNeg])));
            windowMask = zeros(size(polygonImage));
            windowMask(:, cutoffBorderX:end-cutoffBorderX+1, :) = 1;
        else
%                     xOffsetPos = median(alignmentData(alignmentData(:, 1)>0, 1)) +  mad(alignmentData(alignmentData(:, 1)>0, 1));
%                     xOffsetNeg =  median(alignmentData(alignmentData(:, 1)<0, 1)) -  mad(alignmentData(alignmentData(:, 1)<0, 1));
            %         yOffsetPos = median(alignmentData(alignmentData(:, 2)>0, 2)) +  mad(alignmentData(alignmentData(:, 2)>0, 2));
            %         yOffsetNeg =  median(alignmentData(alignmentData(:, 2)<0, 2)) -  mad(alignmentData(alignmentData(:, 2)<0, 2));
            xOffsetPos = max(alignmentData(:, 1));
            xOffsetNeg =  min(alignmentData(:, 1));
            yOffsetPos = max(alignmentData(:, 2));
            yOffsetNeg =  min(alignmentData(:, 2));
            
            cutoffBorderX = ceil(max(abs([xOffsetPos xOffsetNeg])));
            cutoffBorderY = ceil(max(abs([yOffsetPos yOffsetNeg])));
            
            windowMask = zeros(size(polygonImage));
            windowMask(cutoffBorderY:end-cutoffBorderY+1, cutoffBorderX:end-cutoffBorderX+1, :) = 1;
            %         outMovie = inMovie.*windowMaskWhole;
            %         windowMask = windowMaskWhole(:, :, 1);
        end
        
        
    else
        %% Select polygon
        figure; imagesc(polygonImage);
        title(['Cut out alignment border']);
        windowMask = roipoly;
        
    end

end

