function D = gaussKernel(varargin)
    % cross-correlates a 2D flicker input with the turning response to
    % extract the Wiener kernel of whatever order. Defaults to second order.
    
    
    %% Set default parameters you may want to change with a varargin
                   
    whichBehav = 'turn';
    meanSubtractResp = 1; % fed into organizeData
    wingSpan = 5; 
    diagStart = 11;
    diagEnd = 20;
    whichOrder = [0 1 0];
    interp = 'linear';       
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    dataFolder = C{1}{1};
    kernelFolder = C{1}{4};
    
    %% "not core"
    absResp = 0;
    cutX = 0;
    mixStimTrue = 0;
    mixStimSigma = (5.7 / 2.3548)^2;
    mixStimAlpha = 0;
    mixStimG = 0;
    
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
    D.analysis.analysisParams.diagStart = diagStart;
    D.analysis.analysisParams.diagEnd = diagEnd;
    D.analysis.analysisParams.wingSpan = wingSpan;
    D.analysis.analysisParams.interp = interp; 
    
    %% Loop through individual files (= a 20 min run) within the folders you chose, 
    %  extract individual kernels and save individually. Downscript files
    %  can then average and play with these kernels.
    
    kernelOrders = [1 2 3] .* whichOrder;
    kernelOrdersInd = find(kernelOrders);
    kernelOrders = kernelOrders(kernelOrdersInd);
    
    for q = 1:OD.numFiles
        
        %% Create kernel directory
        kernelFolder = C{1}{4};
        if exist('testData','var')
            paramFile{q} = 'test';
            for rr = kernelOrders
                    whenExtracted{q,rr} = sprintf('%s_%io_%s_%0.5g_line',whichBehav,rr,datestr(now,'ddmmyy_HH_MM'));            
            end
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
            if mixStimTrue
                for rr = kernelOrders
                    whenExtracted{q,rr} = sprintf('%s_%io_%s_%0.5g',whichBehav,rr,datestr(now,'ddmmyy_HH_MM'),mixStimAlpha*10);
                end
                kernelFolder = sprintf('%s/mixedKernels',kernelFolder);
            else
                for rr = kernelOrders
                    whenExtracted{q,rr} = sprintf('%s_%io_%s',whichBehav,rr,datestr(now,'ddmmyy_HH_MM'));
            
                end
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

        %% optionally, mix stimulus
        
        if mixStimTrue
            stimTraces = mixStim(stimTraces,mixStimSigma,mixStimAlpha,mixStimG);
            D.mixedStim = stimTraces;
        end
        
        %% Create Polynomial matrix            

        [ locs,margin,seqInd ] = pickPol( whichOrder,diagStart,diagEnd,wingSpan,1 );
        polMat = genPol( locs,margin,seqInd,stimTraces,whichOrder );                       
        
        %% invert onto each fly's response
        
        toc

        % again, this is the same as you look over q - pulled from the
        % paramfile of the first file, so run analysis on one paramfile at
        % a time.
        
        freqRatio = ceil(D.data.params.flickerFreq/60);       
        
        for qq = 1:kernelData.qSize            
            for rr = 1:freqRatio     
                
                turn = turnTraces(:,qq,rr);
                walk = walkTraces(:,qq,rr); 
                evalc(['coeffVect = polMat\' sprintf('%s',whichBehav) '(margin:end,1);']);               
                [ k1_x_sh(:,rr),k1_y_sh(:,rr),k2_xy_sh(:,rr),k3_xxy_sh(:,rr),k3_yyx_sh(:,rr) ] = reshapePol( coeffVect, locs, margin, seqInd );                              

            end
            
            k1_x_sh = mean(k1_x_sh,2);
            k1_y_sh = mean(k1_y_sh,2);
            k2_xy_sh = mean(k2_xy_sh,2);
            k3_xxy_sh = mean(k3_xxy_sh,2);
            k3_yyx_sh = mean(k3_yyx_sh,2);
            
            D.kernels.k1_x_all(:,qq) = k1_x_sh;
            D.kernels.k1_y_all(:,qq) = k1_y_sh;
            D.kernels.k2_xy_all(:,qq) = k2_xy_sh;
            D.kernels.k3_xxy_all(:,qq) = k3_xxy_sh;
            D.kernels.k3_yyx_all(:,qq) = k3_yyx_sh;
            
        end
        
        %% Save the kernels and everything else
        for rr = kernelOrders
            D.analysis.OD = OD;
            fullStrName = sprintf('%s/%s',destination{q},whenExtracted{q,rr});
            save(fullStrName,'D');          
        end
        fprintf('The kernels for file %i have been extracted and saved. ',q); toc

    end
    
    D.analysis.kernelPaths = destination;
    D.analysis.kernelFiles = whenExtracted;
        
end
