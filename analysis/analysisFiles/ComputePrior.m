function D = ComputePrior(varargin)
    %reads in the data and cuts out snips around the given epochs and sums
    %them together then plots the average response to each epoch
    
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = [];
    suppressOut = 0;
    combType = 'mean';
    %figLeg = {'0.0 contrast noise' '0.1 contrast noise' '0.2 contrast noise' '0.3 contrast noise'  '0.4 contrast noise'};
    stand = [0 log([15 30 60 120 240 480])]';
    calcType = 1;
    numIgnore = 4;
    SV = [4 5];
    xLabel = 'log velocity';
    tickLabelX = [];
    blacklist = [];
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if exist('dataPath','var')
        D = grabData(dataPath,blacklist);
    else
        D = grabData();
    end

    stand = stand(:);
    %% perform analysis
    
    analysis.OD = organizeData(D,varargin{:});
    analysis.GS = grabSnips(analysis.OD,D.data.params,varargin{:});
    
    %get rid of the numIgnore points (controls or 0 and you don't want
    %log(0)
    analysis.GS.snipMat = analysis.GS.snipMat(numIgnore+1:end,:);
    analysis.GS.comb = analysis.GS.comb(numIgnore+1:end,:);
    analysis.GS.numEpochs = analysis.GS.numEpochs - numIgnore;
    stand = stand(floor(numIgnore/4)+1:end);
    
    analysis.CR = combineInput(analysis.GS.comb,1);
    analysis.CD = combineDuplicates(analysis.CR.combResp,1);
    
    D.analysis = analysis;
    

    % pull out the responses at low noise
    flyResp = analysis.CD.combDup(1:2:end);
    % pull out the responses at high noise
    flyRespwNoise = analysis.CD.combDup(2:2:end);
    
    switch calcType
        case 1
        % use these variables to calculate the percentage of flies that saw
        % the standard stimulus as faster than the test stimulus.
        % percentGreater compares the standard (no noise) stimulus to itself and
        % percentGreater.withNoise.mean compares the standard to the test
        percentGreater.noNoise.mean = zeros(analysis.CD.numEpochs/2);
        percentGreater.withNoise.mean = zeros(analysis.CD.numEpochs/2);
        for ii = 1:analysis.CD.numEpochs/2
            for jj = 1:analysis.CD.numEpochs/2
                % number of flies that saw a>b divided by total number of
                % flies
                percentGreater.noNoise.mean(jj,ii) = sum(flyResp{ii}(:,:,1)<flyResp{jj}(:,:,1))/analysis.CD.numFlies;
                percentGreater.withNoise.mean(jj,ii) = sum(flyResp{jj}(:,:,1)>flyRespwNoise{ii}(:,:,1))/analysis.CD.numFlies;
            end
        end

        % for the standard to standard comparison get rid of the diaganol
        % because each fly compares its perception of a velocity to that
        % perception so its useless to ask is a>a
        percentGreater.noNoise.mean(logical(eye(analysis.CD.numEpochs/2))) = [];
        % removing the diagonal makes the matrix lose its shape. reshape
        percentGreater.noNoise.mean = reshape(percentGreater.noNoise.mean,[analysis.CD.numEpochs/2-1,analysis.CD.numEpochs/2]);

        % repmat the list of velocities tested (stand) and remove those
        % that are not tested (the same diagonal as before)
        velMat = repmat(stand,[1 analysis.CD.numEpochs/2]);
        velMat(logical(eye(analysis.CD.numEpochs/2))) = [];
        velMat = reshape(velMat,[analysis.CD.numEpochs/2-1,analysis.CD.numEpochs/2]);

        % create a variable to hold the fitted mean and STD of the fitted
        % gaussian CDF
        meanSTDCDFnoNoise = zeros(size(percentGreater.noNoise.mean,2),2);
        meanSTDCDFwNoise = zeros(size(percentGreater.withNoise.mean,2),2);

        %compute liklihood mean note that posterior and liklihood are expected
        %to have the same std
        logPostSlope = (meanSTDCDFnoNoise(:,1)-meanSTDCDFwNoise(:,1))./(meanSTDCDFnoNoise(:,2).^2-meanSTDCDFwNoise(:,2).^2);
        likeMean = meanSTDCDFnoNoise(:,1)-logPostSlope.*meanSTDCDFnoNoise(:,2).^2;
        prior = [];
        for ii = 1:size(stand,1)
            x = stand(ii)-log(2)/2:0.05:stand(ii)+log(2)/2;
            prior = [prior exp(logPostSlope(ii)*x)];
        end

        percentGreater.noNoise.sem = zeros(size(percentGreater.noNoise.mean));
        percentGreater.withNoise.sem = zeros(size(percentGreater.withNoise.mean));
        
        prior = prior./(7*mean(prior));
    case 2
        % create a variable to hold the average over time response to each trial
        eachFlyTrialResp = cell(analysis.GS.numEpochs/2,analysis.GS.numFlies);
    
        %average each trial over time to get a mean response for that trial
        for ii = 1:2:analysis.GS.numEpochs
            for jj = 1:analysis.GS.numFlies
                %combine the negatives of each trial here
                eachFlyTrialResp{(ii+1)/2,jj} = mean([analysis.GS.snipMat{ii,jj} -1*analysis.GS.snipMat{ii+1,jj}],1);
                eachFlyTrialResp{(ii+1)/2,jj} = eachFlyTrialResp{(ii+1)/2,jj}(:,:,1);
            end
        end

        %make a histogram of each response to each trial
        numBins = 200;
        maxResp = max(max(cellfun(@max,eachFlyTrialResp)));
        minResp = min(min(cellfun(@min,eachFlyTrialResp)));
        histEdge = linspace(minResp,maxResp,numBins);
        histTrialResp = cell(analysis.GS.numEpochs/2,analysis.GS.numFlies);
        probEpochResp = cell(analysis.GS.numEpochs/2,analysis.GS.numFlies);
        cumEpochResp = cell(analysis.GS.numEpochs/2,analysis.GS.numFlies);

        % turn that histogram into a cumulative distribution
        for ii = 1:analysis.GS.numEpochs/2
            for jj = 1:analysis.GS.numFlies
                histTrialResp{ii,jj} = histc(eachFlyTrialResp{ii,jj},histEdge);
                probEpochResp{ii,jj} = histTrialResp{ii,jj}./sum(histTrialResp{ii,jj});
                cumEpochResp{ii,jj} = cumsum(probEpochResp{ii,jj});
            end
        end

        % using these curves you can calculate the probability  that one curve
        % is greater than the other. Given probability distributions a and b,
        % and their corresponding cumulative distributions ac and bc
        % p(b>a) = sum(a*(1-bc))

        % compare standard curve (odds) to test curves w noise (evens)
        % grab standard and arange from -480 to -15 to 15 to 480
        standProb = probEpochResp(1:2:end,:);
        standCum = cumEpochResp(1:2:end,:);
        testProb = probEpochResp(2:2:end,:);

        % make a matrix where columns are test stimuli and rows are standard
        % stimuli. values in the matrix are p(standard>test)
        % make another matrix where you combine the standard to itself,
        % basically how good are flies at telling apart non noisy stimuli
        testToStand = zeros(analysis.GS.numEpochs/4,analysis.GS.numEpochs/4,analysis.GS.numFlies);
        standToStand = zeros(analysis.GS.numEpochs/4,analysis.GS.numEpochs/4,analysis.GS.numFlies);

        for ff = 1:analysis.GS.numFlies
            for ii = 1:analysis.GS.numEpochs/4
                for jj = 1:analysis.GS.numEpochs/4
                    % add 1/2*prob(a = b) to pretend curves are continuous
                    testToStand(jj,ii,ff) = sum(testProb{ii,ff}.*(1-standCum{jj,ff}))+0.5*sum(testProb{ii,ff}.*standProb{jj,ff});
                    standToStand(jj,ii,ff) = sum(standProb{ii,ff}.*(1-standCum{jj,ff}))+0.5*sum(standProb{ii,ff}.^2);
                end
            end
        end

        % repmat the list of velocities tested (stand)
        velMat = repmat(stand,[1 analysis.CD.numEpochs/2]);
        
        percentGreater.withNoise.mean = mean(testToStand,3);
        percentGreater.withNoise.std = std(testToStand,[],3);
        percentGreater.withNoise.sem = percentGreater.withNoise.std/size(testToStand,3);
        
        percentGreater.noNoise.mean = mean(standToStand,3);
        percentGreater.noNoise.std = std(standToStand,[],3);
        percentGreater.noNoise.sem = percentGreater.withNoise.std/size(standToStand,3);
    end
    
    meanSTDCDFnoNoise = zeros(size(percentGreater.noNoise.mean,2),2);
    meanSTDCDFwNoise = zeros(size(percentGreater.withNoise.mean,2),2);
    
    figLegend = {'no noise' 'no noise fit' 'with noise' 'with noise fit'};
    
    % for each column in velMat fit it to a gaussian CDF
    for ii = 1:size(percentGreater.noNoise.mean,2);
        x = velMat(:,ii);
        y = percentGreater.noNoise.mean(:,ii);
        ywNoise = percentGreater.withNoise.mean(:,ii);
        modelFun =  @(p,x) normcdf(x,p(1),p(2));
        startingVals = SV;
        meanSTDCDFnoNoise(ii,:) = nlinfit(x, y, modelFun, startingVals);
        meanSTDCDFwNoise(ii,:) = nlinfit(stand, ywNoise, modelFun, startingVals);
        modelX = linspace(min(stand),max(stand),50);
        
        continue;
        %plot log velocity vs percent reference stimuli is perceived as faster
        %scatter points of sinewave without noise psychometric function
        makeFigure; hold on;
        plotXvsY(x,y,xLabel,'% flies perceived reference velocity > test velocity','graphType','scatter','color',[0,0,1],'error',percentGreater.noNoise.sem(:,ii),varargin{:});
        %plot normcdf fit
        plotXvsY(modelX,modelFun(meanSTDCDFnoNoise(ii,:),modelX),xLabel,'% flies perceived reference velocity > test velocity','color',[0,0,1],varargin{:});

        %scatter points of sinewave with noise psychometric function
        plotXvsY(stand,ywNoise,xLabel,'% flies perceived reference velocity > test velocity','graphType','scatter','color',[0,0.5,0],'error',percentGreater.withNoise.sem(:,ii),varargin{:});
        %plot normcdf fit
        plotXvsY(modelX,modelFun(meanSTDCDFwNoise(ii,:),modelX),xLabel,'% flies perceived reference velocity > test velocity','color',[0,0.5,0],varargin{:});
        confAxis('tickX',stand,'tickLabelX',tickLabelX);
        legend(figLegend);
        hold off;
    end

    makeFigure; hold on;
    plotXvsY(stand,meanSTDCDFnoNoise(:,1),xLabel,'mean of fit CDF for V2>V1','graphType','scatter','color',[0 0 1],varargin{:});
    plotXvsY(stand,stand,xLabel,'log velocity','color',[0 0 1],varargin{:});
    %plot predicted velocity of sine waves with noise
    plotXvsY(stand,meanSTDCDFwNoise(:,1),xLabel,'mean of fit CDF for V2wNoise>V1','graphType','scatter','color',[0,0.5,0],varargin{:});
    confAxis('tickX',stand,'tickLabelX',tickLabelX);
    legend({'wo noise' 'X=Y' 'w noise'});
    hold off;
    
    makeFigure; hold on;
    %plot predicted STD as a function of actual velocity
    plotXvsY(stand,meanSTDCDFnoNoise(:,2),xLabel,'std of fit CDF for V2>V1','graphType','scatter',varargin{:},'color',[0 0 1]);
    plotXvsY(stand,meanSTDCDFwNoise(:,2),xLabel,'std of fit CDF for V2>V1','graphType','scatter',varargin{:},'color',[0,0.5,0]);
    confAxis('tickX',stand,'tickLabelX',tickLabelX);
    legend({'wo noise' 'w noise'});
    hold off;

    %% go through every single trial time trace, ask what the mean response
    % is at that timepoint for the fly, and what the STD between trials for
    % that fly is

    allTrialMeanTurn = cell(analysis.GS.numEpochs/2,1);
    allTrialSTDTurn = cell(analysis.GS.numEpochs/2,1);

    allTrialMeanWalk = cell(analysis.GS.numEpochs/2,1);
    allTrialSTDWalk = cell(analysis.GS.numEpochs/2,1);
    
    for ii = 1:2:analysis.GS.numEpochs
        turnPos = cell2mat(analysis.GS.snipMat(ii,:));
        walkPos = turnPos(:,:,2);
        turnPos = turnPos(:,:,1);
        
        turnNeg = cell2mat(analysis.GS.snipMat(ii+1,:));
        walkNeg = turnNeg(:,:,2);
        turnNeg = turnNeg(:,:,1);
        
        allTrialMeanTurn{(ii+1)/2} = mean([turnPos -1*turnNeg],2);
        allTrialSTDTurn{(ii+1)/2} = std([turnPos -1*turnNeg],[],2);

        allTrialMeanWalk{(ii+1)/2} = mean([walkPos walkNeg],2);
        allTrialSTDWalk{(ii+1)/2} = std([walkPos walkNeg],[],2);
    end

    allTurn.noNoise.mean = cell2mat(allTrialMeanTurn(1:2:end));
    allTurn.withNoise.mean = cell2mat(allTrialMeanTurn(2:2:end));

    allTurn.noNoise.STD = cell2mat(allTrialSTDTurn(1:2:end));
    allTurn.withNoise.STD = cell2mat(allTrialSTDTurn(2:2:end));

    allWalk.noNoise.mean = cell2mat(allTrialMeanWalk(1:2:end));
    allWalk.withNoise.mean = cell2mat(allTrialMeanWalk(2:2:end));

    allWalk.noNoise.STD = cell2mat(allTrialSTDWalk(1:2:end));
    allWalk.withNoise.STD = cell2mat(allTrialSTDWalk(2:2:end));

    % plot turning mean vs its std
    makeFigure; hold on;
    plotXvsY(allTurn.noNoise.mean,allTurn.noNoise.STD,[],[],'graphType','scatter','color',[0,0,1],varargin{:});
    %perform linear fit
    p = polyfit(allTurn.noNoise.mean,allTurn.noNoise.STD,1);
    xEnd = [min(allTurn.noNoise.mean) max(allTurn.noNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p(1)*xPlot+p(2),[],[],'color',[0,0,1],varargin{:});
    
    
    plotXvsY(allTurn.withNoise.mean,allTurn.withNoise.STD,[],[],'graphType','scatter','color',[0,0.5,0],varargin{:});
    p2 = polyfit(allTurn.withNoise.mean,allTurn.withNoise.STD,1);
    xEnd = [min(allTurn.withNoise.mean) max(allTurn.withNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p2(1)*xPlot+p2(2),'turn mean','turn std','color',[0,0.5,0],varargin{:});
    legend({'without noise' [num2str(p(1)) '*x+' num2str(p(2))] 'with noise' [num2str(p2(1)) '*x+' num2str(p2(2))]});
    hold off;
    
    %plot walking mean vs its std
    makeFigure; hold on;
    plotXvsY(allWalk.noNoise.mean,allWalk.noNoise.STD,[],[],'graphType','scatter','color',[0,0,1],varargin{:});
    %perform linear fit
    p = polyfit(allWalk.noNoise.mean,allWalk.noNoise.STD,1);
    xEnd = [min(allWalk.noNoise.mean) max(allWalk.noNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p(1)*xPlot+p(2),[],[],'color',[0,0,1],varargin{:});

    plotXvsY(allWalk.withNoise.mean,allWalk.withNoise.STD,[],[],'graphType','scatter','color',[0,0.5,0],varargin{:});
    p2 = polyfit(allWalk.withNoise.mean,allWalk.withNoise.STD,1);
    xEnd = [min(allWalk.withNoise.mean) max(allWalk.withNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p2(1)*xPlot+p2(2),'walk mean','walk std','color',[0,0.5,0],varargin{:});
    legend({'without noise' [num2str(p(1)) '*x+' num2str(p(2))] 'with noise' [num2str(p2(1)) '*x+' num2str(p2(2))]});
    hold off;
    
    % plot mean walking speed vs mean turning speed
    makeFigure; hold on;
    plotXvsY(allWalk.noNoise.mean,allTurn.noNoise.mean,[],[],'graphType','scatter','color',[0,0,1],varargin{:});
    %perform linear fit
    p = polyfit(allWalk.noNoise.mean,allTurn.noNoise.mean,1);
    xEnd = [min(allWalk.noNoise.mean) max(allWalk.noNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p(1)*xPlot+p(2),[],[],'color',[0,0,1],varargin{:});

    plotXvsY(allWalk.withNoise.mean,allTurn.withNoise.mean,[],[],'graphType','scatter','color',[0,0.5,0],varargin{:});
    p2 = polyfit(allWalk.withNoise.mean,allTurn.withNoise.mean,1);
    xEnd = [min(allWalk.withNoise.mean) max(allWalk.withNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p2(1)*xPlot+p2(2),'walk mean','turn mean','color',[0,0.5,0],varargin{:});
    legend({'without noise' [num2str(p(1)) '*x+' num2str(p(2))] 'with noise' [num2str(p2(1)) '*x+' num2str(p2(2))]});
    hold off;
    
    % plot mean walking speed vs std turning speed
    makeFigure; hold on;
    plotXvsY(allWalk.noNoise.mean,allTurn.noNoise.STD,[],[],'graphType','scatter','color',[0,0,1],varargin{:});
    %perform linear fit
    p = polyfit(allWalk.noNoise.mean,allTurn.noNoise.STD,1);
    xEnd = [min(allWalk.noNoise.mean) max(allWalk.noNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p(1)*xPlot+p(2),[],[],'color',[0,0,1],varargin{:});
    
    plotXvsY(allWalk.withNoise.mean,allTurn.withNoise.STD,[],[],'graphType','scatter','color',[0,0.5,0],varargin{:});
    p2 = polyfit(allWalk.withNoise.mean,allTurn.withNoise.STD,1);
    xEnd = [min(allWalk.withNoise.mean) max(allWalk.withNoise.mean)];
    xPlot = linspace(xEnd(1),xEnd(2),10);
    plotXvsY(xPlot,p2(1)*xPlot+p2(2),'walk mean','turn std','color',[0,0.5,0],varargin{:});
    legend({'without noise' [num2str(p(1)) '*x+' num2str(p(2))] 'with noise' [num2str(p2(1)) '*x+' num2str(p2(2))]});
    hold off;
    
    disp(['turn low noise mean = ' num2str(mean(allTurn.noNoise.mean))]);
    disp(['turn low noise std = ' num2str(mean(allTurn.noNoise.STD))]);
    disp(['walk low noise mean = ' num2str(mean(allWalk.noNoise.mean))]);
    %disp(['walk low noise std = ' num2str(mean(allWalk.noNoise.STD))]);
    disp(['turn high noise mean = ' num2str(mean(allTurn.withNoise.mean))]);
    disp(['turn high noise std = ' num2str(mean(allTurn.withNoise.STD))]);
    disp(['walk high noise mean = ' num2str(mean(allWalk.withNoise.mean))]);
    %disp(['walk high noise std = ' num2str(mean(allWalk.withNoise.STD))]);
end