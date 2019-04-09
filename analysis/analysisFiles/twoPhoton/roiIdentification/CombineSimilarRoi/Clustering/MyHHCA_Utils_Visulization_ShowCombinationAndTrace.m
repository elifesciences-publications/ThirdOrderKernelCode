function  MyHHCA_Utils_Visulization_ShowCombinationAndTrace(roiMask,edgeTrace,whichCombine,objName)
colormap(gray(256));% not sure what color to use.
subplot(3,1,1:2)
% try to fully use the color...
MyHHCA_Utils_Visualization_MyImagesc_RoiMask(roiMask)
axis off
hold on
nRoi = length(objName);
for rr = 1:1:nRoi
    roiBoundaries = bwboundaries(roiMask == objName(rr),8,'noholes');
    % only plot boundaries...
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',1,'color','y');
end

% ConfAxis;

% objNameArray = objName;
% objIndex = zeros(2,1);
objIndex = find(ismember(objName,whichCombine)); % might three, do you want to do this?
% find out the center of Mass;

nElements = length(whichCombine);
centerOfMass = zeros(2,nElements);
for ii = 1:1:nElements
    roiMaskObj = roiMask == whichCombine(ii);
    centerOfMass(:,ii) = [mean(find(sum(roiMaskObj,2) > 0)); mean(find(sum(roiMaskObj,1) > 0))];
    text(centerOfMass(2,ii),centerOfMass(1,ii),num2str( whichCombine(ii)),'color','r','FontSize',15,'FontWeight','bold');
    % normally
    % make the boudary of those to to be red...
    roiBoundaries = bwboundaries(roiMaskObj,8,'noholes');
    % only plot boundaries...
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',1,'color','r');
    
end
hold off
subplot(3,1,3);
legendStr = cell(nElements,1);
for ii = 1:1:nElements
% plot two traces and combined trace...
plot(edgeTrace(:,objIndex(ii)));
hold on
legendStr{ii} = num2str(whichCombine(ii));
end
legend(legendStr);

ax = gca; yLim = ax.YLim;
% show the r value and distance between the two.
edgeTraceThis = edgeTrace(:,objIndex);

edgeTraceSmooth = smooth(edgeTraceThis(:),5); edgeTraceSmooth = reshape(edgeTraceSmooth ,size(edgeTraceThis ));
corrThis  = corr(edgeTraceSmooth);
corrVec = corrThis(tril(true(nElements,nElements),-1));
distVec = pdist(centerOfMass');
title(['corr : ', strsplit(num2str(corrVec','%.2f,')),'dist', strsplit(num2str(distVec,'%.2f,'))]);
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