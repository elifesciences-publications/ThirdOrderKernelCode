function combModel = GenSpeedModel(twIn,varargin)
    colormap_gen;
	TF = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32 48 64];
    % this takes all the data in varargin, makes power maps out of it, and
    % then linearly combines each power map and fits it to the last map

    for ii = 1:nargin-1
        figLeg{ii} = inputname(ii+1);
    end
    
    % tw is a variable that determines whether the corresponding map is
    % turning or walking data. If this array is too small, assume the data
    % is for walking
    tw = cell(length(varargin),1);
    tw = cellfun(@(x){2},tw); % initialize cell array to assume walking data
    
    for in = 1:length(twIn)
        tw{in} = twIn(in);
    end
    
    numMaps = length(varargin);
    lineColors = lines(numMaps);
    lambda = cell(numMaps,1);
    
    respMap = cell(numMaps,1);
    respMapSEM = cell(numMaps,1);
    respMax = cell(numMaps,1);
    respMaxSEM = cell(numMaps,1);
    respScale = cell(numMaps,1);
    respScaleSEM = cell(numMaps,1);

    % input data from the maps. we'll mainly be using respMap but I got all
    % the maximum data too for fun
    for mm = 1:numMaps
        respMap{mm} = varargin{mm}.powerMap(:,:,tw{mm});
        respMapSEM{mm} = varargin{mm}.powerMapSem(:,:,tw{mm});
        
        lambda{mm} = varargin{mm}.lambda;
    end

    % fit matrix is going to have all the values from the resp matricies
    % input, in the form [ones map1 map2 map3 ... mapn] needs a constant
    % vector (ones) for optimal fitting
    % start with column of ones
    fitMat = ones(size(respMap{1}(:)));
%     fitMatSEM = ones(size(respMap{1}(:)));
    
    % add columns of all other maps except for last map. This is the map we
    % are fitting to
    for mm = 1:numMaps-1
        fitMat = [fitMat respMap{mm}(:)];
%         fitMatSEM = [fitMatSEM respMapSEM{mm}(:)];
    end
    
    % perform the fit and weight it with the last maps SEM
    fits = lscov(fitMat,respMap{end}(:),1./respMapSEM{end}(:).^2);
    
    % combModel is the model prediction from weighting the inputs
    % start with the offset (fits(1))
    combModel = fits(1)*ones(size(respMap{1}));
    
    % add weighted versions of the other matricies
    for mm = 1:numMaps-1
        combModel = combModel + fits(mm+1)*respMap{mm};
    end
    
    combModel = reshape(combModel,size(respMap{end}));
    
    disp(fits);
    
    MakeFigure;
    interpRes = 1;
    for mm = 1:numMaps
        subplot(ceil((numMaps+2)/3),3,mm);
        
        [x,y] = meshgrid(1:length(lambda{mm}),1:17);
        [xInt,yInt] = meshgrid(1:interpRes:length(lambda{mm}),1:interpRes:17);
        intMap = interp2(x,y,respMap{mm},xInt,yInt);
        
        imagesc(log(1./lambda{mm}),log(TF(end:-1:1)),intMap);
        hold on;
        contour(log(1./lambda{mm}),log(TF(end:-1:1)),intMap,10,'k');
        hold off;
        
        colormap(mymap);
        if tw{mm} == 2
            caxis([0 2]);
        else
            caxis([-60 60]);
        end
        
        ConfAxis('tickX',log(1./lambda{mm}),'tickLabelX',lambda{mm},'tickY',log(TF(1:2:end)),'tickLabelY',TF(end:-2:1))
        title(figLeg{mm});
        xlabel('log lambda (degrees)','interpreter','none');
        ylabel('log temporal frequency (Hz)','interpreter','none')
    end
    
    %% plot combined model
    subplot(ceil((numMaps+2)/3),3,numMaps+1);

    imagesc(log(1./lambda{1}),log(TF(end:-1:1)),combModel);
    hold on;
    contour(log(1./lambda{1}),log(TF(end:-1:1)),combModel,10,'k');
    hold off;
    
    colormap(mymap);
    caxis([0 2]);
    
    ConfAxis('tickX',log(1./lambda{1}),'tickLabelX',lambda{1},'tickY',log(TF(1:2:end)),'tickLabelY',TF(end:-2:1))
    title('combined model');
    xlabel('log lambda (degrees)','interpreter','none');
    ylabel('log temporal frequency (Hz)','interpreter','none')
    
    %% plot difference from desired
    subplot(ceil((numMaps+2)/3),3,numMaps+2);

    intMap = interp2(x,y,respMap{end},xInt,yInt);
    
    imagesc(log(1./lambda{1}),log(TF(end:-1:1)),intMap-combModel);
    hold on;
    contour(log(1./lambda{1}),log(TF(end:-1:1)),intMap-combModel,10,'k');
    hold off;
    
    colormap(mymap);
    %caxis([-0.5 0.5]);
    colorbar;
    ConfAxis('tickX',log(1./lambda{1}),'tickLabelX',lambda{1},'tickY',log(TF(1:2:end)),'tickLabelY',TF(end:-2:1))
    title('diff');
    xlabel('log lambda (degrees)','interpreter','none');
    ylabel('log temporal frequency (Hz)','interpreter','none')
    
    polyOrder = 6;
    combModelMax = zeros(size(respMap{end},2),2);
    fitLength = 100;
    fitX = linspace(-2,6,fitLength)';
    fitX = log(2.^fitX);
    for ii = 1:size(respMap{end},2)
        [coefFit,S] = polyfit(log(TF)',combModel(:,ii),polyOrder);
        fitTrace = polyval(coefFit,fitX,S);
        [~,minInd] = min(fitTrace);
        combModelMax(ii,1) = exp(fitX(minInd));
        combModelMax(ii,2) = exp(fitX(minInd))*lambda{end}(ii);
    end
    
    scatter(combModelMax(:,1),combModelMax(:,2));
end