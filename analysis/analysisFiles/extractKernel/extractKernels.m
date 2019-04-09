function D = extractKernel(varargin)
    % cross-correlates a 2D flicker input with the turning response to
    % extract the Wiener kernel of whatever order. Defaults to second order.
    
    
    %% Set default parameters you may want to change with a varargin
     
    maxTau = 50; % maximum filter length - inspect to see whether this is 
                 % adequate. You want your filter to go to zero on the
                 % edges (and hopefully never increase again after that!)               
    whichBehav = 'turn';
    meanSubtractResp = 1; % fed into organizeData
    kernelOrder = 2;
%     testData = 0;
    doRedundant = 0; % Kernels that we expect to be 0 - Kxx, etc.
    interp = 'linear';       
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    dataFolder = C{1}{1};
    hugDiagonal = 0;
    absResp = 0;
    cutX = 0;
    mixStimTrue = 0;
    mixStimSigma = (5.7 / 2.3548)^2;
    mixStimAlpha = .2;
    mixStimG = .1;
    
    %% Vararararararar
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Get data path
    
    tic
    
    if exist('testData','var')
        D = testData;    
        OD = organizeData(D,'removeOutliers',0,'meanSubtract',meanSubtractResp,'normMouseRead',0,'rollSize',1,'absResp',absResp);
    elseif exist('dataPath','var')
        D = GrabData(dataPath);
        OD = OrganizeData(D,'removeOutliers',0,'meanSubtract',meanSubtractResp,'absResp',absResp);
    else
        D = GrabData();
        OD = OrganizeData(D,'removeOutliers',0,'meanSubtract',meanSubtractResp,'absResp',absResp);
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
        
        kernelFolder = C{1}{3};
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
            
            if mixStimTrue
                whenExtracted{q} = sprintf('%s_%io_%s_%0.5g',whichBehav,kernelOrder,datestr(now,'ddmmyy_HH_MM'),mixStimAlpha*10);
                kernelFolder = sprintf('%s/mixedKernels',kernelFolder);
            else
                whenExtracted{q} = sprintf('%s_%io_%s',whichBehav,kernelOrder,datestr(now,'ddmmyy_HH_MM'));
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
        
        %% Compute filters individually for each fly and then average

        toc

        % again, this is the same as you look over q - pulled from the
        % paramfile of the first file, so run analysis on one paramfile at
        % a time.
        
        if isfield(D.data.params,'var')
            inVar = D.data.params.var;
        else
            inVar = 1;
        end
        
        freqRatio = ceil(D.data.params.flickerFreq/60);

        switch kernelOrder
            case 1
                k1_x_all = zeros(maxTau,kernelData.qSize*freqRatio);
                k1_y_all = zeros(maxTau,kernelData.qSize*freqRatio);
            case 2
                k2_xy_all = zeros(maxTau^2,kernelData.qSize*freqRatio);
                k2_xx_all = zeros(maxTau^2,kernelData.qSize*freqRatio);
                k2_yy_all = zeros(maxTau^2,kernelData.qSize*freqRatio); 
            case 3
                k3_xxy_all = zeros(maxTau^3,kernelData.qSize*freqRatio);
                k3_yyx_all = zeros(maxTau^3,kernelData.qSize*freqRatio);
                k3_xxx_all = zeros(maxTau^3,kernelData.qSize*freqRatio);
                k3_yyy_all = zeros(maxTau^3,kernelData.qSize*freqRatio);
        end

        % took out mean subtraction of input since they're designed to be
        % balanced. Worth bothering?
        % Mean subtraction of responses done in organizeData unless vararared
        for qq = 1:kernelData.qSize            
            for rr = 1:freqRatio
                stim = stimTraces(:,:,rr);
                turn = turnTraces(:,qq,rr);
                walk = walkTraces(:,qq,rr);              

                if cutX 
                    stim(:,1) = stim(:,1) .* (stim(:,1) > 0);
                end
                
                switch kernelOrder

                    case 1

                    trialLen = length(turn);
                    normConst = (trialLen - (maxTau - 1)) * inVar;
                    xRoll = rollup(stim(:,1),maxTau);
                    yRoll = rollup(stim(:,2),maxTau);
                    evalc(['respCut =' sprintf('%s',whichBehav) ';']);         
                    respCut = respCut(maxTau:end);
                    kernels.k1_x_all(:,(qq-1)*freqRatio+rr) = xRoll * respCut / normConst;
                    kernels.k1_y_all(:,(qq-1)*freqRatio+rr) = yRoll * respCut / normConst;

                    case 2

                    evalc(['k2_xy_all(:,(qq-1)*freqRatio+rr) = twod_fast(maxTau,inVar,stim(:,1),stim(:,2),' sprintf('%s',whichBehav) ');']);
                    kernels.k2_xy_all = k2_xy_all;

                    if doRedundant
                        evalc(['k2_xx_all(:,(qq-1)*freqRatio+rr) = twod_fast(maxTau,inVar,stim(:,1),stim(:,1),' sprintf('%s',whichBehav) ');']);
                        evalc(['k2_yy_all(:,(qq-1)*freqRatio+rr) = twod_fast(maxTau,inVar,stim(:,2),stim(:,2),' sprintf('%s',whichBehav) ');']);
                        kernels.k2_xx_all = k2_xx_all;
                        kernels.k2_yy_all = k2_yy_all;
                    end                             

                    case 3

                    evalc(['k3_xxy_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,1),stim(:,1),stim(:,2),' sprintf('%s',whichBehav) ');']);
                    evalc(['k3_yyx_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,2),stim(:,2),stim(:,1),' sprintf('%s',whichBehav) ');']);
                    kernels.k3_xxy_all = k3_xxy_all;
                    kernels.k3_yyx_all = k3_yyx_all;

                    if doRedundant
                        evalc(['k3_xxx_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,1),stim(:,1),stim(:,1),' sprintf('%s',whichBehav) ');']);
                        evalc(['k3_yyy_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,2),stim(:,2),stim(:,2),' sprintf('%s',whichBehav) ');']);
                        kernels.k3_xxx_all = k3_xxx_all;
                        kernels.k3_yyy_all = k3_yyy_all;
                    end                 
                end               
            end  
        end
        
        %% Save the kernels and everything else
        
        fullStrName = sprintf('%s/%s',destination{q},whenExtracted{q});
        save(fullStrName,'kernels');
        fprintf('The kernels for file %i have been extracted and saved. ',q); toc

    end
    
    D.analysis.kernelPaths = destination;
    D.analysis.kernelFiles = whenExtracted;

end
