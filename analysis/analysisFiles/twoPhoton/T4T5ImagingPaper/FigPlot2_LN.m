function roiData  = FigPlot2_LN(roiData,varargin)
saveFigFlag = false;
MainName = 'Fig2';
nFigSave = 3;
figFileType = {'fig','eps','png'};
barWidth = roiData{1}.stimInfo.barWidth;
titleStr ={'Progressive T4','Regressive T4','Progressive T5','Regressive T5'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nRoi = length(roiData);
% if ~isfield(roiData{1},'LM')
%     for rr = 1:1:nRoi
%         roiData{rr} = roiAnalysis_OneRoi_LN_OLS(roiData{rr});
%     end
% end
edgeType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
end
% Plot the Non-linearity
MakeFigure;
[~,edgeTypeColorRGB,~] = FigPlot1ColorCode();
subplotNum = [1,2,3,4];
nBins = 30;
nOneBin = 50;
predRespAll = cell(4,1);
respAll = cell(4,1);
predMean = cell(4,1);
respMean = cell(4,1);
% this is not averaged over fly, write a code to make it average over
% fly. you just create a bin...
for tt = 1:1:4
    roiUse = find(edgeType == tt);
    nRoiPlot = length(roiUse);
    if nRoiPlot == 0
        disp('bad luck, no filter is good for this roi');
    else
        predRespAll{tt} = zeros(nBins + 2,nRoiPlot);
        respAll{tt} = zeros(nBins + 2,nRoiPlot);
        % plot the LN for this guy, all of them...only for the one that are
        % showed... four of them. not all of them.
        for ii = 1:1:nRoiPlot
            rr = roiUse(ii);
            subplot(2,2,subplotNum(tt));
            % you have to label what is the name of those roi...
            name = roiData{rr}.typeInfo.edgeName;
            
%             predResp = roiData{rr}.LN.predResp;
%             resp = roiData{rr}.LN.resp;
            predResp =  roiData{rr}.LM.firstOrder.predRespNonRep;
            resp = roiData{rr}.LM.firstOrder.respNonRep;
            
            [x_,y_,n] = BinXY_FixedBinValue(predResp,resp,'x',nBins);
            x_Plot = x_(n > nOneBin);
            y_Plot = y_(n > nOneBin);
            FigPlot2_OneLN(x_Plot,y_Plot,'color',[0.5,0.5,0.5],'lineWidth',1);
            %             ConfAxis;
            %             PlotLNModel(predResp,resp,'color',[0.5,0.5,0.5],'lineWidth',1,'markerType','.','titleFlag',false,'plotMethod','line','setAxisLimFlag',0,'plotDashLineFlag',0);
            hold on
            x_(n <= nOneBin) = NaN;
            y_(n <= nOneBin) = NaN;
            
            predRespAll{tt}(:,ii) = x_;
            respAll{tt}(:,ii) = y_;
            % for the average response. you have to plot the nonlinearity
            % in a different way.....
        end
        % how do you calcualte mean?
        [predMean{tt},respMean{tt}] = FigPlot2_MyNanMean(predRespAll{tt},respAll{tt});
        % how do plot that error bar?
        FigPlot2_OneLN(predMean{tt},respMean{tt},'color',edgeTypeColorRGB(tt,:),'lineWidth',1);
        %         ConfAxis;
        title(name);
    end
end

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,'_b_LN','nFigSave',nFigSave,'fileType',figFileType);
end

end