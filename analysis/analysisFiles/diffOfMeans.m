function [ D ] = diffOfMeans( varargin )
% Compares means of adjacent epoch pairs to see whether there is a
% significant difference between them.

    %% Input Variables
    limits = [30 120];
    numBins = 49;
    xLabel = 'time (sec)';
    yLabel = 'response + SEM';
    combType = 'mean';

    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    %% Get Data Paths
    if exist('dataPath','var')
        D = grabData(dataPath);
    else
        D = grabData();
    end
    
    %% Preprocessing
    analysis.OD = organizeData(D,varargin{:});
    analysis.GS = grabSnips(analysis.OD,D.data.params,'limits',limits,varargin{:});
    
    %% Make comparisons
    keyboard
    
    numFlies = analysis.OD.numFlies;
    numEpochs = analysis.GS.numEpochs;
    snipMat = analysis.GS.snipMat;
    
    numPairs = numEpochs/2;
    if mod(numPairs,1) ~= 0
        error('You do not have an even number of epochs.');
    end
    
    numPairPairs = (numPairs-1)/2;
    if mod(numPairPairs,1) ~= 0
        error('You do not have an even number of pairs to compare.')
    end
    
    diffMeans = zeros(numPairs,numFlies);
    diffDiffMeans = zeros(numPairPairs,numFlies);
    
    pairInd = 0;
    pairPairInd = 0;
    for qq = 1:numEpochs
        if mod(qq,2) == 1 
                pairInd = pairInd+1;
                termPol = 1;
                if mod(qq,4) == 1
                    pairPairInd = pairPairInd + 1;
                end
            else
                termPol = -1;
        end            
        for rr = 1:numFlies
            getSnips = snipMat{qq,rr}(:,:,1);
            snipsMean(qq,rr) = mean(getSnips(:));
            
            diffMeans(pairInd,rr) = termPol * snipsMean(qq,rr) / 2;
            diffDiffMeans(pairPairInd,rr) = termPol * snipsMean(qq,rr) / 4;               
        end 
    end
    
    diffMeansDevs = std(diffMeans,[],2);
    diffMeansSEM = diffMeansDevs / sqrt( numFlies - 1 );
    diffMeansZ = mean(diffMeans,2) ./ diffMeansSEM;
    
    diffDiffMeansDevs = std(diffDiffMeans,[],2);
    diffDiffMeansSEM = diffDiffMeansDevs / sqrt( numFlies - 1 );
    diffDiffMeansZ = mean(diffDiffMeans,2) ./ diffDiffMeansSEM;
    
    figure; 
    title('Z score of differences of means');
    axLim = max(abs(diffDiffMeansZ));
    plot(diffDiffMeansZ);
    set(gca,'Ylim',[-axLim axLim]);  
    
    %% Save and output everything
    
    D.analysis.diff.diffMeansDevs = diffMeansDevs;
    D.analysis.diff.diffMeansSEM = diffMeansSEM;
    D.analysis.diff.diffMeansZ = diffMeansZ;
   
    D.analysis.diff.diffDiffMeansDevs = diffDiffMeansDevs;
    D.analysis.diff.diffDiffMeansSEM = diffDiffMeansSEM;
    D.analysis.diff.diffDiffMeansZ = diffDiffMeansZ;
   
    D.analysis = analysis;    

end

