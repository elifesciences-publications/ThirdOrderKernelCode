function CombineSameRoi_Clustering_Visualization_Utils_ShowOneRoiMask(roiMask,edgeTrace,clusteredObject)

% set a color limit.?
colormap(gray(256));% not sure what color to use.
subplot(3,1,1:2)
imagesc(sum(roiMask,3));
axis off
hold on
nRoi = size(roiMask,3);
for rr = 1:1:nRoi
    roiBoundaries = bwboundaries(roiMask(:,:,rr),8,'noholes');
    % only plot boundaries...
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',1,'color','k');
end

% ConfAxis;

objCombined = clusteredObject.which;
objNameArray = clusteredObject.objectName;
objIndex = zeros(2,1);
objIndex(1) = find( objNameArray == objCombined(1));objIndex(2) = find( objNameArray == objCombined(2));

% find out the center of Mass;
for ii = 1:1:2
    roiMaskObj = roiMask(:,:,objIndex(ii));
    centerOfMass = [mean(find(sum(roiMaskObj,2) > 0)); mean(find(sum(roiMaskObj,1) > 0))];
    text(centerOfMass(2),centerOfMass(1),num2str(objCombined(ii)),'color','r','FontSize',15,'FontWeight','bold');
    % normally
    % make the boudary of those to to be red...
    roiBoundaries = bwboundaries(roiMaskObj,8,'noholes');
    % only plot boundaries...
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',1,'color','y');
    
end
hold off
subplot(3,1,3);
% plot two traces and combined trace...
plot(edgeTrace(:,objIndex(1)));
hold on
plot(edgeTrace(:,objIndex(2)));
legend(num2str(objCombined(1)),num2str(objCombined(2)));
ax = gca; yLim = ax.YLim;
% show the r value and distance between the two.
% title(['corr : ', num2str(clusteredObject.corrValue),' dist', num2str(clusteredObject.distValue)]);
% plot blue line to seperate different egdes and squarewaves, so many T4T5
% together..
timeEdge = (1:4)' * 156;
timeSquare = timeEdge(end) + (1:3)' * 56;
timePoint = [timeEdge;timeSquare];
for ee = 1:1:7
    plot([timePoint(ee),timePoint(ee)],yLim,'k');
end
hold off
end