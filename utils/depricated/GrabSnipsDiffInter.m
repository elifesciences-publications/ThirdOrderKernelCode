function GS = grabSnipsDiffInter(input,params,varargin)
    %clips up all the data mmo snipits around a stimulus in a given epoch
    %and combines the data mmo epochs
    
    combType = 'mean';
    limits = zeros(2,1);
    normWalk = 1;
    epsilon = 0;
    absTurn = 0;
    ignoreInter = 0;
    mmerShift = 0;
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if limits(1) == 0 && limits(2) == 0
        for ii = 2:size(params,2);
            if params(ii).duration>limits(2);
                limits = [0 params(ii).duration];
            end
        end
    end
    
    snipLength = sum(limits);
    combFunc = str2func(combType);
    
    if absTurn
        input.XY(:,:,1) = abs(input.XY(:,:,1));
    end
    
    %create cells to house the data for each epoch, because epochs can be
    %of different durations. exclude the first epoch
    GS.origSize = size(params,2)-ignoreInter;
    GS.numEpochs = (size(params,2)-ignoreInter)^2;
    GS.numFlies = size(input.XY,2);
    dataSize = size(input.XY,1);
    GS.numData = sum(limits);
    GS.aveSizeNW = 30;
    
    if ignoreInter
        GS.mmerShift = 0;
    else
        GS.mmerShift = mmerShift;
    end
    
    GS.numReadsMat = cell(GS.numEpochs,GS.numFlies);
    GS.snipMat = cell(GS.numEpochs,GS.numFlies);
    
    GS.turn = zeros(snipLength,GS.numEpochs,GS.numFlies);
    GS.walk = zeros(snipLength,GS.numEpochs,GS.numFlies);
    GS.read = zeros(snipLength,GS.numEpochs,GS.numFlies);
    
    GS.stdTurn = zeros(snipLength,GS.numEpochs,GS.numFlies);
    GS.stdWalk = zeros(snipLength,GS.numEpochs,GS.numFlies);
    GS.semTurn = zeros(snipLength,GS.numEpochs,GS.numFlies);
    GS.semWalk = zeros(snipLength,GS.numEpochs,GS.numFlies);
    
    GS.numTrials = zeros(GS.numEpochs,GS.numFlies);
    
    GS.normWalk = zeros(GS.numEpochs,GS.numFlies);
    
    %go through each epoch. Find rows and columns where each epoch begins
    %go through each fly, find where the fly was exposed this this epoch
    %count the number of trials each fly has on this epoch. Go through each
    %trial and average them.
    
    for ii = 1:GS.origSize
        % find the indicies for when each fly saw this epoch
        % this ignores the very first stimulus
        epochInd = input.epoch == (ii+ignoreInter);
        [findEpochR,findEpochC] = find([zeros(1,GS.numFlies); diff(epochInd)==1]);

        for mm = 1:GS.origSize
            for jj = 1:GS.numFlies
                % all the indicies for the beginning of each epoch for this fly
                
                thisFlyEpochList = findEpochR(findEpochC == jj);
                
                %remove any from the list that go past the number of data
                %pomms
                thisFlyEpochList = thisFlyEpochList(thisFlyEpochList+limits(2)<dataSize);
                thisFlyEpochList = thisFlyEpochList(thisFlyEpochList-limits(1)+1>0);
                
                for ad = 1:length(thisFlyEpochList)
                    if epochInd(thisFlyEpochList(ad)+params(ii).duration)
                        thisFlyEpochList = [thisFlyEpochList; thisFlyEpochList(ad)+params(ii).duration];
                    end
                end
                
                for ad = length(thisFlyEpochList):-1:1
                    if input.epoch(thisFlyEpochList(ad)-1) ~= mm
                        thisFlyEpochList(ad) = [];
                    end
                end
                
                if isempty(thisFlyEpochList)
                    continue;
                end
                

                GS.numTrials(GS.origSize*(ii-1)+mm,jj) = size(thisFlyEpochList,1);
                GS.snipMat{GS.origSize*(ii-1)+mm,jj} = zeros(GS.numData,GS.numTrials(GS.origSize*(ii-1)+mm,jj),2);
                GS.numReadsMat{GS.origSize*(ii-1)+mm,jj} = zeros(GS.numData,GS.numTrials(GS.origSize*(ii-1)+mm,jj));

                for kk = 1:GS.numTrials(GS.origSize*(ii-1)+mm,jj)
                    snip = (thisFlyEpochList(kk) - limits(1) + 1) : (thisFlyEpochList(kk)+limits(2));
                    GS.numReadsMat{GS.origSize*(ii-1)+mm,jj}(:,kk) = input.numReads(snip,jj);
                    GS.snipMat{GS.origSize*(ii-1)+mm,jj}(:,kk,:) = input.XY(snip,jj,:);
                    GS.normWalk(GS.origSize*(ii-1)+mm,jj) = GS.normWalk(GS.origSize*(ii-1)+mm,jj) + mean(input.XY(thisFlyEpochList(kk)-GS.aveSizeNW+GS.mmerShift+1:thisFlyEpochList(kk)+GS.mmerShift,jj,2));
                end

                GS.normWalk(GS.origSize*(ii-1)+mm,jj) = GS.normWalk(GS.origSize*(ii-1)+mm,jj)/GS.numTrials(GS.origSize*(ii-1)+mm,jj);

                GS.read(:,GS.origSize*(ii-1)+mm,jj) = mean(GS.numReadsMat{GS.origSize*(ii-1)+mm,jj},2);

                GS.turn(:,GS.origSize*(ii-1)+mm,jj) = combFunc(GS.snipMat{GS.origSize*(ii-1)+mm,jj}(:,:,1),2);
                GS.walk(:,GS.origSize*(ii-1)+mm,jj) = combFunc(GS.snipMat{GS.origSize*(ii-1)+mm,jj}(:,:,2),2);

                if normWalk
                    GS.walk(:,GS.origSize*(ii-1)+mm,jj) = GS.walk(:,GS.origSize*(ii-1)+mm,jj)/(GS.normWalk(GS.origSize*(ii-1)+mm,jj)+epsilon);
                end

                GS.stdTurn(:,GS.origSize*(ii-1)+mm,jj) = std(GS.snipMat{GS.origSize*(ii-1)+mm,jj}(:,:,1),[],2);
                GS.stdWalk(:,GS.origSize*(ii-1)+mm,jj) = std(GS.snipMat{GS.origSize*(ii-1)+mm,jj}(:,:,2),[],2);
                GS.semTurn(:,GS.origSize*(ii-1)+mm,jj) = GS.stdTurn(:,GS.origSize*(ii-1)+mm,jj)/sqrt(GS.numTrials(GS.origSize*(ii-1)+mm,jj));
                GS.semWalk(:,GS.origSize*(ii-1)+mm,jj) = GS.stdWalk(:,GS.origSize*(ii-1)+mm,jj)/sqrt(GS.numTrials(GS.origSize*(ii-1)+mm,jj));
            end
        end
    end
    
    GS.comb = cat(4,GS.turn,GS.walk);
    GS.std = cat(4,GS.stdTurn,GS.stdWalk);
    GS.sem = cat(4,GS.semTurn,GS.semWalk);
end