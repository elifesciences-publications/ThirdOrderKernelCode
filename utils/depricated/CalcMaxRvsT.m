% max from poly fit
turnMap = [lam360r.analysis.pTraces(:,:,1) lam180r.analysis.pTraces(:,:,1) lam120r.analysis.pTraces(:,:,1) lam90r.analysis.pTraces(:,:,1) lam60r.analysis.pTraces(:,:,1) lam45r.analysis.pTraces(:,:,1) lam30r.analysis.pTraces(:,:,1) lam22r.analysis.pTraces(:,:,1)];
turnMapSEM = [lam360r.analysis.pSEMTraces(:,:,1) lam180r.analysis.pSEMTraces(:,:,1) lam120r.analysis.pSEMTraces(:,:,1) lam90r.analysis.pSEMTraces(:,:,1) lam60r.analysis.pSEMTraces(:,:,1) lam45r.analysis.pSEMTraces(:,:,1) lam30r.analysis.pSEMTraces(:,:,1) lam22r.analysis.pSEMTraces(:,:,1)];

turnMax = [lam360r.analysis.polyFit.turnMax lam180r.analysis.polyFit.turnMax lam120r.analysis.polyFit.turnMax lam90r.analysis.polyFit.turnMax lam60r.analysis.polyFit.turnMax lam45r.analysis.polyFit.turnMax lam30r.analysis.polyFit.turnMax lam22r.analysis.polyFit.turnMax]';
turnMaxSEM = [lam360r.analysis.polyFit.turnMaxSEM lam180r.analysis.polyFit.turnMaxSEM lam120r.analysis.polyFit.turnMaxSEM lam90r.analysis.polyFit.turnMaxSEM lam60r.analysis.polyFit.turnMaxSEM lam45r.analysis.polyFit.turnMaxSEM lam30r.analysis.polyFit.turnMaxSEM lam22r.analysis.polyFit.turnMaxSEM]';

turnScale = [lam360r.analysis.polyFit.turnScale lam180r.analysis.polyFit.turnScale lam120r.analysis.polyFit.turnScale lam90r.analysis.polyFit.turnScale lam60r.analysis.polyFit.turnScale lam45r.analysis.polyFit.turnScale lam30r.analysis.polyFit.turnScale lam22r.analysis.polyFit.turnScale]';
turnScaleSEM = [lam360r.analysis.polyFit.turnScaleSEM lam180r.analysis.polyFit.turnScaleSEM lam120r.analysis.polyFit.turnScaleSEM lam90r.analysis.polyFit.turnScaleSEM lam60r.analysis.polyFit.turnScaleSEM lam45r.analysis.polyFit.turnScaleSEM lam30r.analysis.polyFit.turnScaleSEM lam22r.analysis.polyFit.turnScaleSEM]';


walkMap = [lam360w.analysis.pTraces(:,:,2) lam180w.analysis.pTraces(:,:,2) lam120w.analysis.pTraces(:,:,2) lam90w.analysis.pTraces(:,:,2) lam60w.analysis.pTraces(:,:,2) lam45w.analysis.pTraces(:,:,2) lam30w.analysis.pTraces(:,:,2) lam22w.analysis.pTraces(:,:,2)];
walkMapSEM = [lam360w.analysis.pSEMTraces(:,:,2) lam180w.analysis.pSEMTraces(:,:,2) lam120w.analysis.pSEMTraces(:,:,2) lam90w.analysis.pSEMTraces(:,:,2) lam60w.analysis.pSEMTraces(:,:,2) lam45w.analysis.pSEMTraces(:,:,2) lam30w.analysis.pSEMTraces(:,:,2) lam22w.analysis.pSEMTraces(:,:,2)];

walkMin = [lam360w.analysis.polyFit.walkMin lam180w.analysis.polyFit.walkMin lam120w.analysis.polyFit.walkMin lam90w.analysis.polyFit.walkMin lam60w.analysis.polyFit.walkMin lam45w.analysis.polyFit.walkMin lam30w.analysis.polyFit.walkMin lam22w.analysis.polyFit.walkMin]';
walkMinSEM = [lam360w.analysis.polyFit.walkMinSEM lam180w.analysis.polyFit.walkMinSEM lam120w.analysis.polyFit.walkMinSEM lam90w.analysis.polyFit.walkMinSEM lam60w.analysis.polyFit.walkMinSEM lam45w.analysis.polyFit.walkMinSEM lam30w.analysis.polyFit.walkMinSEM lam22w.analysis.polyFit.walkMinSEM]';

walkScale = [lam360w.analysis.polyFit.walkScale lam180w.analysis.polyFit.walkScale lam120w.analysis.polyFit.walkScale lam90w.analysis.polyFit.walkScale lam60w.analysis.polyFit.walkScale lam45w.analysis.polyFit.walkScale lam30w.analysis.polyFit.walkScale lam22w.analysis.polyFit.walkScale]';
walkScaleSEM = [lam360w.analysis.polyFit.walkScaleSEM lam180w.analysis.polyFit.walkScaleSEM lam120w.analysis.polyFit.walkScaleSEM lam90w.analysis.polyFit.walkScaleSEM lam60w.analysis.polyFit.walkScaleSEM lam45w.analysis.polyFit.walkScaleSEM lam30w.analysis.polyFit.walkScaleSEM lam22w.analysis.polyFit.walkScaleSEM]';


fitMin = 0;
fitMax = 3000;


walkX = 0:0.01:30;
turnX = 0:0.01:30;

%% set up turn data
theseLamR = 3:8;
lambdaR = [360 180 120 90 60 45 30 22.5]';
lambdaR = lambdaR(theseLamR);

turnMap = turnMap(:,theseLamR);
turnMapSEM = turnMapSEM(:,theseLamR);

cfTurnMax = turnMax(theseLamR);
cfTurnMaxSEM = turnMaxSEM(theseLamR);

velTurnMax = cfTurnMax.*lambdaR;
velTurnMaxSEM = cfTurnMaxSEM.*lambdaR;

turnScale = turnScale(theseLamR);
turnScaleSEM = turnScaleSEM(theseLamR);

[turnCoefB,turnCoefM] = york_fit(cfTurnMax',velTurnMax',cfTurnMaxSEM',velTurnMaxSEM',ones(size(cfTurnMaxSEM))');

turnFit = turnX*turnCoefM+turnCoefB;

turnX(turnFit<=fitMin) = [];
turnFit(turnFit<=fitMin) = [];
turnX(turnFit>fitMax) = [];
turnFit(turnFit>fitMax) = [];


%% set up walk data
theseLamW = 3:8;
lambdaW = [360 180 120 90 60 45 30 22.5]';
lambdaW = lambdaW(theseLamW);

walkMap = walkMap(:,theseLamW);
walkMapSEM = walkMapSEM(:,theseLamW);

cfWalkMin = walkMin(theseLamW);
cfWalkMinSEM = walkMinSEM(theseLamW);
    
velWalkMin = cfWalkMin.*lambdaW;
velWalkMinSEM = cfWalkMinSEM.*lambdaW;

walkScale = walkScale(theseLamW);
walkScaleSEM = walkScaleSEM(theseLamW);

[walkCoefB,walkCoefM] = york_fit(cfWalkMin',velWalkMin',cfWalkMinSEM',velWalkMinSEM',ones(size(cfWalkMinSEM))');

walkFit = walkX*walkCoefM+walkCoefB;

walkX(walkFit<fitMin) = [];
walkFit(walkFit<fitMin) = [];
walkX(walkFit>fitMax) = [];
walkFit(walkFit>fitMax) = [];


%% plot shit

%% plot lambda vs temporal frequency maximum

makeFigure;
hold on;
h1=ploterr(lambdaR,cfTurnMax,zeros(size(cfTurnMax)),cfTurnMaxSEM,'ob');
h2=ploterr(lambdaW,cfWalkMin,zeros(size(cfWalkMin)),cfWalkMinSEM,'or');
legend([h1(1),h2(1)],{'turning response' 'walking response'});
p = zeros(1,2);

x = 1:max([lambdaR; lambdaW]);
[p(2),p(1)] = york_fit(lambdaR',cfTurnMax',1,cfTurnMaxSEM',zeros(size(cfTurnMax')));
y = p(1)*x+p(2);
plot(x,y,'linestyle','- -');

% fit walking data to a constant velocity curve
fitModel=fitnlm(lambdaW,cfWalkMin,@(a,x) a(1)./x,500,'Weight',1./cfWalkMinSEM.^2);
a = fitModel.Coefficients.Estimate;
x = 20:139;
y = a./x;
plot(x,y,'r','linestyle','- -') %fit

%[p(2),p(1)] = york_fit(lambdaW',cfWalkMin',1,cfWalkMinSEM',zeros(size(cfWalkMin')));
% y = p(1)*x+p(2);
% plot(x,y,'r','linestyle','- -');

grid off;
hold off;
    
%% plot lambda vs velocity maximum

makeFigure;
hold on;
h1=ploterr(lambdaR,velTurnMax,zeros(size(cfTurnMax)),velTurnMaxSEM,'ob');
h2=ploterr(lambdaW,velWalkMin,zeros(size(cfWalkMin)),velWalkMinSEM,'or');
legend([h1(1),h2(1)],{'turning response' 'walking response'});

p = polyfit(lambdaR,velTurnMax,1);
y = p(1)*x+p(2);
plot(x,y,'linestyle','- -');

p = polyfit(lambdaW,velWalkMin,1);
y = p(1)*x+p(2);
plot(x,y,'r','linestyle','- -');

grid off;
hold off;

%% plot lambda vs maximum value
makeFigure;
h1=ploterr(lambdaR,turnScale,zeros(size(cfTurnMax)),turnScaleSEM,'ob');
makeFigure;
hold on;
h2=ploterr(lambdaW,walkScale,zeros(size(cfWalkMin)),walkScaleSEM,'or');
hold off;



%% plot power maps
flipWalk = flipud(walkMap);
flipTurn = flipud(turnMap);

makeFigure;
subplot(1,2,1);
plotHeat(flipTurn,'turning','');
subplot(1,2,2);
plotHeat(flipWalk,'walking','');


%% plot temporal frequency vs velocity maximum
makeFigure;
hold on;

hr = ploterr(cfTurnMax,velTurnMax,cfTurnMaxSEM,velTurnMaxSEM,'bo');
plot(turnX,turnFit,'linestyle','- -','color','b');

hw = ploterr(cfWalkMin,velWalkMin,cfWalkMinSEM,velWalkMinSEM,'ro');
plot(walkX,walkFit,'linestyle','- -','color','r');

xlabel('temporal frequency maximum');
ylabel('velocity maximum');
legend([hr(1),hw(1)],{'turning response' 'walking response'});

hold off;