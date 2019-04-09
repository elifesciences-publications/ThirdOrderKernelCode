function OD = OrganizeData(D,varargin)
    meanSubtract = 1; % subtract mean from turning data
    normMouseRead = 1; % normalize dx dy values to the number of times the mice were read
    removeFlies = []; % array of indicies of flies to remove
    removeOutliers = 1; % remove flies that have abberant behavior
    rollSize = 2; % size of square window to filter data with
    mouseReadTime = 0.0026; % amount of time the arudino takes to read all 5 mice
    
    % this lovely little code takes in all arguments in varargin of the
    % form 'variableName','variableValue'
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% initialize variables
    % input form [time (flies,dx,dy) files] - parentheis indicate variables in the same diminsion
    % output form [time (flies) (dx,dy)]
    
    resp = D.data.resp; % make a shorthand
    stim = D.data.stim;
    
    %perform rolling average on data. Should be at least 2 because the
    %mouse reads alternate betwen 5 and 4 reads per query
    rollFun = ones(rollSize,1)/rollSize;

    % all analysis utilities should count the number of flies and size of the data
    OD.numFiles = size(resp,3);
    OD.numFlies = OD.numFiles*5;
    OD.numData = size(resp,1);
    
    % matrix containing the time (relative to start) each data point was collected
    OD.time(OD.numData,OD.numFlies) = 0;
    
    %% put stim values in form [time stimVal# flies]
    OD.stim = [];
    % this is fairly slow (100ms/file)
    for ii = 1:size(stim,3)
        OD.stim = cat(3,OD.stim,repmat(stim(:,4:end,ii),[1 1 5]));
    end
    
    %% put epoch values in form [time flies]
    epochPerExp = stim(:,3,:); % third column of stim is epoch #
    epochPerExp = epochPerExp(:,:); % formats to [time files]
    
    % convert epochs from [time files] to [time flies]
    OD.epoch(OD.numData,OD.numFlies) = 0; % format [time flies]
    for ii = 1:OD.numFiles % 5 flies in a row have the same epoch#'s
        OD.epoch(:,ii*5-4:ii*5) = repmat(epochPerExp(:,ii),[1 5]);
        OD.time(:,ii*5-4:ii*5) = repmat(resp(:,1,ii),[1 5]);
    end
    
    %% change dxdy data form from [time flies files] to [time flies]
    
    respX = resp(:,3:7,:); % dx values are columns 3-7
    respY = resp(:,8:12,:); % dy values are columns 8-12
    
    % normalize the dxdy values to the number of times the mouse was read
    % This keeps dropped fromes from being read as rapid turning / walking
    if normMouseRead
        for ii = 1:size(resp,3)
            if ~any(resp(:,18,ii)>0)
                disp(['dataset ' num2str(ii) ' doesnt have mouse read counts']);
            else
                % mouseReadTime is the amount of time the ardunio takes to
                % read all 5 mice
                % the 18th column of resp is the number of mouse reads per
                % dx reading. This puts the measurements from dots /
                % matlabRead to dots/second
                respX(:,:,ii) = (1/mouseReadTime)*bsxfun(@times,respX(:,:,ii),1./(resp(:,18,ii)));
                respY(:,:,ii) = (1/mouseReadTime)*bsxfun(@times,respY(:,:,ii),1./(resp(:,18,ii))); 
            end
        end
    end
    
    % if there are no reads
    respX(isnan(respX)) = 0;
    respY(isnan(respY)) = 0;
    
    % shift from [time flies files] to [time flies]
    respX = respX(:,:);
    respY = respY(:,:);
    
    % change dX from dots/second to degrees/second
    % each ball is 1/4 inch diameter so dots per circumference is 1000*1/4*pi
    % divide by 360 to get dots per degree 1000*1/4*pi/360
    respX = respX/(1000*1/4*pi/360);
    % change dY from dots/second to mm/second
    % 1000 dots per inch .03937 inches per mm flip to get mm per dot
    respY = respY/(1000*.03937);
    
    % save the rig number of each fly
    OD.rig = repmat(1:5,[1 OD.numFiles]);

    % initialize num reads and closed loop variables to zeros
    % (this method is faster than the zeros command)
    OD.numReads(OD.numData,OD.numFlies) = 0;
    OD.CLvar(OD.numData,OD.numFlies,2) = 0;
    
    for nf = 1:OD.numFiles
        OD.numReads(:,5*nf-4:5*nf) = repmat(resp(:,18,nf),[1 5]);
        OD.CLvar(:,5*nf-4:5*nf,1) = repmat(stim(:,5,nf),[1 5]);
        OD.CLvar(:,5*nf-4:5*nf,2) = repmat(stim(:,6,nf),[1 5]);
    end
    
    % remove flies that don't behave
    % std too low
    if removeOutliers
        absCutOffWalk = 2; % mm/sec
        absCutOffTurn = 60; % deg/sec
        relCutOffTurn = 1; % std/turn
        
        % flies that don't have a high enough std
        fliesHighTurnSTD = std(respX,[],1)>absCutOffTurn;
        OD.numFlies = OD.numFlies - sum(~fliesHighTurnSTD);
        OD.rig = OD.rig(:,fliesHighTurnSTD);
        OD.epoch = OD.epoch(:,fliesHighTurnSTD);
        OD.time = OD.time(:,fliesHighTurnSTD);
        OD.numReads = OD.numReads(:,fliesHighTurnSTD);
        OD.CLvar = OD.CLvar(:,fliesHighTurnSTD,:);
        OD.stim = OD.stim(:,:,fliesHighTurnSTD);
        respY = respY(:,fliesHighTurnSTD);
        respX = respX(:,fliesHighTurnSTD);
        
        % flies that don't walk fast enough
        fliesHighWalk = mean(respY,1)>absCutOffWalk;
        OD.numFlies = OD.numFlies - sum(~fliesHighWalk);
        OD.rig = OD.rig(:,fliesHighWalk);
        OD.epoch = OD.epoch(:,fliesHighWalk);
        OD.time = OD.time(:,fliesHighWalk);
        OD.numReads = OD.numReads(:,fliesHighWalk);
        OD.CLvar = OD.CLvar(:,fliesHighWalk);
        OD.stim = OD.stim(:,:,fliesHighWalk);
        respX = respX(:,fliesHighWalk);
        respY = respY(:,fliesHighWalk);

        % don't have a high enough std to mean ratio
        fliesHighSTDtoMean = std(respX,[],1)./abs(mean(respX,1))>relCutOffTurn;
        OD.numFlies = OD.numFlies - sum(~fliesHighSTDtoMean);
        OD.rig = OD.rig(:,fliesHighSTDtoMean);
        OD.epoch = OD.epoch(:,fliesHighSTDtoMean);
        OD.time = OD.time(:,fliesHighSTDtoMean);
        OD.numReads = OD.numReads(:,fliesHighSTDtoMean);
        OD.CLvar = OD.CLvar(:,fliesHighSTDtoMean);
        OD.stim = OD.stim(:,:,fliesHighSTDtoMean);
        respY = respY(:,fliesHighSTDtoMean);
        respX = respX(:,fliesHighSTDtoMean);
    end
    
    % remove flies in removeFlies
    OD.numFlies = OD.numFlies - size(removeFlies,2);
    OD.rig(:,removeFlies) = [];
    OD.epoch(:,removeFlies) = [];
    OD.stim(:,:,removeFlies) = [];
    respY(:,removeFlies) = [];
    respX(:,removeFlies) = [];
    OD.time(:,removeFlies) = [];
    OD.numReads(:,removeFlies) = [];
    OD.CLvar(:,removeFlies,:) = [];

    
    %subtract mean
    if meanSubtract
        %respX = bsxfun(@rdivide,respX,std(respX,[],1));
        respX = bsxfun(@minus,respX,mean(respX,1));
        %respY = bsxfun(@rdivide,respY,mean(respY,1));
        %respY = bsxfun(@minus,respY,mean(respY,1));
    end 
    
    respXave = zeros(size(respX,1),OD.numFlies);
    respYave = zeros(size(respY,1),OD.numFlies);
    %perform rolling average set size to 1 for no average
    for ii = 1:OD.numFlies
        respXave(:,ii) = filter(rollFun,1,respX(:,ii));
        respYave(:,ii) = filter(rollFun,1,respY(:,ii));
    end
    
    OD.XY = cat(3,respXave,respYave);
    
    %set up a matrix of meta data, keeping track of which rig each fly came
    %from, what time of day, day of the week
    flyDetails = struct('rig',cell(OD.numFlies,1),'time',cell(OD.numFlies,1),'day',cell(OD.numFlies,1),'month',cell(OD.numFlies,1),'year',cell(OD.numFlies,1),'dayofweek',cell(OD.numFlies,1));
    
    try
        for ii = 1:OD.numFiles;
            for jj = ii*5-4:ii*5
                findBreaks = find(D.paths.resp{ii}=='\' | D.paths.resp{ii}=='/',4,'last');
                flyDetails(jj).time = D.paths.resp{ii}((findBreaks(3)+1):(findBreaks(3)+8));
                flyDetails(jj).day = str2double(D.paths.resp{ii}((findBreaks(3)-2):(findBreaks(3)-1)));
                flyDetails(jj).month = str2double(D.paths.resp{ii}((findBreaks(2)+1):(findBreaks(2)+2)));
                flyDetails(jj).year = str2double(D.paths.resp{ii}((findBreaks(1)+1):(findBreaks(1)+4)));
                flyDetails(jj).dayofweek = weekday([num2str(flyDetails(jj).year) '-' num2str(flyDetails(jj).month) '-' num2str(flyDetails(jj).day)]);
            end
        end
    catch err
        disp('parsing of dates failed ignoring and continuing');
    end
    
    OD.flyDetails = flyDetails;
end