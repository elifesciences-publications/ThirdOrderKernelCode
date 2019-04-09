 function analysis = PlotFourier(flyResp,epochs,params,stim,dataRate,dataType,interleaveEpoch,varargin)
    combOpp = 1; % logical for combining symmetic epochs such as left and right
    figLeg = {};
    snipShift = [];
    duration = [];
    tickLabelX = [];
    dataX = [];
    labelX = '';
    imagingSelectedEpochsStr = {'' ''};
    sepType = 'interleaved';
    numSep = 1;
    fTitle = '';    

    switch dataType
        case 'imagingData'
            numIgnore = interleaveEpoch;
        case 'behavioralData'
            numIgnore = interleaveEpoch+2;
        case 'ephysData'
            numIgnore = interleaveEpoch;
        otherwise
            numIgnore = interleaveEpoch;
    end
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if ~iscell(imagingSelectedEpochsStr)
        imagingSelectedEpochsStr = num2cell(imagingSelectedEpochsStr);
%         imagingSelectedEpochsNum = imagingSelectedEpochsStr;
%     else
%         imagingSelectedEpochsNum = ConvertEpochNameToIndex(imagingSelectedEpochsStr);
    end
    
    numFlies = length(flyResp);
    averagedRois = cell(1,numFlies);
    fourierTransformed = cell(1,numFlies);
    
    %% get processed trials
    
    for ff = 1:numFlies
        analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,dataType,varargin{:});
        processedSnipMat = analysis.indFly{ff}{end}.snipMat;
        
        % Remove ignored epochs
        selectedEpochs = processedSnipMat(numIgnore+1:end,:);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'selectedEpochs';
        analysis.indFly{ff}{end}.snipMat = selectedEpochs;

        %% average over trials
        averagedTrials = ReduceDimension(selectedEpochs,'trials');

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedTrials';
        analysis.indFly{ff}{end}.snipMat = averagedTrials;
        
        %% combine left ward and rightward epochs
        if combOpp
            combinedOpposites = CombineOpposites(averagedTrials,0);
        else
            combinedOpposites = averagedTrials;
        end

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'combinedOpposites';
        analysis.indFly{ff}{end}.snipMat = combinedOpposites;

        %% shift time traces
        % find the relative spatial displacement of each ROI from edge
        % responses
        roiLocationRelative = GetRelativeLocation(processedSnipMat,params{ff},[1 2],dataRate);
        
        % circshift each ROI response the correct amount of time
        shiftedTimeTraces = CircShiftTimeTraces(combinedOpposites,roiLocationRelative,params{ff}(numIgnore+1:end),dataRate);
        shiftedTimeTraces2 = CircShiftTimeTraces(processedSnipMat,roiLocationRelative,params{ff},dataRate);

        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'shiftedTimeTraces';
        analysis.indFly{ff}{end}.snipMat = shiftedTimeTraces{ff};
        
        %% average over Rois
        averagedRois{ff} = ReduceDimension(shiftedTimeTraces,'Rois');
        
%         for ee = 1:size(averagedRois{ff},1)
%             for rr = 1:size(averagedRois{ff},2)
%                 averagedRois{ff}{ee,rr} = bsxfun(@minus,averagedRois{ff}{ee,rr},mean(averagedRois{ff}{ee,rr}));
%             end
%         end
        
        % write to output structure
        analysis.indFly{ff}{end+1}.name = 'averagedRois';
        analysis.indFly{ff}{end}.snipMat = averagedRois{ff};
        
        %% perform fourier transform
%         fourierTransformed{ff} = GetFourierAmplitude(averagedRois{ff});
%         % list of the frequencies present in the fourier transform
%         freqList = linspace(-dataRate/2,dataRate/2,size(fourierTransformed{ff}{1,1},1))';
% 
%         analysis.indFly{ff}{end+1}.name = 'fourierTransformed';
%         analysis.indFly{ff}{end}.snipMat = fourierTransformed{ff};
%         analysis.indFly{ff}{end}.freqList = freqList;
        
        %% Change names of analysis structures
        analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
    end
    
    %% convert from snipMat to matrix wtih averaged flies
    averagedFlies = ReduceDimension(averagedRois,'flies',@nanmean);
    averagedFliesSem = ReduceDimension(averagedRois,'flies',@NanSem);
    
    respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
    respMatSep = SeparateTraces(respMat,numSep,sepType);
    respMatPlot = permute(respMatSep,[1 3 6 7 2 4 5]);
    respMatPlot = bsxfun(@minus,respMatPlot,mean(respMatPlot,1));
    respMatPlot = abs(fft(respMatPlot));
    respMatPlot = fftshift(respMatPlot,1);
    
    respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
    respMatSemPlot = permute(respMatSem,[1 3 6 7 2 4 5]);
    respMatSemPlot = fftshift(respMatPlot,1);
    
    analysis.respMatPlot = respMatPlot;
    analysis.respMatSemPlot = respMatSemPlot;
        
    
    %%
    if isfield(params(1),'epochName')
        for ii = (1+numIgnore):length(params)
            if ischar(params(ii).epochName)
                figLeg{ii-numIgnore} = params(ii).epochName;
            else
                figLeg{ii-numIgnore} = '';
            end
        end
    end
            
    
    %% plot
    if strcmp(dataType,'imagingData');
        finalTitle = [fTitle ': ' imagingSelectedEpochsStr{1} ' - ' imagingSelectedEpochsStr{2}];
    else
        finalTitle = fTitle;
    end
    
    freqList = linspace(-dataRate/2,dataRate/2,size(respMatPlot,1))';
    
    for pp = 1:size(respMatPlot,3)
        for ss = 1:size(respMatPlot,4)
            MakeFigure;
            imagesc(1:size(respMatPlot,2),freqList,respMatPlot(:,:,pp,ss));
            colormap(flipud(cbrewer('div','RdBu',100)));
            maxResp = max(max(respMatPlot(:,:,pp,ss)));
            caxis([-maxResp maxResp]);
            colorbar;
            ConfAxis('tickX',1:size(respMatPlot,2),'tickLabelX',tickLabelX,'labelX',labelX,'labelY',['frequency (Hz) - ' num2str(numFlies) ' flies'],'fTitle',{finalTitle 'trace #' num2str(ss)});
        end
    end
end