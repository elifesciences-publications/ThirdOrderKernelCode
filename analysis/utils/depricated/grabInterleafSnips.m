function GS = grabInterleafSnips(resp,params,limits,combType)
    %Grabs the data from the control epoch, which is thrown out by the
    %other analysis files
    
    if nargin < 4 || isempty(combType)
        combType = 'mean';
    end
    
    combFunc = str2func(combType);
    
    %create cells to house the data for each epoch, because epochs can be
    %of different durations. 
    GS.numEpochs = 1; %just the control epoch
    GS.numFlies = size(resp.XY,2);
    dataSize = size(resp.XY,1);
    GS.numData = sum(limits);
    
    GS.snipMat = cell(GS.numEpochs,GS.numFlies);
    GS.combSnips = cell(GS.numEpochs,1);
    GS.numTrials = cell(GS.numEpochs,1);
    
    %go through each epoch. Find rows and columns where each epoch begins
    %go through each fly, find where the fly was exposed this this epoch
    %count the number of trials each fly has on this epoch. Go through each
    %trial and average them.
    GS.numTrials(:) = {zeros(1,GS.numFlies)};
    GS.numData = sum(limits);
    
    for ii = 1:GS.numEpochs
        [findEpochC,findEpochR] = find([zeros(1,GS.numFlies); resp.epoch(:,:,1)==ii]);
        GS.combSnips{ii} = zeros(GS.numData,GS.numFlies,2);
        
        for jj = 1:GS.numFlies
            thisFlyEpochList = findEpochC(findEpochR == jj);
            %remove any from the list that go past the number of data
            %points
            thisFlyEpochList = thisFlyEpochList(thisFlyEpochList+limits(2)<dataSize);
            thisFlyEpochList = thisFlyEpochList(thisFlyEpochList-limits(1)+1>0);
            
            GS.numTrials{ii}(jj) = size(thisFlyEpochList,1);
            GS.snipMat{ii,jj} = zeros(GS.numData,GS.numTrials{ii}(jj),2);
            
            for kk = 1:GS.numTrials{ii}(jj)
                snip = (thisFlyEpochList(kk) - limits(1) + 1) : (thisFlyEpochList(kk)+limits(2));
                GS.snipMat{ii,jj}(:,kk,:) = resp.XY(snip,jj,:);
            end
            
            GS.combSnips{ii}(:,jj,:) = combFunc(GS.snipMat{ii,jj},2);
            GS.stdSnips{ii}(:,jj,:) = std(GS.snipMat{ii,jj},0,2);
            GS.semSnips{ii}(:,jj,:) = GS.combSnips{ii}(:,jj,:)/sqrt(size(GS.snipMat{ii,jj},2));
        end
    end
end