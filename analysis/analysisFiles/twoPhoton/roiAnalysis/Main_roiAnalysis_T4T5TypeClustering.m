function Main_roiAnalysis_T4T5TypeClustering(roiData)
roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData,'filepath');

nfly = length(roiByFly);
edgeType  = cell(nfly,1);
 nearestEdgeType = cell(nfly,1);
for ff = 1:1:nfly
    roiUse = roiData(roiByFly(ff).roiUse);
    
    % get the roiMask.
    % get the center of mass of all rois.
    centerOfMassCell = cellfun(@(roi) MyClustering_Untils_ComputeCenterOfMass(roi.stimInfo.roiMasks),roiUse,'UniformOutput',false);
    % center of mass computation.
    centerOfMass = cell2mat(centerOfMassCell')';
    roiDist = squareform(pdist(centerOfMass));
    roiDist(eye(length(roiUse)) == 1) = Inf;
    edgeType{ff} = cellfun(@(roi) roi.typeInfo.edgeType,roiUse);
    
    [~,nearestRoi] = min(roiDist);
    
    nearestEdgeType{ff} = edgeType{ff}(nearestRoi);
    % 
    
%     %% do you want to plot all of them and check.? what is your old function?
%     roiMask = reshape(cell2mat(cellfun(@(roi)roi.stimInfo.roiMasks,roiUse,'UniformOutput',false)'),[127,256,length(roiUse)]);
%     colormap(gray(256));% not sure what color to use.
%     MakeFigure;
%     imagesc(sum(roiMask,3));
%     axis off
%     hold on
%     nRoi = size(roiMask,3);
%     
%     % compute distance, using this..
%     
%     for rr = 1:1:length(roiUse)
%         roiBoundaries = bwboundaries(roiMask(:,:,rr),8,'noholes');
%         % only plot boundaries...
%         plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',1,'color','k');
%         centerOfMass = [mean(find(sum(roiMask(:,:,rr),2) > 0)); mean(find(sum(roiMask(:,:,rr),1) > 0))];
%         text(centerOfMass(2),centerOfMass(1),num2str(rr),'color','r','FontSize',15,'FontWeight','bold');
%         
%     end
end

edgeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
T4T5Str = {'T4','T5'};
edgeTypeVec = cell2mat(edgeType);
nearestEdgeTypeVec = cell2mat(nearestEdgeType);
T5T4Type = zeros(length(edgeTypeVec),1);
T4T5Type(edgeTypeVec == 1 | edgeTypeVec == 2) = 1; % T4;
T4T5Type(edgeTypeVec == 3 | edgeTypeVec == 4) = 2; % T5;
nearestT4T5Type = zeros(length(edgeTypeVec),1);
nearestT4T5Type(nearestEdgeTypeVec == 1 | nearestEdgeTypeVec == 2) = 1; % T4;
nearestT4T5Type(nearestEdgeTypeVec == 3 | nearestEdgeTypeVec == 4) = 2; % T5;

proOrCount = 'prob';
MakeFigure;
for tt = 1:1:4
subplot(2,4,tt);
h = histogram(nearestEdgeTypeVec(edgeTypeVec == tt));
set(gca,'XTick',1:4,'XTickLabel',edgeStr);

title(['conditioned on ', edgeStr{tt}]);
if strcmp(proOrCount,'prob')
    h.Normalization = 'probability';
    set(gca,'YLim',[0,1]);
end
end

for tt = 1:1:2
subplot(2,4,tt + 4);
h = histogram(nearestT4T5Type(T4T5Type == tt));
set(gca,'XTick',1:2,'XTickLabel',T4T5Str);
title(['conditioned on ', T4T5Str{tt}]);
if strcmp(proOrCount,'prob')
    h.Normalization = 'probability';
    set(gca,'YLim',[0,1]);
end
end

subplot(2,4,7);
h = histogram(nearestEdgeTypeVec);
set(gca,'XTick',1:4,'XTickLabel',edgeStr);
title(['marginal distribution']);
if strcmp(proOrCount,'prob')
    h.Normalization = 'probability';
    set(gca,'YLim',[0,1]);
end

subplot(2,4,8);
h = histogram(nearestT4T5Type);
set(gca,'XTick',1:2,'XTickLabel',T4T5Str);
title(['marginal distribution']);

if strcmp(proOrCount,'prob')
    h.Normalization = 'probability';
    set(gca,'YLim',[0,1]);
end
end
%% only on the selected one...