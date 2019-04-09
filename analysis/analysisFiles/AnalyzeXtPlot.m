function AnalyzeXtPlot(dataPath,computeCorr,normSize)    
    %reads in the data and analyzes the xtPlot

    %% deal with inputs
    %initialize vars these can be changed through varargin with the form
    %func(...'varName','value')
    switch nargin
        case 0
            dataPath = [];
            computeCorr = 0;
            normSize = 1;
        case 1
            computeCorr = 0;
            normSize = 1;
        case 2
            normSize = 1;
    end
    
    if isempty(dataPath)
        [xtPlot,params] = GetXtPlot();
    else
        [xtPlot,params] = GetXtPlot(dataPath);
    end
    
    twoEyes = 0;
    
    framesPerUp = params(1).framesPerUp;
    
    epoch = xtPlot(:,3);
    % Because there are zero epochs sometimes?
    xtPlot = xtPlot(epoch>0, :);
    epoch = xtPlot(:,3);
    time = xtPlot(:,1);
    frameNum = xtPlot(:,2);
    
    numLevels = 2^(8/(framesPerUp/3));
    
    inPlot = xtPlot(:,4:end-1)./(numLevels-1);
    inPlot = 2*inPlot-1;

    epochChange = [1; find(diff(epoch)); size(epoch,1)];
    numEpochs = size(epochChange,1)-1;
    highResEpoch = cell(numEpochs,1);
    thisEpoch = cell(numEpochs,1);
    tRes = framesPerUp*60;
    epochNum = zeros(numEpochs,1);

    for nn = 1:numEpochs
        thisEpoch{nn} = inPlot(epochChange(nn)+1:epochChange(nn+1),:);
        epochNum(nn,1) = epoch(epochChange(nn)+1);
        lastNeg1 = find(thisEpoch{nn}(1,:)~=-1,1,'last');
        
        if normSize == 1
            for cc = lastNeg1:size(thisEpoch{nn},2)
                if all(thisEpoch{nn}(:,cc) == -1)
                    thisEpoch{nn} = thisEpoch{nn}(:,1:cc-1);
                    break;
                end
            end
        end
        
        inSizeX = size(thisEpoch{nn},2); % spatial resolution of the stimulus
        inSizeT = size(thisEpoch{nn},1); % temporal resolution of the stimulus
        
        % adjust spatial resolution to 1 deg
        foldT = 1000/tRes;
        sizeT = inSizeT*foldT;
        sizeX = 360*1;
        highResEpoch{nn} = zeros(round(sizeT),sizeX);
        pixelSize = sizeX/inSizeX;

        for ii = 1:inSizeX
            for jj = 1:inSizeT
                highResEpoch{nn}(round(foldT*jj-foldT+1):round(foldT*jj),round((pixelSize*ii-pixelSize+1)):round((pixelSize*ii))) = thisEpoch{nn}(jj,ii);
            end
        end
    end
    
    xtPlot = cell2mat(highResEpoch);
    
    MakeFigure;
    imagesc(xtPlot);
    ConfAxis('tickY',1:10:size(xtPlot,1),'tickLabelY',1:10:size(xtPlot,1),'tickX',1:size(xtPlot,2),'tickLabelX',1:size(xtPlot,2));
    colormap('Gray');
%     D.analysis.R = reichardtModel(xtPlot);
    
    if computeCorr
        % set how far in time and x to look for correlations
        % replace in loop size(epochXT.leftEye{ii},2) for max
        % includes dx = 0
        corrTLength = 54;
        % replace in loop with size(epochXT.leftEye{ii},1) for max
        % includes dt = 0
        corrXLength = 15;

        epochXT.leftEye = cell(numEpochs,1);
        epochXT.rightEye = cell(numEpochs,1);

        % left eye stats
        stat.LE.mean.spatial = cell(numEpochs,1);
        stat.LE.std.spatial = cell(numEpochs,1);
        stat.LE.mean.temporal = cell(numEpochs,1);
        stat.LE.std.temporal = cell(numEpochs,1);

        stat.LE.mean.ave = cell(numEpochs,1);
        stat.LE.std.spatialAve = cell(numEpochs,1);
        stat.LE.std.temporalAve = cell(numEpochs,1);

        stat.LE.corr = cell(numEpochs,1);

        % right eye stats
        stat.RE.mean.spatial = cell(numEpochs,1);
        stat.RE.std.spatial = cell(numEpochs,1);
        stat.RE.mean.temporal = cell(numEpochs,1);
        stat.RE.std.temporal = cell(numEpochs,1);

        stat.RE.mean.ave = cell(numEpochs,1);
        stat.RE.std.spatialAve = cell(numEpochs,1);
        stat.RE.std.temporalAve = cell(numEpochs,1);

        stat.RE.corr = cell(numEpochs,1);

        for ii = 1:numEpochs
            epochXT.leftEye{ii} = thisEpoch{ii};
            
            if isfield(params(epochNum(ii)),'twoEyes')
                twoEyes = params(epochNum(ii)).twoEyes;
            end
            
            if twoEyes
                epochXT.leftEye{ii} = thisEpoch{ii}(:,1:floor(size(thisEpoch{ii},2)/2));
                epochXT.rightEye{ii} = thisEpoch{ii}(:,ceil(size(thisEpoch{ii},2)/2):end);
            
                % grab data only from this epoch and only for right eye
                stat.RE.mean.spatial{ii} = mean(epochXT.rightEye{ii},2);
                stat.RE.std.spatial{ii} = std(epochXT.rightEye{ii},1,2);
                stat.RE.mean.temporal{ii} = mean(epochXT.rightEye{ii},1);
                stat.RE.std.temporal{ii} = std(epochXT.rightEye{ii},1,1);

                stat.RE.mean.ave{ii} = mean(stat.RE.mean.spatial{ii});
                stat.RE.std.spatialAve{ii} = mean(stat.RE.std.spatial{ii});
                stat.RE.std.temporalAve{ii} = mean(stat.RE.std.temporal{ii});
            end

            % grab data only from this epoch and only for left eye
            stat.LE.mean.spatial{ii} = mean(epochXT.leftEye{ii},2);
            stat.LE.std.spatial{ii} = std(epochXT.leftEye{ii},1,2);
            stat.LE.mean.temporal{ii} = mean(epochXT.leftEye{ii},1);
            stat.LE.std.temporal{ii} = std(epochXT.leftEye{ii},1,1);

            stat.LE.mean.ave{ii} = mean(stat.LE.mean.spatial{ii});
            stat.LE.std.spatialAve{ii} = mean(stat.LE.std.spatial{ii});
            stat.LE.std.temporalAve{ii} = mean(stat.LE.std.temporal{ii});

            %check for correlations in the left eye
            %for max use
            %stat.LE.corr{ii} = zeros(size(epochXT.leftEye{ii},1),2*size(epochXT.leftEye{ii},2)-1);
            %stat.RE.corr{ii} = zeros(size(epochXT.rightEye{ii},1),2*size(epochXT.rightEye{ii},2)-1);

            stat.LE.corr{ii} = zeros(corrTLength,2*corrXLength-1);
            count{ii} = zeros(corrTLength,2*corrXLength-1);

            for xx = 1:size(epochXT.leftEye{ii},2)
                % the +1 and -1 for dx is because corrXLength includes dx = 0
                for dx = max([xx-corrXLength+1 1]):min([xx+corrXLength-1 size(epochXT.leftEye{ii},2)])
                    for dt = 1:corrTLength
                        cL = cov(epochXT.leftEye{ii}(1:end-dt+1,xx),epochXT.leftEye{ii}(dt:end,dx));
                        stat.LE.corr{ii}(dt,dx-xx+corrXLength) = stat.LE.corr{ii}(dt,dx-xx+corrXLength) + cL(1,2);
                   end
                end
            end

            % calculate the number of times you've added something together and
            % divide by it to give the mean covariance
            divMatLE = repmat((size(epochXT.leftEye{ii},2)-corrXLength+1):(size(epochXT.leftEye{ii},2)),[dt 1]);
            divMatLE = [divMatLE fliplr(divMatLE)];
            divMatLE(:,floor(size(divMatLE,2)/2)) = [];

            % divide by the proper number of times you could have had a
            % correlation
            stat.LE.corr{ii} = stat.LE.corr{ii}./divMatLE;
            
            if isfield(params(epochNum(ii)),'twoEyes')
                twoEyes = params(epochNum(ii)).twoEyes;
            end
            
            if twoEyes
                stat.RE.corr{ii} = zeros(corrTLength,2*corrXLength-1);
                
                for xx = 1:size(epochXT.rightEye{ii},2)
                    % the +1 and -1 for dx is because corrXLength includes dx = 0
                    for dx = max([xx-corrXLength+1 1]):min([xx+corrXLength-1 size(epochXT.rightEye{ii},2)])
                        for dt = 1:corrTLength
                            cR = cov(epochXT.rightEye{ii}(1:end-dt+1,xx),epochXT.rightEye{ii}(dt:end,dx));
                            stat.RE.corr{ii}(dt,dx-xx+corrXLength) = stat.RE.corr{ii}(dt,dx-xx+corrXLength) + cR(1,2);
                        end
                    end
                end
                
                % calculate the number of times you've added something together and
                % divide by it to give the mean covariance
                divMatRE = repmat((size(epochXT.rightEye{ii},2)-corrXLength+1):(size(epochXT.rightEye{ii},2)),[dt 1]);
                divMatRE = [divMatRE fliplr(divMatRE)];
                divMatRE(:,floor(size(divMatRE,2)/2)) = [];
                
                % divide by the proper number of times you could have had a
                % correlation
                stat.RE.corr{ii} = stat.RE.corr{ii}./divMatRE;
            end
        end
        
        tickY = frameNum;
        tickLabelY = frameNum;
        
        for ii = 1:numEpochs
            if isfield(params(epochNum(ii)),'twoEyes')
                twoEyes = params(epochNum(ii)).twoEyes;
            end
            
            if twoEyes
                MakeFigure;
                colormap('Gray');
                imagesc(stat.LE.corr{ii})
                xlabel('dx');
                ylabel('dt (ms)');
                ConfAxis('fTitle',['epoch #' num2str(ii) ' left eye'],'tickX',1:size(stat.LE.corr{ii},2)*2-1,'tickLabelX',(1:size(stat.LE.corr{ii},2)*2)-ceil(size(stat.LE.corr{ii},2)/2),'tickY',1:size(stat.LE.corr{ii},1),'tickLabelY',(0:size(stat.LE.corr{ii},1)-1)/(params(1).framesPerUp*60)*1000);

                MakeFigure;
                colormap('Gray');
                imagesc(stat.RE.corr{ii});
                xlabel('dx');
                ylabel('dt (ms)');
                ConfAxis('fTitle',['epoch #' num2str(ii) ' right eye'],'tickX',1:size(stat.RE.corr{ii},2)*2-1,'tickLabelX',(1:size(stat.RE.corr{ii},2)*2)-ceil(size(stat.RE.corr{ii},2)/2),'tickY',1:size(stat.RE.corr{ii},1),'tickLabelY',(0:size(stat.RE.corr{ii},1)-1)/(params(1).framesPerUp*60)*1000);
            else
                MakeFigure;
                colormap('Gray');
                imagesc(stat.LE.corr{ii});
                xlabel('dx');
                ylabel('dt (ms)');
                ConfAxis('fTitle',['epoch #' num2str(ii) ' full stim'],'tickX',1:size(stat.LE.corr{ii},2)*2-1,'tickLabelX',(1:size(stat.LE.corr{ii},2)*2)-ceil(size(stat.LE.corr{ii},2)/2),'tickY',1:size(stat.LE.corr{ii},1),'tickLabelY',(0:size(stat.LE.corr{ii},1)-1)/(params(1).framesPerUp*60)*1000);
            end
        end
    end
end