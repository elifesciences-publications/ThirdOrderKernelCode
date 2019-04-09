function FigPlot1_cosine(Z,flyEye,varargin)
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

metaAnalysis_flag = false;

for ii = 1:2:length(varargin)
    str = [ varargin{ii} ' = varargin {' num2str(ii+1) '};'];
    eval(str);
end

if saveFigFlag
    mainName = [Z.params.name,'roiSelect',num2str(roiSelectionFlag)];
end
dirTypeColorRGB = zeros(4,3);
% there will be four colors for four different layers.
% up/down/progressive/regressive.
dirTypeColorRGB(1,:) = [1,0,0]; % black % progressive.
dirTypeColorRGB(2,:) = [0,0,1]; % white % regressive.

dirTypeColorRGB(1,:) = [0,1,0]; % black % progressive.
dirTypeColorRGB(2,:) = [0,1,1]; % white % regressive.

DarkLightColor = zeros(2,3);
DarkLightColor(1,:) = [1,0,0]; % red;
DarkLightColor(2,:) = [0,0,1]; % blue;

edgeTypeColorRGB = zeros(4,3);
edgeTypeColorRGB(1,:) = [1,0,0]; % red(light), left/progressive
edgeTypeColorRGB(2,:) = [1,0,1]; % megenda(light), right/regressive
edgeTypeColorRGB(3,:) = [0,0,1]; % blue(dark), left/progressive
edgeTypeColorRGB(4,:) = [0,1,0]; % green(dark), right/regressive;

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
[cfRoi,roiTrace] = RoiClassification(Z,flyEye);



%% Start Plotting....
%% first, use square waves to plot out the four layers...
roiSquareType = cfRoi.PEye.dirType;
if ~roiSelectionFlag
    roiSelected = true(nRoi,1);
end

if fig1_b_Flag
    MakeFigure
    colormap(gray(256));
    imagesc(roiImage);
    axis off
    hold on
    for rr = 1:1:nRoi
        roiBoundaries = bwboundaries(roiMasks(:,:,rr),8,'noholes');
        type = roiSquareType(rr);
        if type == 1 || type == 2
            if roiSelected(rr)
                plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',5,'color',dirTypeColorRGB(type,:));
            end
%             legend('progressive','regressive');
        end
    end
    hold off
    ConfAxis;
    
    imageDescriptionPath = fullfile(Z.params.filename,'imageDescription.mat');
    imageDescription = load(imageDescriptionPath);
    imageDescription = imageDescription.state;
    dataRate = imageDescription.acq.frameRate; % imaging frequency
    zoomLevel = imageDescription.acq.zoomFactor;
    PixelPerMicron = zoomLevel * 0.4;
    pixelPerScale = round(5 * PixelPerMicron); % nm...
     
    startY = round(0.9 * length(verInd));
    endY = startY ;
    endX = round(0.9 * length(horInd));
    startX  = endX -  pixelPerScale;
    hold on
    line([startX,endX],[startY,endY], 'LineWidth',10,'color',[0,0,0]);
    
    if saveFigFlag
        FigPlot1_SaveFigure(gcf,mainName ,'fourLayer');
        % save the data, by type, name, number and name
    end
end

if fig1_c_Flag
    % reorganize the function, so that you can plot the mean image and roi
    % at any point you want?
    % might be too trouble some for now. Let me do it later on...
    MakeFigure
    colormap(gray(256));
    imagesc(roiImage);
    axis off
    hold on
    contrastType = cfRoi.PEye.contrastType;
    leftRightFlag = cfRoi.PEye.leftRightFlag;
    edgeType = cfRoi.PEye.edgeType;
    % try to show the first two T4 and T5....
    firstT4 = find(contrastType == 1 & roiSelected & leftRightFlag);
    firstT4 = firstT4(1);
    firstT5 = find(contrastType == 2 & roiSelected & leftRightFlag);
    firstT5 = firstT5(1);
    first2 = [firstT4,firstT5];
    for ii = 1:1:2
        rr = first2(ii);
        roiBoundaries = bwboundaries(roiMasks(:,:,rr),8,'noholes');
        % determine whether it is left/right selective...
        type = contrastType(rr);
        %     type = edgeType(rr);
        if roiSelected(rr) && leftRightFlag(rr)
            
            plot(roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',2,'color',DarkLightColor(type,:));
            
        end
    end
    for rr = 1:1:nRoi
        roiBoundaries = bwboundaries(roiMasks(:,:,rr),8,'noholes');
        % determine whether it is left/right selective...
        type = contrastType(rr);
        %     type = edgeType(rr);
        if roiSelected(rr) && leftRightFlag(rr)
            
            plot(roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',2,'color',DarkLightColor(type,:));
            
        end
%         legend('T4','T5');
    end
    ConfAxis;
   %     line
    
    
    
    % plot the scale bar and color bar...
    % 0.4
    %% MakeFigure;
    %roiSelection based on cfRoi....
    % once you get some roi, select the best 4 of them to do analysis....
    % roiSelectedCorrPeakConsist = RoiSelectionByProbingStimulus(cfRoi,'method','CorrPeakConsistency','classInterested',1);
    % roiSelected = roiSelectedCorrPeakConsist;
    roiUse = find(roiSelected & leftRightFlag);
    
    % first, plot the trace for this roi,
    nRoiUse = length(roiUse);
    bestRoi = zeros(4,1);
    bestRoiESI = zeros(4,1);
    bestRoiCC = zeros(4,1);
    bestESI_CC = zeros(4,1);
    % %
    for ii = 1:1:nRoiUse
        rr = roiUse(ii);
        type = cfRoi.PEye.edgeType(rr);
        % ESI is not the best thing, use correlation between two.
        %        cc = cfRoi.CCEye.value(rr,type);
        ESI = cfRoi.PEye.ESI(rr,type);
        
        %        if cc > bestRoiCC(type)
        %          bestRoi(type) = rr;
        %          bestRoiCC(type) = cc;
        %         end
        if ESI >  bestRoiESI(type)
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
            % instead using text, using &
            plot(centerOfMass(2), centerOfMass(1),'*','Color',[1,1,1]);
            %             text(centerOfMass(2), centerOfMass(1), num2str(rr), 'HorizontalAlignment', 'center', 'Color', [1,1,1]);
            
        end
        
    end
    hold off
    ConfAxis;
end
 hold on
    line([startX,endX],[startY,endY], 'LineWidth',10,'color',[0,0,0]);
    
%% plot trace
if fig1_trace_Flag
    MakeFigure;
    for tt = 1:1:4
        if roiTypeExistFlag(tt)
            rr = bestRoi(tt);
            allTrace = roiTrace.eye.indiVidualTrace{rr};
            corrValue = cfRoi.CCEye.value(rr,1:4);
            name = cfRoi.PEye.edgeName(rr);
            subplot(2,2,tt)
            % it needs Xlabel and Y Label As well.
            %     PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','titleStr',name,'colorBank',edgeTypeColorRGB);
            
            PlotTrace_ProbingStimulus(allTrace,'traceToDraw','meanTrace','coordinates','eye','legendLabel','typeOnly','legendValue',[],'titleStr',name,'colorBank',edgeTypeColorRGB);
            
        end
    end
    
    if saveFigFlag
        FigPlot1_SaveFigure(gcf,mainName ,'trace');
        % save the data, by type, name, number and name
    end
end


end



