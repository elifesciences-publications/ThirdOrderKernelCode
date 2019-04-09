function FigPlot_DSISQ_DSIED(roiData)
nRoi = length(roiData);
contrastType = zeros(nRoi,1);
DSI_Edge_Combined = zeros(nRoi,1);
DSI_Edge_NoNorm_Combined = zeros(nRoi,1);
DSI_Edge_PreferedCont = zeros(nRoi,1);
DSI_Edge_NoNorm_PreferedCont = zeros(nRoi,1);

DSI_Square = zeros(nRoi,1);
DSI_NoNorm = zeros(nRoi,1);
% instead of looking at normalized value, you can also look at just the
% difference...
for rr = 1:1:nRoi
    roi = roiData{rr};
    contrastType(rr) = roi.typeInfo.contrastType;
    % DSI_Edge is progressive - regressive from edge response.
    % could be combination of the light and dark
    % could only be the prefered contrast.
    
    edgePro = roi.typeInfo.value([1,3]);
    edgeReg = roi.typeInfo.value([2,4]);
    ld = roi.typeInfo.contrastType;
   
    DSI_Edge_Combined(rr) = (sum(edgePro) - sum(edgeReg))/(sum(edgePro) + sum(edgeReg));
    DSI_Edge_NoNorm_Combined(rr) = (sum(edgePro) - sum(edgeReg));
    
    DSI_Edge_PreferedCont(rr) = (edgePro(ld) - edgeReg(ld))/(edgePro(ld) + edgeReg(ld));
    DSI_Edge_NoNorm_PreferedCont(rr) = (edgePro(ld) - edgeReg(ld));
    
    DSI_Square(rr) = roi.typeInfo.DSI_Diff;
    squarePro = roi.typeInfo.value(5);
    squareReg = roi.typeInfo.value(6);
    DSI_NoNorm(rr) = squarePro - squareReg; 
end


DSI_Square(DSI_Square < -1) = -1;
DSI_Square(DSI_Square > 1) = 1;

MakeFigure;
subplot(2,2,1);
scatter(DSI_Edge_NoNorm_PreferedCont,DSI_Edge_NoNorm_Combined,'r+');
xlabel('prefered contrast');
ylabel('conbined two contrast');
title('difference in peak response');
subplot(2,2,2);
scatter(DSI_Edge_Combined, DSI_Edge_PreferedCont,'r+');
xlabel('prefered contrast');
ylabel('conbined two contrast');
title('DSI');

% MakeFigure;
% subplot(2,2,1);
% DSI_Edge_Plot = DSI_Edge_Combined;
% scatter(DSI_Square,DSI_Edge_Plot,'r.');
% hold on
% plot([-2,2],[0,0],'y-')
% plot([0,0],[-2,2],'y-');
% hold off
% xlabel('DSI from square wave Progressive - Regressive');
% ylabel('DSI from Edge Progressive - Regressive');
% title('Combined')
% axis([-2,2,-2,2]);
MakeFigure;
subplot(2,2,1); % prove that is does not work very well....
yLimMax = max(abs(DSI_NoNorm));
scatter(DSI_Square,DSI_NoNorm,'r.');
hold on
plot([-2,2],[0,0],'y-')
plot([0,0],[-yLimMax,yLimMax],'y-');
hold off
xlabel('DSI index');
ylabel('D difference');
title('DSI index VS D difference')

subplot(2,2,2);
xLimMax = max(abs(DSI_Edge_NoNorm_Combined));
scatter(DSI_Edge_NoNorm_Combined,DSI_NoNorm,'r.');
hold on
plot([-xLimMax,xLimMax],[0,0],'y-')
plot([0,0],[-yLimMax,yLimMax],'y-');
hold off
ylabel('D from Edge');
xlabel('D difference from square wave');
title('light/Dark response combined');
axis([-xLimMax,xLimMax,-yLimMax,yLimMax]);


subplot(2,2,3); % continue to prove that it does not work very well..
DSI_Edge_Plot = DSI_Edge_Combined;
scatter(DSI_Square,DSI_Edge_Plot,'r.');
hold on
plot([-2,2],[0,0],'y-')
plot([0,0],[-2,2],'y-');
hold off
xlabel('DSI from square wave Progressive - Regressive');
ylabel('DSI from Edge Progressive - Regressive');
title('light/Dark response combined');
axis([-2,2,-2,2]);

subplot(2,2,4);
scatter(DSI_Edge_Plot,DSI_NoNorm,'r.');
hold on
plot([-2,2],[0,0],'y-')
plot([0,0],[-yLimMax,yLimMax],'y-');
hold off
ylabel('D difference');
xlabel('DSI from Edge');
title('light/Dark response combined');
axis([-2,2,-yLimMax,yLimMax]);


MakeFigure;
subplot(2,2,1); % prove that is does not work very well....
yLimMax = max(abs(DSI_NoNorm));
scatter(DSI_Square,DSI_NoNorm,'r.');
hold on
plot([-2,2],[0,0],'y-')
plot([0,0],[-yLimMax,yLimMax],'y-');
hold off
xlabel('DSI index');
ylabel('D difference');
title('DSI index VS D difference')

subplot(2,2,2);
xLimMax = max(abs(DSI_Edge_NoNorm_PreferedCont));
scatter(DSI_Edge_NoNorm_PreferedCont,DSI_NoNorm,'r.');
hold on
plot([-xLimMax,xLimMax],[0,0],'y-')
plot([0,0],[-yLimMax,yLimMax],'y-');
hold off
ylabel('D from Edge');
xlabel('D difference from square wave');
title('Prefered Contrast');
axis([-xLimMax,xLimMax,-yLimMax,yLimMax]);


subplot(2,2,3); % continue to prove that it does not work very well..
DSI_Edge_Plot = DSI_Edge_PreferedCont;
scatter(DSI_Square,DSI_Edge_Plot,'r.');
hold on
plot([-2,2],[0,0],'y-')
plot([0,0],[-2,2],'y-');
hold off
xlabel('DSI from square wave Progressive - Regressive');
ylabel('DSI from Edge Progressive - Regressive');
title('Prefered Contrast');
axis([-2,2,-2,2]);

subplot(2,2,4);
scatter(DSI_Edge_Plot,DSI_NoNorm,'r.');
hold on
plot([-2,2],[0,0],'y-')
plot([0,0],[-yLimMax,yLimMax],'y-');
hold off
ylabel('D difference');
xlabel('DSI from Edge');
title('Prefered Contrast');
axis([-2,2,-yLimMax,yLimMax]);

end