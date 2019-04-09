function D = normKernel(varargin)
    % cross-correlates a 2D flicker input with the turning response to
    % extract the Wiener kernel of whatever order. Defaults to second order.
    
    
    %% Set default parameters you may want to change with a varargin
     
    maxTau =50; % maximum filter length - inspect to see whether this is 
                 % adequate. You want your filter to go to zero on the
                 % edges (and hopefully never increase again after that!)               
    whichBehav = 'turn';
    meanSubtractResp = 1; % fed into organizeData
    diagStart = 21;
    maxKernelOrder = 3;
    interp = 'linear';       
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    dataFolder = C{1}{1};
    kernelFolder = C{1}{4};
    absResp = 0;
    cutX = 0;
    mixStim = 0;
    mixStimSigma = (5.7 / 2.3548)^2;
    mixStimAlpha = 0;
    mixStimG = .2;
    wingSpan = 5; % set to maxTau for "full span"
    downSampAll = 1;
    downSampRatio = 10;
    regenInv = 0;
    
    %% Vararararararar
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Get data path
    
    tic
    
    if exist('testData','var')
        D = testData;    
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',1,'normMouseRead',0,'rollSize',1,'absResp',absResp);
    elseif exist('dataPath','var')
        D = grabData(dataPath);
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',1,'absResp',absResp);
    else
        D = grabData();
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',1,'absResp',absResp);
    end

    % important parameters to output for reference
    D.analysis.analysisParams.whichBehav = whichBehav;
    D.analysis.analysisParams.maxTau = maxTau;
    D.analysis.analysisParams.interp = interp; 
    
    %% Loop through individual files (= a 20 min run) within the folders you chose, 
    %  extract individual kernels and save individually. Downscript files
    %  can then average and play with these kernels.
    
    for q = 1:OD.numFiles
        
        %% Create kernel directory
        
        if exist('testData','var')
            paramFile{q} = 'test';
            whenExtracted{q} = sprintf('%s_%io_%s',whichBehav,kernelOrder,datestr(now,'ddmmyy_HH_MM'));
            destination{q} = sprintf('%s/%s',kernelFolder,paramFile{q});
            if ~isdir(destination{q})
                mkdir(destination{q});              
            end 
        else            
            % get necessary parameters for naming directory
            if any(find(D.paths.stim{q} == '/'))
                pathParts{q} = strsplit(D.paths.stim{q},'/');
            else
                pathParts{q} = strsplit(D.paths.stim{q},'\');
            end
            paramFile{q} = pathParts{q}{end-4};
            % though this could in theory be different, it could mess up parts
            % of the analysis to have different paramfiles analyzed in one go
            % (if any of the paramfile-dependent parameters such as inVar,
            % update rate, etc. were not constant), so better to avoid doing
            % this.
            year{q} = pathParts{q}{end-3};
            date{q} = pathParts{q}{end-2};
            file{q} = pathParts{q}{end-1};

            % destination{q} is the name of the directory for each file - mirrors how
            % data is saved by master_stim, with an additional parameters of order and 
            % when the kernel was extracted: you may want to have two kernels
            % with different normalizations, sizes, etc., for the same file.
            for rr = 1:maxKernelOrder
                whenExtracted{q,rr} = sprintf('%s_%io_%s',whichBehav,rr,datestr(now,'ddmmyy_HH_MM'));     
            end
            destination{q} = sprintf('%s/%s/%s/%s/%s',kernelFolder,paramFile{q},year{q},date{q},file{q});
            if ~isdir(destination{q})
                mkdir(destination{q});              
            end        
        end
        
        %% Collect stimulus and response data

        toc

        D.kernelData.whichFile =  diff(OD.rig) < 1;
        D.kernelData.whichFile = [0 cumsum(D.kernelData.whichFile)] + 1;
        
        kernelData = getKernelData(D,OD,q);
        stimTraces = kernelData.stimTraces;
        turnTraces = kernelData.turnTraces;
        walkTraces = kernelData.walkTraces;

        % save this for convenience
        D.kernelData = kernelData;    

        %% downsample all traces?
        if downSampAll
            downSampInd = [ 1:downSampRatio:size(stimTraces,1) ];
            stimTraces = stimTraces(downSampInd,:);
            turnTraces = turnTraces(downSampInd,:);
            walkTraces = walkTraces(downSampInd,:);   
            D.downSampled.stimTraces = stimTraces;
            D.downSampled.turnTraces = turnTraces;
            D.downSampled.walkTraces = walkTraces;
        end
        
        %% mix stimulus?
        
        if mixStim
            stimTraces = mixStim(stimTraces,mixStimSigma,mixStimAlpha,mixStimG);
            D.mixedStim = stimTraces;
        end
        
        %% Create Polynomial matrix
        
        respLen = size(stimTraces,1)-(maxTau-1);
        seqInd(1:3) = 0;
        
        if or(maxKernelOrder <= 0,maxKernelOrder>3)
            fprintf('error: kernelMaxOrder should be between 1 and 3');
        end
        
        if maxKernelOrder > 0
            polMat(:,1) = ones(respLen,1);
            for diag = diagStart:maxTau
                polMat(:,1+diag) = stimTraces(diag:diag+respLen-1,1);
                polMat(:,1+maxTau+diag) = stimTraces(diag:diag+respLen-1,2);
            end
            seqInd(1) = 2*maxTau;
        end
        
        if maxKernelOrder > 1
            for diag = diagStart:maxTau
                diagPrime = maxTau+1 - diag;
                for r = diag:min(maxTau,diag+wingSpan)
                    rPrime = maxTau+1 - r;
                    seqInd(2) = seqInd(2) + 1;
                    polMat(:,1+seqInd(1)+seqInd(2)) = stimTraces(diagPrime:diagPrime+respLen-1,1).*stimTraces(rPrime:rPrime+respLen-1,2);
                    locate.k_xy(seqInd(2),1) = diag; locate.k_xy(seqInd(2),2) = r; seqInd(2) = seqInd(2) + 1;        
                    polMat(:,1+seqInd(1)+seqInd(2)) = stimTraces(diagPrime:diagPrime+respLen-1,2).*stimTraces(rPrime:rPrime+respLen-1,1);
                    locate.k_xy(seqInd(2),1) = r; locate.k_xy(seqInd(2),2) = diag; 
                end
            end
        end       
       
        if maxKernelOrder > 2
            for diag = diagStart:maxTau
                diagPrime = maxTau+1 - diag;
                for r = diag:min(maxTau,diag+wingSpan)
                    rPrime = maxTau+1 - r;
                    for s = diag:min(maxTau,diag+wingSpan)
                        seqInd(3) = seqInd(3) + 1;
                        sPrime = maxTau+1 - s;
                        polMat(:,1+seqInd(1)+seqInd(2)+seqInd(3)) = stimTraces(diagPrime:diagPrime+respLen-1,1) ... 
                            .*stimTraces(rPrime:rPrime+respLen-1,1) .*stimTraces(sPrime:sPrime+respLen-1,2) ;
                        locate.k_xxy(seqInd(3),1) = diag; locate.k_xxy(seqInd(3),2) = r; locate.k_xxy(seqInd(3),3) = s;
                    end
                    for s = max(1,diag-wingSpan):diag-1
                        seqInd(3) = seqInd(3) + 1;
                        polMat(:,1+seqInd(1)+seqInd(2)+seqInd(3)) = stimTraces(diagPrime:diagPrime+respLen-1,1) ... 
                            .*stimTraces(rPrime:rPrime+respLen-1,1) .*stimTraces(sPrime:sPrime+respLen-1,2) ;
                        locate.k_xxy(seqInd(3),1) = diag; locate.k_xxy(seqInd(3),2) = r; locate.k_xxy(seqInd(3),3) = s;
                    end
                end
            end
        end         

        %% invert onto each fly's response
        
        toc

        % again, this is the same as you look over q - pulled from the
        % paramfile of the first file, so run analysis on one paramfile at
        % a time.
        if exist('D.data.params.var')
            inVar = D.data.params.var;
        else
            inVar = 1;
        end
        
        freqRatio = ceil(D.data.params.flickerFreq/60);

        %% find the matrix to multiply against b once and then use for all subsequent trials
        if or(regenInv,~exist('normFlip'));
            ATA = (polMat'*polMat);
%             keyboard
        end
        
        for qq = 1:kernelData.qSize            
            for rr = 1:freqRatio     
                
                turn = turnTraces(:,qq,rr);
                walk = walkTraces(:,qq,rr); 
                evalc(['allKernel = ATA\permute(polMat,[2 1])*' sprintf('%s',whichBehav) '(maxTau:end);']);
               
                D.kernels.k0_all(:,qq) = allKernel(1);
                D.kernels.k1_x_all(:,qq) = allKernel(2:seqInd(1)/2+1);
                D.kernels.k1_y_all(:,qq) = allKernel(seqInd(1)/2+2:seqInd(1)+1);
                k_xy(:,qq) = allKernel(seqInd(1)+2:1+seqInd(1)+seqInd(2));
                k_xxy(:,qq) = allKernel(2+seqInd(1)+seqInd(2):1+seqInd(1)+seqInd(2)+seqInd(3)); 
                
                % reshape the diagonal-limited kernels
                
                for rr = 1:seqInd(2)
                    thisX = locate.k_xy(rr,1);
                    thisY = locate.k_xy(rr,2);
                    D.kernels.k2_xy_all((thisX-1)*maxTau+thisY,qq) = k_xy(rr) * (abs(k_xy(rr)) < 1e7);
                end       
                
                for rr = 1:seqInd(3)
                    thisX1 = locate.k_xxy(rr,1);
                    thisX2 = locate.k_xxy(rr,2);
                    thisY = locate.k_xxy(rr,3);
                    D.kernels.k3_xxy_all((thisX1-1)*maxTau^2+(thisX2-1)*maxTau+thisY,qq) = k_xxy(rr) * (abs(k_xxy(rr)) < 1e7);
                    D.kernels.k3_xxy_all((thisX2-1)*maxTau^2+(thisX1-1)*maxTau+thisY,qq) = k_xxy(rr) * (abs(k_xxy(rr)) < 1e7);   
                end          
                
            end
        end
        
        %% Save the kernels and everything else
        for rr = 1:maxKernelOrder
            D.analysis.OD = OD;
            fullStrName = sprintf('%s/%s',destination{q},whenExtracted{q,rr});
                save(fullStrName,'D');           
        end
        fprintf('The kernels for file %i have been extracted and saved. ',q); toc

    end
    
    D.analysis.kernelPaths = destination;
    D.analysis.kernelFiles = whenExtracted;
        
end
