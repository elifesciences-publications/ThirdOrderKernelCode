function [ CoM ] = centerOfMass( inImgs, roundCoord, seeAll )
% Computes the center of mass of an array of input images. Returns the x
% and y coordinates of the center in terms of original image pixels, with
% the origin at the top left. 
%   Inputs:
%       inImgs: array of input images. First two dimensions the height and
%           width of original image, third dimension over different images.
%       round: binary choise to round to nearest pixel or return fractional
%           output.
%   Outputs:
%       CoM: centers of mass of each image, I in first row, J in second
%           row, columns over images (so 2 x N). 

    if nargin < 2
        roundCoord = 1;
    end

    if nargin < 3
        seeAll = 0;
    end

    ht = size(inImgs,1); wd = size(inImgs,2);
    N = size(inImgs,3);
    iLin = [1:ht]; jLin = [1:wd];
    [jMesh iMesh] = meshgrid(jLin,iLin);

    for q = 1:N
        thisImg = abs(inImgs(:,:,q));
        M = sum(thisImg(:));
        iWeighted = jMesh(:)'*thisImg(:) / M;
        jWeighted = iMesh(:)'*thisImg(:) / M;
        if roundCoord
            jWeighted = round(jWeighted);
            iWeighted = round(iWeighted);
        end
        if seeAll
            figure;
            imagesc(thisImg); hold all;
            scatter(iWeighted,jWeighted,200,'filled','r');
            thisTitle = sprintf('I: %0.5g, J: %0.5g',iWeighted,jWeighted);
            title(thisTitle);
            hold off;
        end
        CoM(:,q) = [iWeighted; jWeighted];
    end

end

