function R = ReichardtModel(xtPlot)
    % There are around 270/5.1 = 53 ommatidia that see the stimulus, and
    % therefor 53 reichardt correlators
    numReich = 53;
    filtOut = 1;
    disp = 1;

    sizeX = size(xtPlot,2);
    sizeT = size(xtPlot,1);
    
    % gid rid of the part of the stim behind the fly
    xtPlot = xtPlot(:,sizeX/8+1:sizeX-sizeX/8);
    sizeX = 3/4*sizeX;
    % make a matrix of how the stim looks through the receptor eyes over
    % time
%     recVis = zeros(sizeT,numReich);
%     
%     recSpace = 5.1; % spacing between receptors in degrees
%     spatFilMean = (0:numReich-1)*recSpace+recSpace/2;
%     spatFilSTD = 5.7/(2*sqrt(2*log(2))); % std of gaussian spatial filter
%     
%     % delay should be about 11 ms;
% 
%     tempFilTau = 12;
%     tempFil = (1:sizeT).*exp(-(1:sizeT)/tempFilTau);
%     tempFil = tempFil/sum(tempFil);
%     smallTau = 4;
%     
%     smallFil = (1:sizeT).*exp(-(1:sizeT)/smallTau);
%     smallFil = smallFil/sum(smallFil);
% 
%     spatFil = zeros(sizeX,numReich);
%     for ii = 1:numReich
%         spatFil(:,ii) = normpdf(1:sizeX,spatFilMean(ii),spatFilSTD);
%         
%         for jj = 1:sizeT
%             recVis(jj,ii) = sum(spatFil(:,ii).*xtPlot(jj,:)');
%         end
%     end
%     
%     recVisDelay = filter(tempFil,1,recVis);
%     recVis = filter(smallFil,1,recVis);
%     
%     reichSignalL = recVisDelay(:,1:end-disp).*recVis(:,1+disp:end);
%     reichSignalR = recVis(:,1:end-disp).*recVisDelay(:,1+disp:end);
%     
%     reichSignalSub = reichSignalL - reichSignalR;
%     
%     reichTime = mean(reichSignalSub,2);
%     reichTimeAbs = mean(abs(reichSignalSub),2);
%     
%     if filtOut
%         time = 300;
%         behavFil = normpdf(linspace(-time/2,100,time/2),0,time/6);
%         
%         reichTimeSmoothed = filter(behavFil,1,reichTime);
%         reichTimeAbsSmoothed = filter(behavFil,1,reichTimeAbs);
%         stdResp = filter(behavFil,1,reichTimeAbs.^2)-filter(behavFil,1,reichTimeAbs).^2;
%     end
% 
% %     makeFigure;
% %     plot(mean(abs(reichSignalL) - abs(reichSignalR),2));
% %     xlabel('abs arms then subtracted');
% %     makeFigure;
% %     plot(mean(abs(reichSignalL) + abs(reichSignalR),2));
% %     xlabel('abs arms added subtracted');
% %     makeFigure;
% %     plot(mean(reichSignalL + reichSignalR,2));
% %     xlabel('arms added');makeFigure;
%     makeFigure;
%     plot(reichTime);
%     xlabel('after subtraction');
%     makeFigure;
%     plot(reichTimeAbs);
%     xlabel('after subtaction abs');
%     makeFigure;
%     plot(reichTimeSmoothed);
%     xlabel('after subtraction smoothed');
%     makeFigure;
%     plot(reichTimeAbsSmoothed);
%     xlabel('after subtraction abs smoothed');
%     makeFigure;
%     plot(stdResp);
%     xlabel('after subtraction abs std');
%     
    makeFigure;
    plotHeat(xtPlot,'','');
    confAxis('tickY',1:10:size(xtPlot,1),'tickLabelY',1:10:size(xtPlot,1),'tickX',1:size(xtPlot,2),'tickLabelX',1:size(xtPlot,2));
    colormap('Gray');
%     makeFigure;
%     plotHeat(recVis,'','');
%     confAxis('tickY',1:10:size(recVis,1),'tickLabelY',1:10:size(recVis,1),'tickX',1:size(recVis,2),'tickLabelX',1:size(recVis,2));
%     colormap('Gray');
%     makeFigure;
%     plotHeat(recVisDelay,'','');
%     confAxis('tickY',1:10:size(recVisDelay,1),'tickLabelY',1:10:size(recVisDelay,1),'tickX',1:size(recVisDelay,2),'tickLabelX',1:size(recVisDelay,2));
%     colormap('Gray');
%     
%     R.reichTime = reichTime;
%     R.reichTimeAbs = reichTimeAbs;
    R.xtPlot = xtPlot;
%     R.recVis = recVis;
%     R.recVisDelay = recVisDelay;
end