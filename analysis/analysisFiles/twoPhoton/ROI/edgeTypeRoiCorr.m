function ROI = edgeTypeRoiCorr( Z )
% Attempt to segment regions of the image by edge selectivity. This assumes
% that all the edge types have been presented (variable edgeTypes). Note
% that this script requires imgFrame!

roiMinPixNumber = 1;
% there would be several threshold.
% use a set threshold can be very dangerous, and the quality of the data
% set could be better....

% when the data is so good, how do you separate them??
% group them by the correlation beweent them themselves?
corrThreshEdge = 0.25;
corrThreshSquare = 0.15;
corrThreshExclude = 0.1; % the threshold here might be too high when the data is noisy. 0.1 might be too easy to achieve and it is easy for unreponsive data to show up here. 
% although, it is really really hard to eliminate double responsive area
% here... you might get a lot double selective signal.... but worth
% trying to eliminate it...
squareCounts = 0;
% corrThresh = 0.25;
loadFlexibleInputs(Z);

%%  Get indices associated with different edge presentations.

edgeTypes = {'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge','Square Left','Square Right','Square Up','Square Down'};
nEdges = length(edgeTypes);
%% Select background
bkgdMask = roiUtils_dimConnectedBg( Z );
% Update the windowMask so that background regions are excluded from
% all future selection.
Z.grab.windowMask = Z.grab.windowMask .* ~bkgdMask;

%% compute the inds of those epoches.
controlEpochInds = cell(nEdges,1);
inds = cell(nEdges,2);
indsCat = cell(nEdges,1);
indsAll = [];
for qq = 1:nEdges
    % Grabbing the frames in which the edge types occurred
    controlEpochInds{qq} = getEpochInds(Z, edgeTypes{qq});
    inds{qq,2} = [];
    indsCat{qq} = [];
    for r = 1:length(controlEpochInds{qq})
        % indscat contains all the indexes for those frames in linear
        % form, as opposed to separated into presentations as in
        % controlEpochInds
        inds{qq,r} = controlEpochInds{qq}{r};
    end
    if length(inds{qq,1}) > length(inds{qq,2})
        inds{qq,1} = inds{qq,1}(1:length(inds{qq,2}));
    else
        inds{qq,2} = inds{qq,2}(1:length(inds{qq,1}));
    end
    indsCat{qq} = cat(1,inds{qq,1},inds{qq,2});
    indsAll = cat(1,indsAll, indsCat{qq});
end

%% compute the quality of one pixel using correlation between two epoches.
ccImg = zeros(imgSize(1),imgSize(2),nEdges);
for m = 1:1:imgSize(1)
    for n = 1:1:imgSize(2)
        for qq = 1:1:nEdges
            a1 = squeeze(Z.grab.imgFrames(m,n,inds{qq,1}));
            a2 = squeeze(Z.grab.imgFrames(m,n,inds{qq,2}));
            ccImg(m,n,qq) = corr(a1,a2);
        end
    end
end

%% all the possible logic to select a roi using this correlation method.

ccImgEdge = ccImg(:,:,1:4);
ccImgSquare = ccImg(:,:,5:8);
ccImgEdgeB = ccImgEdge > corrThreshEdge;
ccImgSquareB = ccImgSquare > corrThreshSquare;
ccImgEdgeBExc = ccImgEdge > corrThreshExclude;
ccImgExc = sum(ccImgEdgeBExc,3);
ccImgExc = ccImgExc > 1;
%% 

masks = [];
% squareCounts = 1;
% group the data by the correlation, not by the function.... find the
% correlation between pixels and group them together... not only by the
% connectivity....
for qq = 1:1:4
    % find area that is large first, they are likely to be the same cell?
    % at least, from the data, they are likely to be the same roi, because
    % the raw traces looks really similar to each other...
    roiMasksEdgeType = MyBWConncomp(ccImgEdgeB(:,:,qq),roiMinPixNum);
    % whether consider square wave? only the one which has large response
    % on square wave will be included.
       if squareCounts 
        if qq == 1 || qq == 2
            % left sqaure for left dark and left bright
            BinarySquare = ccImgSquareB(:,:,1);
        else
            % right square for right dark and right bright
            BinarySquare = ccImgSquareB(:,:,2);
        end

        % exclude those points if the square response is not large enough.
        nRoi = size(roiMasksEdgeType,3);
        for rr = 1:1:nRoi
            roiMasksEdgeType(:,:,rr) = roiMasksEdgeType(:,:,rr) &  BinarySquare; 
        end
       end
   
    masks = cat(3,masks,roiMasksEdgeType);
end
quickViewRois(masks);

sumMasks = sum(masks, 3);
masks(repmat(sumMasks>1, [1, 1, size(masks,3)])) = false;

% the function to check the qualality is 
% plotTraceBeforeDff(masks,qq,Z,inds)


% after the thing, decide whether to keep this roi,
% first, is that pixel double selective?
% second, is that pixel in the window?
% third, is that roi large enough ?
nRoi = size(masks,3);
roiMasks = [];
for rr = 1:1:nRoi
%     %
      % although, it would harm some data, it might be worth the loss??
%     masks(:,:,rr) = masks(:,:,rr)& ~ccImgExc; with this term, it is a
%     total failure... the roi looks terrible, not direction selective at
%     all....
    masks(:,:,rr) = masks(:,:,rr) & Z.grab.windowMask;    
    nPixel = sum(sum( masks(:,:,rr)));
    if nPixel > roiMinPixNum
        roiMasks = cat(3,roiMasks, masks(:,:,rr));
    end
end

% Split by watershed
%  if splitByWatershed
if ~isempty( roiMasks )
    fgThreshForWatershed = .75;
        watersheds = roiUtils_watershedMovieAvg( Z, fgThreshForWatershed );
        splitMasks = [];
        splitTypeFlag = [];
        for q = 1:size(roiMasks,3)
            thisShedSet = roiMasks(:,:,q) .* watersheds;
            uniqueVals = unique(thisShedSet(:));
            uniqueVals = uniqueVals(uniqueVals ~= 0);
            for r = uniqueVals'
                thisSplitMask = thisShedSet == r;
                splitMasks = cat(3,splitMasks,thisSplitMask);
            end
%             splitTypeFlag = cat(1,splitTypeFlag,repmat(typeFlag(q),[ length(uniqueVals) 1 ]));
        end
        roiMasks = splitMasks;
%         typeFlag = splitTypeFlag;
%     end
end
%%
roiMasks = cat(3,roiMasks,bkgdMask);
quickViewRois( roiMasks );

%% Save everything
ROI.roiMasks = roiMasks;

% %%
% % % 
% MakeFigure;
% for qq = 1:1:4
%     subplot(2,2,qq);
%     tempC = ccImgEdge(:,:,qq);
%     histCC = histogram(tempC(:));
% 
%   imagesc(ccImgEdgeB(:,:,qq));
%     imagesc(ccImgEdge(:,:,qq));
%     set(gca,'CLim',[0.25,0.7])
% end
% % % MakeFigure;
% % for qq = 1:1:4
% %     subplot(2,2,qq);
% % %     tempC = ccImgSquare(:,:,qq);
% % %     histCC = histogram(tempC(:));
% %     imagesc(ccImgSquare(:,:,qq));
% % %     set(gca,'CLim',[0.1,0.3])
% % end
% MakeFigure; % take a look at the expression...
% meanImg = mean(Z.grab.imgFrames,3);
% meanImgShow = meanImg/max(meanImg(:));
% imagesc(meanImgShow);
% hold on 
% h = imagesc(roiMasks(:,:,7));
% alpha(h,0.3)
end

