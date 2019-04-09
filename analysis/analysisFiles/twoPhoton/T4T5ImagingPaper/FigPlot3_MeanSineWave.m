function FigPlot3_MeanSineWave(roiData,varargin)
nFigSave = 3;
figFileType = {'fig','eps','png'};

nMultiBars = 20;
saveFigFlag = false;
MainName = 'Fig3';
barWidth = roiData{1}.stimInfo.barWidth;
dx = 1; % you might need both...
aveBy = 'Fly';


omega = roiData{1}.simu.sK.sine.stim.omega';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% there are four types, each four types, you need at least four rois.
% first, collect all the glider response.
nRoi = length(roiData);
kernelType = zeros(nRoi,1);
edgeType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end

nType = 4;

numStat = roiAnalysis_FlyRoiKernelStat(roiData);
switch aveBy
    case 'fly'
        [sineResp,nNorm] = roiAnalysis_AverageFunction_OverFly(roiData,'dx',dx,'whichValue','sinewave');
    case 'roi'
        [sineResp,nNorm] = roiAnalysis_AverageFunction_OverRoi(roiData,'dx',dx,'whichValue','sinewave');
    case 'kernel'
        [sineResp,nNorm] = roiAnalyis_AverageFuncion_OverKernel(roiData,'dx',dx,'whichValue','sinewave');
end
% prepare to plot response
titleStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};

for tt = 1:1:nType
    if nNorm == 0
        disp('no roi for this type : ',num2str(tt));
    else
        
        meanSineResp = mean(sineResp{tt},2);
        stdSineResp  = std(sineResp{tt},1,2);
        semSineResp = stdSineResp./sqrt(nNorm(tt));
        
        
        MakeFigure;
        subplot(2,2,1)
        PlotXY_Juyue(omega,meanSineResp,'errorBarFlag',true,'sem',semSineResp);
        subplot(2,2,2)
        PlotXY_Juyue(omega,semSineResp);
        subplot(2,1,2)
        plot(omega,sineResp{tt},'color',[0.5,0.5,0.5]);
        hold on
        plot(omega,meanSineResp,'color',[1,0,0]);
        hold off
        title(titleStr{tt});
        
        if saveFigFlag
            secondaryName = ['sinewave',num2str(barWidth),'_DX',num2str(dx),'_',titleStr{tt},'_aveBy',aveBy];
            MySaveFig_Juyue(gcf,MainName, secondaryName ,'nFigSave',nFigSave,'fileType',figFileType);
        end
    end
end

%%
% average over kernels....
% gliderResp = cell(nType,1);
% for tt = 1:1:nType
%     gliderResp{tt} = [];
%     roiUse = find(edgeType == tt & kernelType > 1);
%     nRoiUse = length(roiUse);
%     if nRoiUse == 0
%         disp('no roi for this type : ',num2str(tt));
%     else
%         for ii = 1:1:nRoiUse
%             roi = roiData{roiUse(ii)};
%             switch dx
%                 case 1
%                     [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,1,'glider');
%                 case 2
%                     [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,2,'glider');
%                 case 0
%                     [resp1,barUse1] = roiAnalysis_OneRoi_GetSimuResult(roi,1,'glider');
%                     [resp2,barUse2] = roiAnalysis_OneRoi_GetSimuResult(roi,2,'glider');
%                     resp = [resp1,resp2];
%                     barUse = [barUse1;barUse2 + 20];
%             end
%             % why there is zeros?
%             if find(resp(:,barUse) == 0)
%                 keyboard
%             end
%             gliderResp{tt} = cat(2,gliderResp{tt},resp(:,barUse));
%         end
%     end
% end

