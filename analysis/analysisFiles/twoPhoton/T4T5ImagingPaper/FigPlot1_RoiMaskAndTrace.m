function FigPlot1_RoiMaskAndTrace(Z,flyEye)
%% there will be four colors for each different types
% you might have to come up with a better metric to do this...
typeColorRGB = zeros(4,3);
typeColorRGB(1,:) = [1,0,0]; % yellow
typeColorRGB(2,:) = [1,0,1]; % magenta
typeColorRGB(3,:) = [0,0,1]; % green
typeColorRGB(4,:) = [0,1,0]; % cyan

%% get the roiMasks and roiImage from Z.
% in the future, this might be changed. but for now, Z is used...
roiMasks = Z.ROI.roiMasks(:,:,1:end - 1);
roiCenterOfMass = Z.ROI.roiCenterOfMass(1:end-1,:);
movieMean = Z.rawTraces.movieMean;
windowMask = Z.grab.windowMask;
% roiImage will be the place in the windowMasks.
verInd = find(sum(windowMask,2) > 0);
horInd = find(sum(windowMask,1) > 0);

roiImage = movieMean(verInd(1):verInd(end),horInd(1):horInd(end));

nRoi = size(roiMasks,3);
% you need roiType by eye...

%% produce a figure, which has roi and mean image.
[cfRoi,roiInfo] = RoiClassification(Z,flyEye);
roiEdgeType = cfRoi.PEye.edgeType;
roiDirType = cfRoi.PEye.dirType;
roiESI = zeros(nRoi,1);
roiDSI = zeros(nRoi,1);
for rr = 1:1:nRoi
    roiESI(rr) = cfRoi.PEye.ESI(rr,roiEdgeType(rr));
    roiDSI(rr) = cfRoi.PEye.DSI(rr,roiDirType(rr));
end
[roiMasksDisplay,alph] =  FigPlot1_GenerateRoiDisplay(roiMasks, roiImage, roiEdgeType, typeColorRGB, roiESI, roiDSI);


MakeFigure
colormap(gray(256))
imagesc(roiImage);
axis off
hold on
h = imagesc(roiMasksDisplay);
set(h, 'AlphaData', .8*alph);
hold off

%% roiSelection based on cfRoi....
% once you get some roi, select the best 4 of them to do analysis....
coordinate = 'eye';
roiSelectedCorrPeakConsist = RoiSelectionByProbingStimulus(cfRoi,'method','CorrPeakConsistency','classInterested',1);
% roiSelectedCorr = RoiSelectionByProbingStimulus(cfRoi,'method','corrOnly','classInterested',1);
% roiSelectedCorrESI = RoiSelectionByProbingStimulus(cfRoi,'method','corrPeak','classInterested',1);
roiSelectedBySize = RoiSelectionBySize(roiMasks,1);
% roiSelected = roiSelectedBySize & roiSelectedCorrESI;
% roiSelected = roiSelectedBySize & roiSelectedCorr;
% roiSelected = roiSelectedBySize;
roiSelected = roiSelectedCorrPeakConsist;
roiUse = find(roiSelected);

% first, plot the trace for this roi,
nRoiUse = length(roiUse);    
bestRoi = zeros(4,1);
bestRoiESI = zeros(4,1);
% % 
for ii = 1:1:nRoiUse
    rr = roiUse(ii);
    type = cfRoi.PEye.edgeType(rr);
    ESI = cfRoi.PEye.ESI(rr,type);
    if ESI > bestRoiESI(type)
        bestRoi(type) = rr;
        bestRoiESI(type)= ESI;
    end
end
% MakeFigure;
% bestRoi = zeros(4,1);
% bestRoiES = zeros(4,1);
% for tt = 1:1:4
%     % for each type, find the largest
%     roiThisType = cfRoi.PEye.edgeType == tt & roiSelected;
%     roiThisTypeInd = find(roiThisType);
%     [maxESI,maxInd] = max(cfRoi.PEye.ESI(roiThisType,tt));
% %     subplot(2,2,tt)
% %     histogram(cfRoi.PEye.ESI(roiThisType,tt))
%     bestRoi(tt) = roiThisTypeInd(maxInd);
%     bestRoiES(tt) = maxESI;
% end

roiTypeExistFlag = zeros(4,1);
for tt = 1:1:4
    rr = bestRoi(tt); % there might be zero. If there is zero, give out an error?
    if rr == 0       
        roiTypeExistFlag(tt) = 0;
        disp(['no good roi for this edge type (', num2str(tt), ') in this fly. bad luck.']);
    else
        roiTypeExistFlag(tt) = 1;
    end
end

%% plot boundary
% 
% MakeFigure;
% h = imagesc(roiMasksDisplay);
hold on
for tt = 1:1:4    
    rr = bestRoi(tt); % there might be zero. If there is zero, give out an error?
    if roiTypeExistFlag(tt)
      
        roiBoundaries = bwboundaries(roiMasks(:,:,rr),8,'noholes');
       
        type = cfRoi.PEye.edgeType(rr);
        plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',5,'color',typeColorRGB(type,:))
        
        % write a number on the roi.
        centerOfMass = roiCenterOfMass(rr,:);
        text(centerOfMass (2), centerOfMass (1), num2str(rr), 'HorizontalAlignment', 'center', 'Color', [1,1,1]);
    end
    
end
hold off
ConfAxis;
%% plot trace
MakeFigure;
for tt = 1:1:4
    if roiTypeExistFlag(tt)
    rr = bestRoi(tt);
    allTrace = roiInfo.eye.indiVidualTrace{rr};
    corrValue = cfRoi.CCEye.value(rr,1:4);
    name = cfRoi.PEye.edgeName(rr); 
    subplot(2,2,tt)
    % it needs Xlabel and Y Label As well.
    PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','titleStr',name,'colorBank',typeColorRGB);
    ConfAxis;  
%     PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','legendLabel','corr','legendValue',corrValue,'titleStr',name,'colorBank',typeColorRGB);
    end
end

MakeFigure;
% distribution of DSI and ESI.
% calculate individual DSI and ESI.
DSI = zeros(nRoi,1);
ESI = zeros(nRoi,1);
for rr = 1:1:nRoi
    dirType = cfRoi.PEye.dirType(rr);
    DSI(rr) = cfRoi.PEye.DSI(rr,dirType);
    
    edgeType = cfRoi.PEye.edgeType(rr);
    ESI(rr) = cfRoi.PEye.ESI(rr,edgeType);
end
scatter(DSI,ESI,'r+','lineWidth',10);
axis([0,1,0,1])
xlabel('DSI');
ylabel('ESI');
ConfAxis;
end