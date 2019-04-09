function D = combineEpochRespHeat(varargin)
    % reads in the data and averages the flies' response to the stimuli,
    % keeping each epoch separate. Then plots out the average response to
    % that stimuli vs the log speed of the wave
    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    limits = zeros(2,1);
    combType = 'mean';
    xLabel = 'right eye';
    yLabel = 'left eye';
    blacklist = [];
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if exist('dataPath','var')
        D = grabData(dataPath,blacklist);
    else
        D = grabData();
    end
    
    %% perform analysis
    analysis.OD = organizeData(D,varargin{:});
    analysis.GS = grabSnips(analysis.OD,D.data.params,'limits',limits);
    analysis.CI1 = combineInput(analysis.GS.comb,1,combType);
    analysis.CI3 = combineInput(analysis.CD.comb,3);
    
    D.analysis = analysis;
    
    %% graph data
    aveRespX = reshape(analysis.CI3.turn,sqrt(analysis.CI3.numEpochs),sqrt(analysis.CI3.numEpochs));
    semAveRespX = reshape(analysis.CI3.semTurn,sqrt(analysis.CI3.numEpochs),sqrt(analysis.CI3.numEpochs));
    
    aveRespY = reshape(analysis.CI3.turn,sqrt(analysis.CI3.numEpochs),sqrt(analysis.CI3.numEpochs));
    semAveRespY = reshape(analysis.CI3.semWalk,sqrt(analysis.CI3.numEpochs),sqrt(analysis.CI3.numEpochs));

    %use the values where left and right speed was equal as the expected
    %rotation speed for that stim. Then calculate an average between the
    %expected speeds for the velocity on each eye and see if it predicts
    %the speed the fly turns at when given the two eye stim.
    expRespX = aveRespX(logical(eye(size(aveRespX,1))));
    expRespY = aveRespY(logical(eye(size(aveRespY,1))));
    
    predRespX = zeros(size(aveRespX,1));
    predRespY = zeros(size(aveRespY,1));
    for ii = 1:size(aveRespX,1)
        for jj = 1:size(aveRespX,1)
            predRespX(ii,jj) = mean([expRespX(ii) expRespX(jj)]);
            predRespY(ii,jj) = mean([expRespY(ii) expRespY(jj)]);
        end
    end
    
    if CN
        % translate into progressive/regressive coordinates and take the
        % transverse = rot90 because its a fliplr then transverse. then
        % flip back to get it into absolute coordinates. Then combine anti
        % semetrically. This doesn't work however for the translational
        % motion diagonal so deal with that separately
        transDiag = aveRespX(rot90(logical(eye(size(aveRespX,1)))));
        transDiag = (transDiag - transDiag(end:-1:1))/2;
        zeroAndZero = aveRespX(ceil(size(aveRespX,1)/2),ceil(size(aveRespX,1)/2));
        negAveRespX = fliplr(rot90(aveRespX));
        aveRespX = (aveRespX-negAveRespX)/2;
        aveRespX(rot90(logical(eye(size(aveRespX,1))))) = transDiag;
        aveRespX(ceil(size(aveRespX,1)/2),ceil(size(aveRespX,1)/2)) = zeroAndZero;
        
        %repeat for SEM, summing in quadriture
        semTransDiag = semAveRespX(rot90(logical(eye(size(semAveRespX,1)))));
        semTransDiag = sqrt((semTransDiag.^2 + semTransDiag(end:-1:1).^2))/2;
        zeroAndZero = semAveRespX(ceil(size(semAveRespX,1)/2),ceil(size(semAveRespX,1)/2));
        semNegAveRespX = fliplr(rot90(semAveRespX));
        semAveRespX = sqrt((semAveRespX.^2+semNegAveRespX.^2))/2;
        semAveRespX(rot90(logical(eye(size(semAveRespX,1))))) = semTransDiag;
        semAveRespX(ceil(size(semAveRespX,1)/2),ceil(size(semAveRespX,1)/2)) = zeroAndZero;
    end
    
    %use the values where left and right speed was equal as the expected
    %rotation speed for that stim. Then calculate an average between the
    %expected speeds for the velocity on each eye and see if it predicts
    %the speed the fly turns at when given the two eye stim.
    expRespX = aveRespX(logical(eye(size(aveRespX,1))));
    expRespY = aveRespY(logical(eye(size(aveRespY,1))));
    predRespX = zeros(size(aveRespX,1));
    predRespY = zeros(size(aveRespY,1));
    iFlick = 1./[.1 .25 .25 .25 .1].^2;
    mu = [-57.2952 -57.2952 0 57.2952 57.2952];
    iPriorVar = 1/0.02;
    
    for ii = 1:size(aveRespX,1)
        for jj = 1:size(aveRespX,1)
            weightL = (iFlick(ii) + iPriorVar)/(iFlick(ii)+iFlick(jj)+2*iPriorVar);
            weightR = (iFlick(jj) + iPriorVar)/(iFlick(ii)+iFlick(jj)+2*iPriorVar);
            weightL = 0.5;
            weightR = 0.5;
            predRespX(ii,jj) = weightL*expRespX(ii) + weightR*expRespX(jj);
            predRespY(ii,jj) = weightL*expRespY(ii) + weightR*expRespY(jj);
        end
    end

    % plot heat of turning with different eye stimulations
    makeFigure;
    plotHeat(aveRespX,[xLabel ' (ave rotation speed)'],yLabel);
    confAxis('fTitle','measured turning speed',varargin{:});
    
    % plot heat of walk with different eye stimulations
    makeFigure;
    plotHeat(aveRespY,[xLabel ' (ave mm/sec)'],yLabel);
    confAxis('fTitle','measured walking speed',varargin{:});
    
    % plot heat of expected turning with different eye stimulations
    makeFigure;
    plotHeat(aveRespY,[predRespX ' (ave rotation speed)'],yLabel);
    confAxis('fTitle','predicted turning speed',varargin{:});
    
    % plot heat of expected walking with different eye stimulations
    makeFigure;
    plotHeat(aveRespY,[predRespY ' (ave mm/sec)'],yLabel);
    confAxis('fTitle','predicted walking speed',varargin{:});
    
    makeFigure;
    hold on;
    plotXvsY(1:size(expRespX,1),aveRespX,'left eye','deg/sec','error',semAveRespX);
    plotXvsY(1:size(expRespX,1),predRespX,'left eye','deg/sec');
    hold off;
    confAxis('fTitle','predicted walking speed',varargin{:});
    
    makeFigure;
    hold on;
    plotXvsY(1:size(expRespX,1),aveRespX','right eye','deg/sec','error',semAveRespY');
    plotXvsY(1:size(expRespX,1),predRespX,'right eye','deg/sec');
    hold off;
    confAxis('fTitle','predicted walking speed',varargin{:});
    
    makeFigure;
    surf(aveRespX);
    hold on;
    %surf(predRespX);
    
    numPoints = size(aveRespX,1)*(size(aveRespX,1)-1);
    chiSquare = 1/numPoints*sum(sum((aveRespX-predRespX).^2./semAveRespX.^2))
    
    D.analysis.aveRespX = aveRespX;
    D.analysis.aveRespY = aveRespY;
    D.analysis.predRespX = predRespX;
    D.analysis.predRespX = predRespY;
end