function GS = GrabSnips(input,params,varargin)
    %clips up all the data into snipits around a stimulus in a given epoch
    %and combines the data into epochs
    
    combType = 'mean';
    limits = zeros(2,1);
    normWalk = 1;
    epsilon = 0;
    absTurn = 0;
    ignoreInter = 1;
    interShift = 0;
    turnCut = 9999;
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if limits(1) == 0 && limits(2) == 0
        for ii = 2:size(params,2);
            if params(ii).duration>limits(2);
                limits = [0+6 params(ii).duration+6];
            end
        end
    end
    
    
    GS.limits = limits;
    GS.interShift = interShift;
    snipLength = limits(2)-limits(1);
    combFunc = str2func(combType);
    
    if absTurn
        input.XY(:,:,1) = abs(input.XY(:,:,1));
    end
    
    %create cells to house the data for each epoch, because epochs can be
    %of different durations. exclude the first epoch
    GS.numEpochs = size(params,2)-ignoreInter;
    GS.numFlies = size(input.XY,2);
    dataSize = size(input.XY,1);
    GS.numData = limits(2)-limits(1);
    GS.aveSizeNW = 30;
    
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
    
    for ii = 1:GS.numEpochs
        % find the indicies for when each fly saw this epoch
        % pad with zeros at the beginning so you don't shrink your array
        % with diff
        epochInd = input.epoch == (ii+ignoreInter);
        [findEpochR,findEpochC] = find([zeros(1,GS.numFlies); diff(epochInd)==1]);
        
        for jj = 1:GS.numFlies
            % all the indicies for the begging of each epoch for this fly
            thisFlyEpochList = findEpochR(findEpochC == jj);
            
            %remove any from the list that go past the number of data
            %points
            thisFlyEpochList = thisFlyEpochList(thisFlyEpochList+limits(2)-1<=dataSize);
            thisFlyEpochList = thisFlyEpochList(thisFlyEpochList+limits(1)>0);
            
            if ~ignoreInter
                for ad = 1:length(thisFlyEpochList)
                    if epochInd(thisFlyEpochList(ad)+params(ii).duration)
                        thisFlyEpochList = [thisFlyEpochList; thisFlyEpochList(ad)+params(ii).duration];
                    end
                end
            end
            
            GS.numTrials(ii,jj) = size(thisFlyEpochList,1);
            GS.snipMat{ii,jj} = zeros(GS.numData,GS.numTrials(ii,jj),2);
            GS.numReadsMat{ii,jj} = zeros(GS.numData,GS.numTrials(ii,jj));
            
            for kk = 1:GS.numTrials(ii,jj)
                snip = (thisFlyEpochList(kk) + limits(1)) : (thisFlyEpochList(kk)+limits(2)-1);
                GS.numReadsMat{ii,jj}(:,kk) = input.numReads(snip,jj);
                GS.snipMat{ii,jj}(:,kk,:) = input.XY(snip,jj,:);
                %GS.stimMat{ii,jj}(:,kk,:) = input.stim(snip,:,jj);
                GS.normWalk(ii,jj) = GS.normWalk(ii,jj) + mean(input.XY(thisFlyEpochList(kk)-GS.aveSizeNW+GS.interShift+1:thisFlyEpochList(kk)+GS.interShift,jj,2));
            end
            
            if turnCut ~= 0
                theseSnips = abs(mean(GS.snipMat{ii,jj}(:,:,1),1))<turnCut;
            else
                theseSnips = ones(size(abs(mean(GS.snipMat{ii,jj}(:,:,1),1))));
            end
            
            GS.normWalk(ii,jj) = GS.normWalk(ii,jj)/GS.numTrials(ii,jj);
            
            GS.read(:,ii,jj) = mean(GS.numReadsMat{ii,jj},2);
            
            GS.turn(:,ii,jj) = combFunc(GS.snipMat{ii,jj}(:,:,1),2);
            GS.walk(:,ii,jj) = combFunc(GS.snipMat{ii,jj}(:,theseSnips,2),2);
            
            if normWalk
                GS.walk(:,ii,jj) = GS.walk(:,ii,jj)/(GS.normWalk(ii,jj)+epsilon);
            end
            
            
            
            GS.stdTurn(:,ii,jj) = std(GS.snipMat{ii,jj}(:,:,1),[],2);
            GS.stdWalk(:,ii,jj) = std(GS.snipMat{ii,jj}(:,:,2),[],2);
            GS.semTurn(:,ii,jj) = GS.stdTurn(:,ii,jj)/sqrt(GS.numTrials(ii,jj));
            GS.semWalk(:,ii,jj) = GS.stdWalk(:,ii,jj)/sqrt(GS.numTrials(ii,jj));
        end
    end
    
    GS.comb = cat(4,GS.turn,GS.walk);
    GS.std = cat(4,GS.stdTurn,GS.stdWalk);
    GS.sem = cat(4,GS.semTurn,GS.semWalk);
end