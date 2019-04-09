w2p = GetPathsFromDatabase('T4T5','glidAM_3p2p_sweep','GC6f','right');

no2p =GetPathsFromDatabase('T4T5','glidAM_3p2p_sweep','GC6f','right');

baraGliderNo2 = [no2p(3:end)];%; w2p(2:end)];

baraGliderYes2 = [w2p(2:end-1)];

%%

% For no2p, good flies are 3,4,5,6

% For w2p, 2:end 

 

%%

%'CombAndSep','PlotTimeTraces', 

%'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge';'~Left Dark Edge', 'Left Light Edge', 'Right Dark Edge', 'Right Light Edge';'~Right Dark Edge', 'Right Light Edge', 'Left Dark Edge', 'Left Light Edge'    

%%

% The order of epochs as they appear in the parameter file (for w2p)

legVal = {'Uncorrelated' 'Uncorrelated'  'Diverging P+' 'Diverging N+' 'Diverging P-' 'Diverging N-'  ...

    'Converging P+' 'Converging N+'  'Converging P-' 'Converging N-'  '2pt P' '2pt N'};

%% Current way to run Emilio's roi selection file, I will try to merge them

 

% p1: Regressive T4 (~Left Light Edge)

% p2: Progressive T4 (~Right Light Edge)

% p3: Regressive T5 (~Left Dark Edge)

% p4: Progressive T5 (~Right Dark Edge)

 

% For the no2p

fullGlider3p1=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderNo2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Left Light Edge', 'Left Dark Edge', 'Right Light Edge', 'Right Dark Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt' },'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p2=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderNo2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt'},'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p3=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderNo2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Left Dark Edge', 'Left Light Edge', 'Right Dark Edge', 'Right Light Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt' },'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p4=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderNo2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Right Dark Edge', 'Right Light Edge', 'Left Dark Edge', 'Left Light Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt'},'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

 

% For the yes2p, truncated.

fullGlider3p1Cut=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','kill',4,'filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Left Light Edge', 'Left Dark Edge', 'Right Light Edge', 'Right Dark Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt' },'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p2Cut=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','kill',4,'filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt'},'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p3Cut=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','kill',4,'filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Left Dark Edge', 'Left Light Edge', 'Right Dark Edge', 'Right Light Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt' },'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p4Cut=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','kill',4,'filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Right Dark Edge', 'Right Light Edge', 'Left Dark Edge', 'Left Light Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt'},'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

 

% Collect together as {T4 Regressive T4 Progressive T5 Regressive T5

% Progressive}

 

ResponsesNo2p = {fullGlider3p1, fullGlider3p2, fullGlider3p3, fullGlider3p4};

ResponsesNo2pCut = {fullGlider3p1Cut, fullGlider3p2Cut, fullGlider3p3Cut, fullGlider3p4Cut};

%% Same as above but without truncating

fullGlider3p1=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Left Light Edge', 'Left Dark Edge', 'Right Light Edge', 'Right Dark Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt' },'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p2=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt'},'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p3=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Left Dark Edge', 'Left Light Edge', 'Right Dark Edge', 'Right Light Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt' },'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

fullGlider3p4=RunAnalysis('analysisFile',{'CombAndSep'},'dataPath',baraGliderYes2(:),'roiExtractionFile', 'IcaRoiExtraction','roiSelectionFile', 'SelectResponsiveRois','filterMovie',0,'forceRois',0,'epochsForSelectivity', {'~Right Dark Edge', 'Right Light Edge', 'Left Dark Edge', 'Left Light Edge'},'dataX',[],'tickX',1:6,'tickLabelX',{'Uncorrelated', 'Diverging +', 'Diverging -', 'Converging +', 'Converging -','2pt'},'labelX','','figLeg',legVal,'combOpp',0,'numSep',2,'filterMovie',1,'forceRois',0);

ResponsesYes2p = {fullGlider3p1, fullGlider3p2, fullGlider3p3, fullGlider3p4};

