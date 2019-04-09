useTurn = 0;
useWalk = 0;
useL1L2 = 0;

useLin = 0;


% max from poly fit
if exist('lam360r','var')
    turnMap = [lam360r.analysis.pTraces(:,:,1) lam180r.analysis.pTraces(:,:,1) lam120r.analysis.pTraces(:,:,1) lam90r.analysis.pTraces(:,:,1) lam60r.analysis.pTraces(:,:,1) lam45r.analysis.pTraces(:,:,1) lam30r.analysis.pTraces(:,:,1) lam22r.analysis.pTraces(:,:,1)];
    turnMapSEM = [lam360r.analysis.pSEMTraces(:,:,1) lam180r.analysis.pSEMTraces(:,:,1) lam120r.analysis.pSEMTraces(:,:,1) lam90r.analysis.pSEMTraces(:,:,1) lam60r.analysis.pSEMTraces(:,:,1) lam45r.analysis.pSEMTraces(:,:,1) lam30r.analysis.pSEMTraces(:,:,1) lam22r.analysis.pSEMTraces(:,:,1)];

    if useLin
        turnMax = [lam360r.analysis.linMax.turnMax lam180r.analysis.linMax.turnMax lam120r.analysis.linMax.turnMax lam90r.analysis.linMax.turnMax lam60r.analysis.linMax.turnMax lam45r.analysis.linMax.turnMax lam30r.analysis.linMax.turnMax lam22r.analysis.linMax.turnMax]';
        turnMaxSEM = [lam360r.analysis.linMax.turnMaxSEM lam180r.analysis.linMax.turnMaxSEM lam120r.analysis.linMax.turnMaxSEM lam90r.analysis.linMax.turnMaxSEM lam60r.analysis.linMax.turnMaxSEM lam45r.analysis.linMax.turnMaxSEM lam30r.analysis.linMax.turnMaxSEM lam22r.analysis.linMax.turnMaxSEM]';
    else
        turnMax = [lam360r.analysis.polyFit.turnMax lam180r.analysis.polyFit.turnMax lam120r.analysis.polyFit.turnMax lam90r.analysis.polyFit.turnMax lam60r.analysis.polyFit.turnMax lam45r.analysis.polyFit.turnMax lam30r.analysis.polyFit.turnMax lam22r.analysis.polyFit.turnMax]';
        turnMaxSEM = [lam360r.analysis.polyFit.turnMaxSEM lam180r.analysis.polyFit.turnMaxSEM lam120r.analysis.polyFit.turnMaxSEM lam90r.analysis.polyFit.turnMaxSEM lam60r.analysis.polyFit.turnMaxSEM lam45r.analysis.polyFit.turnMaxSEM lam30r.analysis.polyFit.turnMaxSEM lam22r.analysis.polyFit.turnMaxSEM]';

        turnScale = [lam360r.analysis.polyFit.turnScale lam180r.analysis.polyFit.turnScale lam120r.analysis.polyFit.turnScale lam90r.analysis.polyFit.turnScale lam60r.analysis.polyFit.turnScale lam45r.analysis.polyFit.turnScale lam30r.analysis.polyFit.turnScale lam22r.analysis.polyFit.turnScale]';
        turnScaleSEM = [lam360r.analysis.polyFit.turnScaleSEM lam180r.analysis.polyFit.turnScaleSEM lam120r.analysis.polyFit.turnScaleSEM lam90r.analysis.polyFit.turnScaleSEM lam60r.analysis.polyFit.turnScaleSEM lam45r.analysis.polyFit.turnScaleSEM lam30r.analysis.polyFit.turnScaleSEM lam22r.analysis.polyFit.turnScaleSEM]';
    end
    
    
    useTurn = 1;
else
    turnMap = zeros(17,8);
    turnMapSEM = ones(17,8);
    turnMax = zeros(17,1);
    turnMaxSEM = ones(17,1);
    turnScale = zeros(17,1);
    turnScaleSEM = ones(17,1);
end

if exist('lam360w','var')
    walkMap = [lam360w.analysis.pTraces(:,:,2) lam180w.analysis.pTraces(:,:,2) lam120w.analysis.pTraces(:,:,2) lam90w.analysis.pTraces(:,:,2) lam60w.analysis.pTraces(:,:,2) lam45w.analysis.pTraces(:,:,2) lam30w.analysis.pTraces(:,:,2) lam22w.analysis.pTraces(:,:,2)];
    walkMapSEM = [lam360w.analysis.pSEMTraces(:,:,2) lam180w.analysis.pSEMTraces(:,:,2) lam120w.analysis.pSEMTraces(:,:,2) lam90w.analysis.pSEMTraces(:,:,2) lam60w.analysis.pSEMTraces(:,:,2) lam45w.analysis.pSEMTraces(:,:,2) lam30w.analysis.pSEMTraces(:,:,2) lam22w.analysis.pSEMTraces(:,:,2)];

    if useLin
        walkMin = [lam360w.analysis.linMax.walkMin lam180w.analysis.linMax.walkMin lam120w.analysis.linMax.walkMin lam90w.analysis.linMax.walkMin lam60w.analysis.linMax.walkMin lam45w.analysis.linMax.walkMin lam30w.analysis.linMax.walkMin lam22w.analysis.linMax.walkMin]';
        walkMinSEM = [lam360w.analysis.linMax.walkMinSEM lam180w.analysis.linMax.walkMinSEM lam120w.analysis.linMax.walkMinSEM lam90w.analysis.linMax.walkMinSEM lam60w.analysis.linMax.walkMinSEM lam45w.analysis.linMax.walkMinSEM lam30w.analysis.linMax.walkMinSEM lam22w.analysis.linMax.walkMinSEM]';
    else
        walkMin = [lam360w.analysis.polyFit.walkMin lam180w.analysis.polyFit.walkMin lam120w.analysis.polyFit.walkMin lam90w.analysis.polyFit.walkMin lam60w.analysis.polyFit.walkMin lam45w.analysis.polyFit.walkMin lam30w.analysis.polyFit.walkMin lam22w.analysis.polyFit.walkMin]';
        walkMinSEM = [lam360w.analysis.polyFit.walkMinSEM lam180w.analysis.polyFit.walkMinSEM lam120w.analysis.polyFit.walkMinSEM lam90w.analysis.polyFit.walkMinSEM lam60w.analysis.polyFit.walkMinSEM lam45w.analysis.polyFit.walkMinSEM lam30w.analysis.polyFit.walkMinSEM lam22w.analysis.polyFit.walkMinSEM]';
        
        walkScale = [lam360w.analysis.polyFit.walkScale lam180w.analysis.polyFit.walkScale lam120w.analysis.polyFit.walkScale lam90w.analysis.polyFit.walkScale lam60w.analysis.polyFit.walkScale lam45w.analysis.polyFit.walkScale lam30w.analysis.polyFit.walkScale lam22w.analysis.polyFit.walkScale]';
        walkScaleSEM = [lam360w.analysis.polyFit.walkScaleSEM lam180w.analysis.polyFit.walkScaleSEM lam120w.analysis.polyFit.walkScaleSEM lam90w.analysis.polyFit.walkScaleSEM lam60w.analysis.polyFit.walkScaleSEM lam45w.analysis.polyFit.walkScaleSEM lam30w.analysis.polyFit.walkScaleSEM lam22w.analysis.polyFit.walkScaleSEM]';
    end
        
    useWalk = 1;
else
    walkMap = zeros(17,8);
    walkMapSEM = ones(17,8);
    walkMin = zeros(17,1);
    walkMinSEM = ones(17,1);
    walkScale = zeros(17,1);
    walkScaleSEM = ones(17,1);
end

if exist('lam120L1L2w','var')
    L1L2Map = [lam120L1L2w.analysis.pTraces(:,:,2) lam90L1L2w.analysis.pTraces(:,:,2) lam60L1L2w.analysis.pTraces(:,:,2) lam45L1L2w.analysis.pTraces(:,:,2) lam30L1L2w.analysis.pTraces(:,:,2) lam22L1L2w.analysis.pTraces(:,:,2)];
    L1L2MapSEM = [lam120L1L2w.analysis.pSEMTraces(:,:,2) lam90L1L2w.analysis.pSEMTraces(:,:,2) lam60L1L2w.analysis.pSEMTraces(:,:,2) lam45L1L2w.analysis.pSEMTraces(:,:,2) lam30L1L2w.analysis.pSEMTraces(:,:,2) lam22L1L2w.analysis.pSEMTraces(:,:,2)];

    if useLin
        L1L2Min = [lam120L1L2w.analysis.linMax.walkMin lam90L1L2w.analysis.linMax.walkMin lam60L1L2w.analysis.linMax.walkMin lam45L1L2w.analysis.linMax.walkMin lam30L1L2w.analysis.linMax.walkMin lam22L1L2w.analysis.linMax.walkMin]';
        L1L2MinSEM = [lam120L1L2w.analysis.linMax.walkMinSEM lam90L1L2w.analysis.linMax.walkMinSEM lam60L1L2w.analysis.linMax.walkMinSEM lam45L1L2w.analysis.linMax.walkMinSEM lam30L1L2w.analysis.linMax.walkMinSEM lam22L1L2w.analysis.linMax.walkMinSEM]';
    else
        L1L2Min = [lam120L1L2w.analysis.polyFit.walkMin lam90L1L2w.analysis.polyFit.walkMin lam60L1L2w.analysis.polyFit.walkMin lam45L1L2w.analysis.polyFit.walkMin lam30L1L2w.analysis.polyFit.walkMin lam22L1L2w.analysis.polyFit.walkMin]';
        L1L2MinSEM = [lam120L1L2w.analysis.polyFit.walkMinSEM lam90L1L2w.analysis.polyFit.walkMinSEM lam60L1L2w.analysis.polyFit.walkMinSEM lam45L1L2w.analysis.polyFit.walkMinSEM lam30L1L2w.analysis.polyFit.walkMinSEM lam22L1L2w.analysis.polyFit.walkMinSEM]';

        L1L2Scale = [lam120L1L2w.analysis.polyFit.walkScale lam90L1L2w.analysis.polyFit.walkScale lam60L1L2w.analysis.polyFit.walkScale lam45L1L2w.analysis.polyFit.walkScale lam30L1L2w.analysis.polyFit.walkScale lam22L1L2w.analysis.polyFit.walkScale]';
        L1L2ScaleSEM = [lam120L1L2w.analysis.polyFit.walkScaleSEM lam90L1L2w.analysis.polyFit.walkScaleSEM lam60L1L2w.analysis.polyFit.walkScaleSEM lam45L1L2w.analysis.polyFit.walkScaleSEM lam30L1L2w.analysis.polyFit.walkScaleSEM lam22L1L2w.analysis.polyFit.walkScaleSEM]';
    end
    
    useL1L2 = 1;
else
    L1L2Map = zeros(17,6);
    L1L2MapSEM = ones(17,6);
    L1L2Min = zeros(17,1);
    L1L2MinSEM = ones(17,1);
    L1L2Scale = zeros(17,1);
    L1L2ScaleSEM = ones(17,1);
end

if exist('cos120','var')
    cosMap = [cos120.analysis.pTraces(:,:,2) cos90.analysis.pTraces(:,:,2) cos60.analysis.pTraces(:,:,2) cos45.analysis.pTraces(:,:,2) cos30.analysis.pTraces(:,:,2) cos22.analysis.pTraces(:,:,2)];
    cosMapSEM = [cos120.analysis.pSEMTraces(:,:,2) cos90.analysis.pSEMTraces(:,:,2) cos60.analysis.pSEMTraces(:,:,2) cos45.analysis.pSEMTraces(:,:,2) cos30.analysis.pSEMTraces(:,:,2) cos22.analysis.pSEMTraces(:,:,2)];

    if useLin
        cosMin = [cos120.analysis.linMax.walkMin cos90.analysis.linMax.walkMin cos60.analysis.linMax.walkMin cos45.analysis.linMax.walkMin cos30.analysis.linMax.walkMin cos22.analysis.linMax.walkMin]';
        cosMinSEM = [cos120.analysis.linMax.walkMinSEM cos90.analysis.linMax.walkMinSEM cos60.analysis.linMax.walkMinSEM cos45.analysis.linMax.walkMinSEM cos30.analysis.linMax.walkMinSEM cos22.analysis.linMax.walkMinSEM]';
    else
        cosMin = [cos120.analysis.polyFit.walkMin cos90.analysis.polyFit.walkMin cos60.analysis.polyFit.walkMin cos45.analysis.polyFit.walkMin cos30.analysis.polyFit.walkMin cos22.analysis.polyFit.walkMin]';
        cosMinSEM = [cos120.analysis.polyFit.walkMinSEM cos90.analysis.polyFit.walkMinSEM cos60.analysis.polyFit.walkMinSEM cos45.analysis.polyFit.walkMinSEM cos30.analysis.polyFit.walkMinSEM cos22.analysis.polyFit.walkMinSEM]';

        cosScale = [cos120.analysis.polyFit.walkScale cos90.analysis.polyFit.walkScale cos60.analysis.polyFit.walkScale cos45.analysis.polyFit.walkScale cos30.analysis.polyFit.walkScale cos22.analysis.polyFit.walkScale]';
        cosScaleSEM = [cos120.analysis.polyFit.walkScaleSEM cos90.analysis.polyFit.walkScaleSEM cos60.analysis.polyFit.walkScaleSEM cos45.analysis.polyFit.walkScaleSEM cos30.analysis.polyFit.walkScaleSEM cos22.analysis.polyFit.walkScaleSEM]';
    end
    
    useL1L2 = 1;
else
    cosMap = zeros(17,6);
    cosMapSEM = ones(17,6);
    cosMin = zeros(17,1);
    cosMinSEM = ones(17,1);
    cosScale = zeros(17,1);
    cosScaleSEM = ones(17,1);
end

fitMin = 0;
fitMax = 3000;


walkX = 0:0.01:30;
L1L2X = 0:0.01:30;
turnX = 0:0.01:30;
cosX = 0:0.01:30;
combX = 0:0.01:30;

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


%% set up L1L2 data
theseLamL = 1:6;
lambdaL = [120 90 60 45 30 22.5]';
lambdaL = lambdaL(theseLamL);

L1L2Map = L1L2Map(:,theseLamL);
L1L2MapSEM = L1L2MapSEM(:,theseLamL);

cfL1L2Min = L1L2Min(theseLamL);
cfL1L2MinSEM = L1L2MinSEM(theseLamL);

velL1L2Min = cfL1L2Min.*lambdaL;
velL1L2MinSEM = cfL1L2MinSEM.*lambdaL;

L1L2Scale = L1L2Scale(theseLamL);
L1L2ScaleSEM = L1L2ScaleSEM(theseLamL);
    
[L1L2CoefB,L1L2CoefM] = york_fit(cfL1L2Min',velL1L2Min',cfL1L2MinSEM',velL1L2MinSEM',ones(size(cfL1L2MinSEM))');

L1L2Fit = L1L2X*L1L2CoefM+L1L2CoefB;

L1L2X(L1L2Fit<fitMin) = [];
L1L2Fit(L1L2Fit<fitMin) = [];
L1L2X(L1L2Fit>fitMax) = [];
L1L2Fit(L1L2Fit>fitMax) = [];

%% set up cos data
theseLamC = 1:6;
lambdaC = [120 90 60 45 30 22.5]';
lambdaC = lambdaC(theseLamC);

cosMap = cosMap(:,theseLamC);
cosMapSEM = cosMapSEM(:,theseLamC);

cfCosMin = cosMin(theseLamC);
cfCosMinSEM = cosMinSEM(theseLamC);

velCosMin = cfCosMin.*lambdaC;
velCosMinSEM = cfCosMinSEM.*lambdaC;

cosScale = cosScale(theseLamC);
cosScaleSEM = cosScaleSEM(theseLamC);
    
[cosCoefB,cosCoefM] = york_fit(cfCosMin',velCosMin',cfCosMinSEM',velCosMinSEM',ones(size(cfCosMinSEM))');

cosFit = cosX*cosCoefM+cosCoefB;

cosX(cosFit<fitMin) = [];
cosFit(cosFit<fitMin) = [];
cosX(cosFit>fitMax) = [];
cosFit(cosFit>fitMax) = [];
    
%% plot shit

%% plot lambda vs temporal frequency maximum

makeFigure;
hold on;
h1=ploterr(lambdaR,cfTurnMax,zeros(size(cfTurnMax)),cfTurnMaxSEM,'ob');
h2=ploterr(lambdaW,cfWalkMin,zeros(size(cfWalkMin)),cfWalkMinSEM,'or');
h3=ploterr(lambdaL,cfL1L2Min,zeros(size(cfL1L2Min)),cfL1L2MinSEM,'og');
legend([h1(1),h2(1),h3(1)],{'turning response' 'walking response' 'walking response in L1L2shits'});
p = zeros(1,2);

x = 1:max([lambdaR; lambdaW]);
[p(2),p(1)] = york_fit(lambdaR',cfTurnMax',1,cfTurnMaxSEM',zeros(size(cfTurnMax')));
y = p(1)*x+p(2);
plot(x,y,'linestyle','- -');

[p(2),p(1)] = york_fit(lambdaW',cfWalkMin',1,cfWalkMinSEM',zeros(size(cfWalkMin')));
y = p(1)*x+p(2);
plot(x,y,'r','linestyle','- -');

[p(2),p(1)] = york_fit(lambdaL',cfL1L2Min',1,cfL1L2MinSEM',zeros(size(cfL1L2Min')));
y = p(1)*x+p(2);
plot(x,y,'g','linestyle','- -');
grid off;
hold off;
    
%% plot lambda vs velocity maximum

makeFigure;
hold on;
h1=ploterr(lambdaR,velTurnMax,zeros(size(cfTurnMax)),velTurnMaxSEM,'ob');
h2=ploterr(lambdaW,velWalkMin,zeros(size(cfWalkMin)),velWalkMinSEM,'or');
h3=ploterr(lambdaL,velL1L2Min,zeros(size(cfL1L2Min)),velL1L2MinSEM,'og');
legend([h1(1),h2(1),h3(1)],{'turning response' 'walking response' 'walking response in L1L2shits'});

p = polyfit(lambdaR,velTurnMax,1);
y = p(1)*x+p(2);
plot(x,y,'linestyle','- -');

p = polyfit(lambdaW,velWalkMin,1);
y = p(1)*x+p(2);
plot(x,y,'r','linestyle','- -');

p = polyfit(lambdaL,velL1L2Min,1);
y = p(1)*x+p(2);
plot(x,y,'g','linestyle','- -');
grid off;
hold off;

%% plot lambda vs maximum value
makeFigure;
h1=ploterr(lambdaR,turnScale,zeros(size(cfTurnMax)),turnScaleSEM,'ob');
makeFigure;
hold on;
h2=ploterr(lambdaW,walkScale,zeros(size(cfWalkMin)),walkScaleSEM,'or');
h3=ploterr(lambdaL,L1L2Scale,zeros(size(cfL1L2Min)),L1L2ScaleSEM,'og');
hold off;



%% plot power maps
normWalk = flipud(walkMap);
normL1L2 = flipud(L1L2Map);
normTurn = flipud(turnMap);
%normTurn(normTurn>40) = 40;
normCos = flipud(cosMap);

makeFigure;
subplot(2,2,1);
plotHeat(normTurn,'turning','');
subplot(2,2,2);
plotHeat(normWalk,'walking','');
subplot(2,2,3);
plotHeat(normL1L2,'walking L1L2>shits','');
subplot(2,2,4);
plotHeat(normCos,'walk cont inv','');

makeFigure;
subplot(2,2,1);
plotHeat(normTurn,'turning','');
subplot(2,2,2);
plotHeat(normCos,'walk cont inv','');
subplot(2,2,3);
plotHeat(normWalk,'walking','');
subplot(2,2,4);

try

weights = regress(normWalk(:),[ones(size(normCos(:))) normCos(:) normTurn(:)]);
combModel = weights(1) + weights(2)*normCos + weights(3)*normTurn;
disp(weights);
plotHeat(combModel,'linear combination of turn and cont inv','');

fitLength = 100;
polyOrder = 6;
logDataX = log([0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32 48 64])';
fitX = linspace(logDataX(1),logDataX(end),fitLength)';
combModelFit = zeros(fitLength,size(combModel,2));
for ll = 1:6 % fit a polynomial to the comb model to see where its maximums are
    % plot out the representive polyfit for visualization
    [coefFit,S] = polyfit(logDataX,combModel(:,ll),polyOrder);
    [combModelFit(:,ll)] = polyval(coefFit,fitX,S);
end

[~,minInd] = min(combModelFit);
cfRange = fliplr(linspace(-2,6,fitLength))';
cfRange = 2.^cfRange;
catch
end

%% plot temporal frequency vs velocity maximum
makeFigure;
hold on;

hr = ploterr(cfTurnMax,velTurnMax,cfTurnMaxSEM,velTurnMaxSEM,'bo');
plot(turnX,turnFit,'linestyle','- -','color','b');

hw = ploterr(cfWalkMin,velWalkMin,cfWalkMinSEM,velWalkMinSEM,'ro');
plot(walkX,walkFit,'linestyle','- -','color','r');

hl = ploterr(cfL1L2Min,velL1L2Min,cfL1L2MinSEM,velL1L2MinSEM,'go');
plot(L1L2X,L1L2Fit,'linestyle','- -','color','g');

% hc = ploterr(cfCosMin,velCosMin,cfCosMinSEM,velCosMinSEM,'co');
% plot(cosX,cosFit,'linestyle','- -','color','c');

scatter(cfRange(minInd),cfRange(minInd).*lambdaC,'k');
p = polyfit(cfRange(minInd),cfRange(minInd).*lambdaC,1);

combFit = p(1)*combX+p(2);

combX(combFit<fitMin) = [];
combFit(combFit<fitMin) = [];
combX(combFit>fitMax) = [];
combFit(combFit>fitMax) = [];

plot(combX,combFit,'linestyle','- -','color','k');

xlabel('temporal frequency maximum');
ylabel('velocity maximum');
legend([hr(1),hw(1),hl(1)],{'turning response' 'walking response' 'walking response in L1L2-shits'});

hold off;