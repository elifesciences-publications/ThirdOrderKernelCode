function GS = CLgrabSnips(resp,params,varargin)
    %clips up all the data into snipits around a stimulus in a given epoch
    %and combines the data into epochs
    
    combType = 'mean';
    limits = zeros(2,1);
    normWalk = 1;
    
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
    
    combFunc = str2func(combType);
    
    %create cells to house the data for each epoch, because epochs can be
    %of different durations. exclude the first epoch
    GS.numEpochs = size(params,2)-1;
    GS.numFlies = size(resp.XY,2);
    dataSize = size(resp.XY,1);
    GS.numData = sum(limits);
    GS.aveSizeNW = 30;
    
    GS.numReadsMat = cell(GS.numEpochs,GS.numFlies);
    GS.snipMat = cell(GS.numEpochs,GS.numFlies);
    GS.CLvarMat = cell(GS.numEpochs,GS.numFlies);
    
    % keep track of which fly was the lead for each trial
    GS.leadFly = cell(GS.numEpochs,GS.numFlies);
    
    GS.combCLvar = cell(GS.numEpochs,1);
    GS.combReads = cell(GS.numEpochs,1);
    GS.combSnips.lead = cell(GS.numEpochs,1);
    GS.combSnips.yoke = cell(GS.numEpochs,1);
    GS.numTrials = cell(GS.numEpochs,1);
    GS.numLead = cell(GS.numEpochs,1);
    
    GS.normWalk.lead = zeros(GS.numEpochs,GS.numFlies);
    GS.normWalk.yoke = zeros(GS.numEpochs,GS.numFlies);
    
    %go through each epoch. Find rows and columns where each epoch begins
    %go through each fly, find where the fly was exposed this this epoch
    %count the number of trials each fly has on this epoch. Go through each
    %trial and average them.
    GS.numTrials(:) = {zeros(1,GS.numFlies)};
    GS.numLead(:) = {zeros(1,GS.numFlies)};
    
    for ii = 1:GS.numEpochs
        [findEpochC,findEpochR] = find([zeros(1,GS.numFlies); diff(resp.epoch(:,:,1))==ii]);
        GS.combReads{ii} = zeros(GS.numData,GS.numFlies,1);
        GS.combCLvar{ii} = zeros(GS.numData,GS.numFlies,2);
        GS.combSnips.lead{ii} = zeros(GS.numData,GS.numFlies,2);
        GS.combSnips.yoke{ii} = zeros(GS.numData,GS.numFlies,2);
        
        for jj = 1:GS.numFlies
            thisFlyEpochList = findEpochC(findEpochR == jj);
            %remove any from the list that go past the number of data
            %points
            thisFlyEpochList = thisFlyEpochList(thisFlyEpochList+limits(2)<dataSize);
            thisFlyEpochList = thisFlyEpochList(thisFlyEpochList-limits(1)+1>0);
            
            GS.numTrials{ii}(jj) = size(thisFlyEpochList,1);
            
            GS.snipMat{ii,jj} = zeros(GS.numData,GS.numTrials{ii}(jj),2);
            GS.leadFly{ii,jj} = zeros(1,GS.numTrials{ii}(jj));
            
            GS.numReadsMat{ii,jj} = zeros(GS.numData,GS.numTrials{ii}(jj));
            GS.CLvarMat{ii,jj} = zeros(GS.numData,GS.numTrials{ii}(jj),2);
            
            for kk = 1:GS.numTrials{ii}(jj)
                if resp.stim(thisFlyEpochList(kk),1) == resp.rig(jj)
                    GS.leadFly{ii,jj}(kk) = 1;
                    GS.numLead{ii}(jj) = GS.numLead{ii}(jj)+1;
                end
                
                snip = (thisFlyEpochList(kk) - limits(1) + 1) : (thisFlyEpochList(kk)+limits(2));
                
                GS.numReadsMat{ii,jj}(:,kk,:) = resp.numReads(snip,jj);
                GS.CLvarMat{ii,jj}(:,kk,:) = resp.CLvar(snip,jj,:);
                GS.snipMat{ii,jj}(:,kk,:) = resp.XY(snip,jj,:);
                GS.normWalk.lead(ii,jj) = GS.normWalk.lead(ii,jj) + GS.leadFly{ii,jj}(kk)*mean(resp.XY(thisFlyEpochList(kk)-GS.aveSizeNW+1:thisFlyEpochList(kk),jj,2));
                GS.normWalk.yoke(ii,jj) = GS.normWalk.yoke(ii,jj) + (1-GS.leadFly{ii,jj}(kk))*mean(resp.XY(thisFlyEpochList(kk)-GS.aveSizeNW+1:thisFlyEpochList(kk),jj,2));                
            end
            
            GS.normWalk.lead(ii,jj) = GS.normWalk.lead(ii,jj)/GS.numLead{ii}(jj);
            GS.normWalk.yoke(ii,jj) = GS.normWalk.yoke(ii,jj)/(GS.numTrials{ii}(jj)-GS.numLead{ii}(jj));
            
            GS.combSnips.lead{ii}(:,jj,:) = combFunc(GS.snipMat{ii,jj}(:,logical(GS.leadFly{ii,jj}),:),2);
            GS.combSnips.yoke{ii}(:,jj,:) = combFunc(GS.snipMat{ii,jj}(:,logical(1-GS.leadFly{ii,jj}),:),2);
            
            GS.combReads{ii}(:,jj,:) = mean(GS.numReadsMat{ii,jj},2);
            GS.combCLvar{ii}(:,jj,:) = mean(GS.CLvarMat{ii,jj},2);
            
            if normWalk
                GS.combSnips.lead{ii}(:,jj,2) = GS.combSnips.lead{ii}(:,jj,2)/GS.normWalk.lead(ii,jj);
                GS.combSnips.yoke{ii}(:,jj,2) = GS.combSnips.yoke{ii}(:,jj,2)/GS.normWalk.yoke(ii,jj);
            end
            
            GS.stdSnips.lead{ii}(:,jj,:) = std(GS.snipMat{ii,jj}(:,logical(GS.leadFly{ii,jj}),:),0,2);
            GS.stdSnips.yoke{ii}(:,jj,:) = std(GS.snipMat{ii,jj}(:,logical(1-GS.leadFly{ii,jj}),:),0,2);
            
            GS.semSnips.lead{ii}(:,jj,:) = GS.stdSnips.lead{ii}(:,jj,:)/sqrt(sum(logical(GS.leadFly{ii,jj})));
            GS.semSnips.yoke{ii}(:,jj,:) = GS.stdSnips.yoke{ii}(:,jj,:)/sqrt(sum(logical(1-GS.leadFly{ii,jj})));
        end
    end
end