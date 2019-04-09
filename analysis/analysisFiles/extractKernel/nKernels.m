function D = nKernels(varargin)
    % cross-correlates a 2D flicker input with the turning response to
    % extract the Wiener kernel of whatever order. Defaults to second order.
    
    
    %% Set default parameters you may want to change with a varargin
     
    maxTau = 50; % maximum filter length - inspect to see whether this is 
                 % adequate. You want your filter to go to zero on the
                 % edges (and hopefully never increase again after that!)               
    whichBehav = 'turn';
    N = 3;
    meanSubtractResp = 1; % fed into organizeData
    kernelOrder = 2;   
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    dataFolder = C{1}{1};
    removeOutliers = 1;
    distKernels = 0;
    
    %% Vararararararar
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Get data path
    
    tic
    
    if exist('testData','var')
        D = testData;    
        OD = organizeData(D,'removeOutliers',removeOutliers,'meanSubtract',meanSubtractResp,'normMouseRead',0,'rollSize',1);
    elseif exist('dataPath','var')
        D = grabData(dataPath);
        OD = organizeData(D,'removeOutliers',removeOutliers,'meanSubtract',meanSubtractResp);
    else
        D = grabData();
        OD = organizeData(D,'removeOutliers',removeOutliers,'meanSubtract',meanSubtractResp);
    end

    % important parameters to output for reference
    D.analysis.analysisParams.whichBehav = whichBehav;
    D.analysis.analysisParams.maxTau = maxTau;
    
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
            whenExtracted{q} = sprintf('%s_%io_%s',whichBehav,kernelOrder,datestr(now,'ddmmyy_HH_MM'));        
            destination{q} = sprintf('%s/%s/%s/%s/%s',kernelFolder,paramFile{q},year{q},date{q},file{q});
            
            if ~isdir(destination{q})
                mkdir(destination{q});              
            end        
        end
        
        %% Collect stimulus and response data

        toc

        D.kernelData.whichFile =  diff(OD.rig) < 1;
        D.kernelData.whichFile = [0 cumsum(D.kernelData.whichFile)] + 1;
        
        kernelData = nKernelData(D,OD,q,N);
        stimTraces = kernelData.stimTraces;
        turnTraces = kernelData.turnTraces;
        walkTraces = kernelData.walkTraces;
   
        % save this for convenience
        D.kernelData = kernelData;    
        
        %% Compute filters individually for each fly and then average

        toc

        % again, this is the same as you look over q - pulled from the
        % paramfile of the first file, so run analysis on one paramfile at
        % a time.
        if exist('D.data.params.var')
            inVar = D.data.params.var;
        else
            inVar = 1;
        end
  
        % took out mean subtraction of input since they're designed to be
        % balanced. Worth bothering?
        % Mean subtraction of responses done in organizeData unless vararared
        for qq = 1:kernelData.qSize   
                
            turn = turnTraces(:,qq);
            walk = walkTraces(:,qq);
            
            switch kernelOrder

                case 1

                    trialLen = length(turn);
                    normConst = (trialLen - (maxTau - 1)) * inVar;

                    xRoll = zeros(maxTau,size(stimTraces,1)-maxTau+1);
                    yRoll = zeros(maxTau,size(stimTraces,1)-maxTau+1);

                    for rr = 1:N                    
                        xRoll = xRoll + rollup(stimTraces(:,rr),maxTau) / N;
                        if rr == N
                            rr = 0;
                        end
                        % I know this is dumb, I just want to see it independently show me that 
                        % it's the same.
                        yRoll = yRoll + rollup(stimTraces(:,rr+1),maxTau) / N;
                    end

                    evalc(['respCut =' sprintf('%s',whichBehav) ';']);         
                    respCut = respCut(maxTau:end);
                    
                    kernels.k1_x_all(:,qq) = xRoll * respCut / normConst;
                    kernels.k1_y_all(:,qq) = yRoll * respCut / normConst;

                case 2

                    if N == 3
                        evalc(['k2_xy_all(:,qq) = n3_2o_fast(maxTau,inVar,stimTraces(:,1),stimTraces(:,2),stimTraces(:,3),' sprintf('%s',whichBehav) ');']);
                    elseif N ==4
                        evalc(['k2_xy_all(:,qq) = n4_2o_fast(maxTau,inVar,stimTraces(:,1),stimTraces(:,2),stimTraces(:,3),stimTraces(:,4),' sprintf('%s',whichBehav) ');']);
                    end
                
                    kernels.k2_xy_all = k2_xy_all;

                case 3

                    if N == 3
                        evalc(['k3_xxy_all(:,qq) = n3_3o_fast(maxTau,inVar,stimTraces(:,1),stimTraces(:,2),stimTraces(:,3),' sprintf('%s',whichBehav) ');']);
                        evalc(['k3_yyx_all(:,qq) = n3_3o_fast(maxTau,inVar,stimTraces(:,3),stimTraces(:,2),stimTraces(:,1),' sprintf('%s',whichBehav) ');']);
                    elseif N == 4
                        evalc(['k3_xxy_all(:,qq) = n4_3o_fast(maxTau,inVar,stimTraces(:,1),stimTraces(:,2),stimTraces(:,3),stimTraces(:,4),' sprintf('%s',whichBehav) ');']);
                        evalc(['k3_yyx_all(:,qq) = n4_3o_fast(maxTau,inVar,stimTraces(:,4),stimTraces(:,3),stimTraces(:,2),stimTraces(:,1),' sprintf('%s',whichBehav) ');']);                  
                    end
                    
                    kernels.k3_xxy_all = k3_xxy_all;
                    kernels.k3_yyx_all = k3_yyx_all;

                end                 
            end           
        
    %% Save the kernels and everything else

    fullStrName = sprintf('%s/%s',destination{q},whenExtracted{q});
    save(fullStrName,'kernels');
    fprintf('The kernels for file %i have been extracted and saved. ',q); toc
    
    end
    
end

