function FigPlot1(Z,flyEye,varargin)
%FigPlot1(Z,flyEye,'roiSelectionFlag',true,'roiSelected',roiSelected,'fig1_b_Flag','true,fig1_c_Flag',true,'fig1_trace_Flag',true, 'fig1_DSIESI_flag',true,'saveFigFlag',true)
% you could control what do you plot...
fig1_b_Flag = true;
fig1_c_Flag = true;
fig1_trace_Flag = true;
fig1_DSIESI_flag = true;
roiSelectionFlag = true;
roiSelcted = [];
DSIThreshold = 0.5;
saveFigFlag = false;
MainName = ['Fig1'];
nFigSave = 3;
figFileType = {'fig','eps','png'};
metaAnalysis_flag = false;

for ii = 1:2:length(varargin)
    str = [ varargin{ii} ' = varargin {' num2str(ii+1) '};'];
    eval(str);
end
[dirTypeColorRGB,edgeTypeColorRGB,DarkLightColor] = FigPlot1ColorCode();
dirTypeColorRGB(1,:) = [0,0,0]; % progressive
%% get the roiMasks and roiImage from Z.
% in the future, this might be changed. but for now, Z is used...
roiMasks = Z.ROI.roiMasks(:,:,1:end - 1);
roiCenterOfMass = Z.ROI.roiCenterOfMass(1:end-1,:);
movieMean = Z.rawTraces.movieMean;
windowMask = Z.grab.windowMask;
nRoi = size(roiMasks,3);

%% roiImage will be the place in the windowMasks.
verInd = find(sum(windowMask,2) > 0);
horInd = find(sum(windowMask,1) > 0);
roiImage = movieMean(verInd(1):verInd(end),horInd(1):horInd(end));
roiMasksChop = zeros(length(verInd),length(horInd),nRoi);
for rr = 1:1:nRoi
    roiMasksChop(:,:,rr) = roiMasks(verInd(1):verInd(end),horInd(1):horInd(end),rr);
end
roiMasks = roiMasksChop;

%% produce a figure, which has roi and mean image.
[~,roiTrace] = RoiClassification(Z,flyEye);
[cfRoi] = ESIDSI_CalculationExplore(Z,flyEye);
% here, only the cc is larger than 0.1 if allowed...

%% Start Plotting....
%% first, use square waves to plot out the four layers...
roiSquareType = cfRoi.PEye.dirType;
if ~roiSelectionFlag
    roiSelected = true(nRoi,1);
end

roiSelected = roiSelected & (cfRoi.repeatability.wholeProb > 0.1);

if fig1_b_Flag
    MakeFigure
    colormap(gray(256));
    imagesc(roiImage);
    axis off
    hold on
    for rr = 1:1:nRoi
        roiBoundaries = MyBWBoundaries(roiMasks(:,:,rr));
%         roiBoundaries = bwboundaries(roiMasks(:,:,rr),8,'noholes');
        if length(roiBoundaries) > 1
            keyboard;
        end
        % sometimes, there are more than one boudaries, you have to find
        % the largest one...
        type = roiSquareType(rr);
        if roiSelected(rr)
            plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',5,'color',dirTypeColorRGB(type,:));
        end
    end
    hold off
    ConfAxis;
    try
        FigPlot1_PlotScaleBar(Z,verInd,horInd)
    catch 
    end
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,'_a_fourLayer','nFigSave',nFigSave,'fileType',figFileType);
    end
    % save the data, by type, name, number and name
end

if fig1_c_Flag
    MakeFigure
    colormap(gray(256));
    imagesc(roiImage);
    axis off
    hold on
    contrastType = cfRoi.PEye.contrastType;
    leftRightFlag = cfRoi.PEye.leftRightFlag;
    edgeType = cfRoi.PEye.edgeType;
    for rr = 1:1:nRoi
        roiBoundaries = MyBWBoundaries(roiMasks(:,:,rr));
        % determine whether it is left/right selective...
        type = contrastType(rr);
        % I am coding DSI here, not the ESI....
%         DSI_Edge = abs(cfRoi.PEye.DSI_Edge(rr));
%         ESI_Edge  = abs(cfRoi.PEye.LDSI_Combined(rr));
         ESI_Edge  = abs(cfRoi.PEye.ESI_V2(rr));

        %     type = edgeType(rr);
        if roiSelected(rr) && leftRightFlag(rr)
            h = rgb2hsv(DarkLightColor(type,:));
%             hsvThis = [h(1),DSI_Edge,1];
            hsvThis = [h(1),ESI_Edge,1];
            rgbThis = hsv2rgb(hsvThis);
            plot(roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',5,'color',rgbThis);
        end
    end
    %% MakeFigure;
    %roiSelection based on cfRoi....
    % once you get some roi, select the best 4 of them to do analysis....
    % roiSelectedCorrPeakConsist = RoiSelectionByProbingStimulus(cfRoi,'method','CorrPeakConsistency','classInterested',1);
    % roiSelected = roiSelectedCorrPeakConsist;
    roiUse = find(roiSelected);
    
    % first, plot the trace for this roi,
    nRoiUse = length(roiUse);
    bestRoi = zeros(4,1);
    bestRoiESI = zeros(4,1);
    maxTraceValue = 6;
    % %
    % confine the value of the maximum trace to be smaller...
    for ii = 1:1:nRoiUse
        rr = roiUse(ii);
        type = cfRoi.PEye.edgeType(rr);
        edgeRespThisRoi = cfRoi.PEye.value(rr,type);
        ESI = cfRoi.PEye.ESI(rr,type);
        if ESI > bestRoiESI(type) && edgeRespThisRoi < maxTraceValue; %
            bestRoi(type) = rr;
            bestRoiESI(type)= ESI;
        end
    end
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
    
    %%
    % the centerOfMass has to be transfered.
    
    
    ConfAxis;
    hold on
    axis off
    for tt = 1:1:4
        rr = bestRoi(tt); % there might be zero. If there is zero, give out an error?
        if roiTypeExistFlag(tt)
            centerOfMass = roiCenterOfMass(rr,:) - [verInd(1),horInd(1)];
            %             text(centerOfMass(2), centerOfMass(1), num2str(rr), 'HorizontalAlignment', 'center', 'Color', [1,1,1]);
            text(centerOfMass(2), centerOfMass(1), num2str(tt), 'HorizontalAlignment', 'center', 'Color', [0,0,0],'FontSize',20);
            
        end
        
    end
    hold off
    ConfAxis;
    try
        FigPlot1_PlotScaleBar(Z,verInd,horInd)
    catch 
    end
    
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,'_a_twoLayer','nFigSave',nFigSave,'fileType',figFileType);
    end
end

%% plot trace
if fig1_trace_Flag
    MakeFigure;
    traceAllRoi = cell(4,1);
    for tt = 1:1:4
        if roiTypeExistFlag(tt)
            rr = bestRoi(tt);
            traceAllRoi{tt} = roiTrace.eye.indiVidualTrace{rr};
        end
    end
    traceTogether = [];
    for tt = 1:1:4
        alltrace = traceAllRoi{tt};
        for ii = 1:1:size(alltrace,1)
            for jj = 1:1:size(alltrace,2)
                traceTogether =  [traceTogether;alltrace{ii,jj}];
            end
        end
    end
    
    yLimMin = min(traceTogether);
    yLimMax = max(traceTogether);
    for tt = 1:1:4
        if roiTypeExistFlag(tt)
            rr = bestRoi(tt);
            allTrace = roiTrace.eye.indiVidualTrace{rr};
%             corrValue = cfRoi.CCEye.value(rr,1:4);
            name = cfRoi.PEye.edgeName(rr);
            subplot(2,2,tt)
            % it needs Xlabel and Y Label As well.
            %     PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','titleStr',name,'colorBank',edgeTypeColorRGB);
            % first, collect all the traces and get the scale...
            PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye',...
                'legendLabel','typeOnly','legendValue',[],'titleStr',name,'colorBank',edgeTypeColorRGB,...
                'yLimPreSetFlag',true,'yLimMinPreSet',yLimMin,'yLimMaxPreSet',yLimMax);
            
        end
    end
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,'_b_trace','nFigSave',nFigSave,'fileType',figFileType);
    end
end


%%
% if fig1_DSIESI_flag
%     
%     leftRightFlag = cfRoi.PEye.leftRightFlag;
%     % fig_1c
%     % % progressive are always 1 and 2, regressive are always 3 and 4...
%     % edgeTypesStrEye = {'Progressive Dark','Progressive Light','Regressive Dark','Regressive Light','Progressive','Regressive','Up','Down'};
%     dirTypeStrEye = {'Progressive','Regressive','Up','Down'};
%     contrastTypeStr = {'Light','Dark'};
%     
%     % distribution of DSI and ESI.
%     % calculate individual DSI and ESI.
%     LDSI_Prefered = cfRoi.PEye.LDSI_PreferedDir;
%     LDSI_Combined = cfRoi.PEye.LDSI_Combined;
%     DSI_Diff = cfRoi.PEye.DSI_Diff(:,1); % only care about left and right.
%     
%     DSI_Diff(DSI_Diff > 1) = 1;
%     DSI_Diff(DSI_Diff < -1) = -1;
%     % only plotted the progressive/regressive guys and totally fogot about
%     % those who are not in this category....
%     DSI_Diff_Plot = DSI_Diff(roiSelected & leftRightFlag);
%     LDSI_Plot = LDSI_Prefered(roiSelected & leftRightFlag);
%     
%     % if
%     %     MakeFigure;
%     % %     subplot(2,2,1);
%     %     scatter(DSI_Diff_Plot,LDSI_Plot,'r+','lineWidth',10);
%     %     axis([-1,1,-1,1]);
%     %     xlabel(['(',dirTypeStrEye{1} ,'-',dirTypeStrEye{2},')']);
%     %     ylabel(['(',contrastTypeStr{1},'-' , contrastTypeStr{2}, ')']);
%     %     title('DSI SquareWave');
%     %     ConfAxis;
%     %     axis equal
%     MakeFigure;
%     subplot(2,2,1);
%     DSI_Edge = cfRoi.PEye.DSI_Edge;
%     DSI_Edge_Plot = DSI_Edge(roiSelected & leftRightFlag);
%     scatter(DSI_Edge_Plot,LDSI_Plot,'r+','lineWidth',10);
%     axis([-1,1,-1,1]);
%     xlabel(['(',dirTypeStrEye{1} ,'-',dirTypeStrEye{2},')']);
%     ylabel(['(',contrastTypeStr{1},'-' , contrastTypeStr{2}, ')']);
%     title('DSI Edge');
%     ConfAxis;
%     axis equal
%     
%     subplot(2,2,2);
%     hESI = histogram(LDSI_Plot);
%     hESI.BinWidth = 0.1;
%     hESI.FaceColor = [1,0,0];
%     view(90,-90);
%     ConfAxis;
%     xlabel('ESI');
%     xlim([-1,1]);
%     subplot(2,2,3)
%     hDSI = histogram(DSI_Edge_Plot);
%     hDSI.BinWidth = 0.1;
%     hDSI.FaceColor = [1,0,0];
%     xlabel('DSI');
%     xlim([-1,1]);
%     ConfAxis;
%     if saveFigFlag
%         MySaveFig_Juyue(gcf,MainName,'_d_DSIESI','nFigSave',3,'fileType',{'jpeg','eps','tiff'});
%     end
% end

if metaAnalysis_flag
    edgeTypesStrEye = {'Progressive Light','Regressive Light','Progressive Dark','Regressive Dark','Progressive','Regressive','Up','Down'};
    dirTypeStrEye = {'Progressive','Regressive','Up','Down'};
    
    metaAnalysis_SquareEdgeResponse(cfRoi.PEye.value,roiSelected,edgeTypesStrEye,dirTypeStrEye);
end









