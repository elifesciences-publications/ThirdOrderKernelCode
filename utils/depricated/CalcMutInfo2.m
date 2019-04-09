function calcMutInfo2(TW,varargin)
    
    colormap_gen; % this generates a color map that goes from blue to white to red
    
    figLeg = cell(nargin-1,1); % initialize a cell array for figure legends
    for ii = 1:nargin-1
        figLeg{ii} = inputname(ii+1); % set the figure legend to the input variable names
    end
    
    % the standard TF range I test. Consider making this an optional input variable
    TF = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32 48 64]';
    TF = TF(1:size(varargin{1}{1}.pTraces,1));
    numTF = length(TF);







    numMaps = length(varargin);
    lambda = [120 90 60 45 30 22.5];
    resp = [];
    velX = [];
    tfX = [];
    
    
    for mm = 1:numMaps
        for la = 1:length(lambda)
            snipMat = varargin{mm}{la}.GS.snipMat;
            numEpochs = size(snipMat,1)-2;
            numFlies = size(snipMat,2);

            trials = cell(size(snipMat));

            for ff = 1:numFlies
                for ee = 1:numEpochs
                    trials{ee,ff} = mean(snipMat{ee+2,ff}(:,:,TW))';
                    resp = [resp; trials{ee,ff}];
                    tfX = [tfX; ones(size(trials{ee,ff}))*TF(ee)];
                    velX = [velX; ones(size(trials{ee,ff}))*TF(ee)*lambda(la)];
                end
            end
        end
    end
    
    abHeight = 1;
    cHeight = 3;
    sideSize = abHeight + cHeight;
    [subA,subB,subC] = makeProj(abHeight,cHeight);
    
    % plot joint probability distribution for TF
    makeFigure;
    subplot(sideSize,sideSize,subA);
    hist(log(tfX),50);
    confAxis('tickX',log(TF(1:2:end)),'tickLabelX',TF(1:2:end));

    subplot(sideSize,sideSize,subB);
    hist(resp,50);
    view(-90,90);
    
    subplot(sideSize,sideSize,subC);
    pXYtf = ndhist(log(tfX),resp);
    imagesc(log(TF(1:2:end)),[max(resp) min(resp)],pXYtf);
    confAxis('tickX',log(TF(1:2:end)),'tickLabelX',TF(1:2:end));
    xlabel('temporal frequency');
%     colorbar;
    
    % plot joint porbability distribution for Vel
    makeFigure;
    subplot(sideSize,sideSize,subA);
    hist(log(velX),50);
    confAxis('tickX',log(TF(1:2:end)*lambda(1)),'tickLabelX',TF(1:2:end)*lambda(1));
    
    subplot(sideSize,sideSize,subB);
    hist(resp,50);
    view(-90,90);
    
    subplot(sideSize,sideSize,subC);
    pXYvel = ndhist(log(velX),resp);
    imagesc(log(TF(1:2:end)*lambda(1)),[max(resp) min(resp)],pXYvel);
    confAxis('tickX',log(TF(1:2:end)*lambda(1)),'tickLabelX',TF(1:2:end)*lambda(1));
    xlabel('velocity');
%     colorbar;

    totalReads = sum(sum(pXYtf));
    pX = sum(pXYtf,1)./totalReads;
    pY = sum(pXYtf,2)./totalReads;
    pXYtf = pXYtf./totalReads;
    mutInfo = nansum(nansum(pXYtf.*log(pXYtf./(pY*pX))/log(2)))
    
    totalReads = sum(sum(pXYvel));
    pX = sum(pXYvel,1)./totalReads;
    pY = sum(pXYvel,2)./totalReads;
    pXYvel = pXYvel./totalReads;
    mutInfo = nansum(nansum(pXYvel.*log(pXYvel./(pY*pX))/log(2)))
end