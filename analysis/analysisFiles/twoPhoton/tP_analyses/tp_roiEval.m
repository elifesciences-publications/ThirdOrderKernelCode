function Z = tp_roiEval( Z, roiEval )
% Evaluates ROIs based on activity during the stimuli listed in
% controlEpochs. 
    % INPUTS
        % Z: the structure containing filtered traces for the ROIs you wish
        %   evauluate.
        % roiEval: a vector of the ROIs for which you would like to run
        %   this analysis. All output variables will only be evaluated for
        %   these ROIs, so indices within them will not correspond to
        %   indices of the original ROIs in ROImasks, filtered traces, etc.
    % Outputs
        % Z.eval structure: contains:
            %  - QUANTITIES EVALUATED FOR EACH ROI IN roiEval: 
            % direction_selectivity, bright_min_dark_left_over_sum, 
            % bright_min_dark_right_over_sum, bright_left_plus_right, 
            % dark_left_plus_right.
            % - Category_name and category_force: sorting ROIs based on which
            % of the four edge type stimuli they respond most strongly to.
            % - Parameters documenting how the analysis was run.
            
%%            

    meanMethod = 'percentile'; % This is slightly confusing -- all variables were originally
                     % named as the mean of these quantities, but you might 
                     % want to look at (threshLevel)th percetile or something else
                     % instead, so by changing meanMethod you can make
                     % ___mean a different quantity, see switch/cases
                     % below. meanMethod enters as an argument into
                     % meanFunction, defined at the bottom of this script.
    sphere = 0; % you probably want to sphere traces for clustering but NOT
                % for comparing different parameters. Sphering means that
                % you mean subtract every ROI for the duration of the
                % control stimuli and divide by each ROI's own standard
                % dev.
    threshLevel = .98; % If your meanMethod is percentile, this is the 
                       % threshold level used to approximate "peak
                       % activity".
                     
    loadFlexibleInputs(Z);
    
    controlEpochs = { 'Left Light Edge','Left Dark Edge','Right Light Edge', ...
        'Right Dark Edge','Square Left','Square Right' }; 
        % These are the epochs for which the script will compute activity.
        % This parameter is not flexible because the existence of many of
        % these epochs are asusumed for the assigning of different
        % variables below. This script will not run with very old data sets
        % in which edge types are not presented. 
    
    nRoi = size(Z.ROI.roiMasks,3)-1;
    
    if nargin < 2 || isempty(roiEval)
        roiEval = [1:nRoi];
        % Assigning roiEval gives you the option to run this analysis for
        % only a subset of the ROIs for which masks and traces exist. Be
        % careful if you want to use this option that you understand that
        % the location of an ROI's trace in the outputs of roiEval will be
        % different than its location in ROImasks, rawTraces, filtered
        % traces, etc. For instance, if you have 100 ROIs to start with and
        % roiEval = [22 46 97], then you will only run the script for these
        % three ROIs, and direction_selectivity(2) will give you the
        % direction selectivity of ROI 46, NOT ROI 2. If you do not assign
        % roiEval (that is, if you only enter one input into tp_roiEval AND
        % IF THERE IS NO VARIABLE roiEval in Z.PARAMS then the default is
        % to use all ROIs. 
    end
    
    %% Get epoch inds
    % Here were find the time points in the filtered traces that
    % corresponding to the presentation of each of the control epochs
    % separately. Because each control stimulus is shown twice, each
    % inds{q} should have two sub-cells with a different set of indices for
    % the two presentation.
    nEpTypes = length(controlEpochs);
    for q = 1:nEpTypes
        inds{q} = getEpochInds(Z, controlEpochs{q});
    end
    % Here we concatenate the indices of the two presentations of each
    % control stimulus type.
    for q = 1:nEpTypes
        catInds{q} = [];
        for r = 1:length(inds{q})
            catInds{q} = cat(1,catInds{q},inds{q}{r});
        end
    end
    % Here we find the last point of all the control epochs that we're
    % considering. The idea is that the trace starts out with the control
    % epochs and then later the experimental stimuli are shown. We are only
    % interested in the control behavior here, so we cut the traces to look
    % at only the first part. 
    maxInd = 0;
    for q = 1:length(controlEpochs)
        for r = 1:length(inds{q})
            maxInd = max([ inds{q}{r}' maxInd ]);
        end
    end
    
    %% Option to sphere the traces
    % As described above, this means mean subtracting and dividing by
    % standard deviation. You should decide whether this processing is
    % appropriate for whatever analysis you're running.
    if sphere
        traces = Z.filtered.roi_avg_intensity_filtered_normalized(1:maxInd,:); % note that we're cutting traces to end at maxInd
        traces = traces - repmat(mean(traces,1),[ maxInd 1 ]);
        traces = traces * diag(sqrt(diag(traces'*traces)))^(-1);
    else
        traces = Z.filtered.roi_avg_intensity_filtered_normalized(1:maxInd,:);
    end
        
    %% Compute raw means
    % Here we compute the "mean" (see meanMethod) activity of each ROI for
    % each presentation of each control epoch. These are stored in
    % rawMeans{q,r} where q is the number of the control epoch (location in
    % controlEpochs array) and r is the presentation.
    for q = 1:length(controlEpochs)
        for r = 1:length(inds{q})
            rawMeans{q,r} = meanFunction(traces(inds{q}{r},roiEval), meanMethod, threshLevel);
        end
    end
    eval.rawMeans = rawMeans;
    
    %% Compute desired parameters
    
    % Direction selectivity
    % Here we find the location of these two epochs in the controlEpochs
    % array. By default, these should be 5 and 6.
    leftNum = find(strcmp(controlEpochs,'Square Left'));
    rightNum = find(strcmp(controlEpochs,'Square Right'));
    
    % Subtract the average activity during square right from the average
    % activity during both presentations of square left. Divide by the sum
    % of these two quantities. Therefore, if the average activity during
    % each square left and square right is positive, this should be a
    % number ranging from zero to 1. 
    eval.direction_selectivity = ...
        ( meanFunction( traces( catInds{leftNum},roiEval ), meanMethod, threshLevel) - ...
        meanFunction( traces( catInds{rightNum},roiEval ), meanMethod, threshLevel) ) ./ ...
        ( meanFunction( traces( catInds{leftNum},roiEval ), meanMethod, threshLevel) + ...
        meanFunction( traces( catInds{rightNum},roiEval ), meanMethod, threshLevel) );
    
    % Here we compute several quanitites related to the edge selectivity of
    % the ROIs.
    if length(controlEpochs) > 4
        % Determine the location of each edge type in the controlEpochs
        % vector. By default, these are 1, 2, 3, 4.
        leftBrightNum = find(strcmp(controlEpochs,'Left Light Edge'));
        leftDarkNum = find(strcmp(controlEpochs,'Left Dark Edge'));
        rightBrightNum = find(strcmp(controlEpochs,'Right Light Edge'));
        rightDarkNum = find(strcmp(controlEpochs,'Right Dark Edge'));
        % Compute the average activity of each ROI to these edge types.
        % Notice that the fact that we're using catInds means that this
        % average incorporates both presentations. The resulting variables
        % (e.g. leftBrightMean...) should be vectors of size 1 x nRoi.
        leftBrightMean = meanFunction( traces( catInds{leftBrightNum},roiEval ), meanMethod, threshLevel);
        leftDarkMean = meanFunction( traces( catInds{leftDarkNum},roiEval ), meanMethod, threshLevel);
        rightBrightMean = meanFunction( traces( catInds{rightBrightNum},roiEval ), meanMethod, threshLevel);
        rightDarkMean = meanFunction( traces( catInds{rightDarkNum},roiEval ), meanMethod, threshLevel);    
        % Concatenate these variables so that catMeans has dimension 4 x
        % nRoi, with the first dimension going over edge type and the
        % second dimension going over ROI identity. 
        catMeans = [ leftBrightMean; leftDarkMean; rightBrightMean; rightDarkMean ];
        catList = {'Left Bright','Left Dark','Right Bright','Right Dark'};
        % Here we sort all ROIs by their preference for one of these four
        % edge types. We do this by taking the max along the first
        % dimension of catMeans - whichever of the four edge types has the
        % highest mean activity will be the "category_force" value for the
        % given ROI. Then, with category_name, we translate this number 1-4
        % into the actual name of the control epoch, using catList to tell
        % which numbers correspond to which epochs.
        [vals eval.category_force] = max(catMeans);
        eval.category_name = [];
        for q = 1:length(eval.category_force)
            eval.category_name = cat(1,eval.category_name,catList(eval.category_force(q)));
        end
        % Finally, we use the averages computed above (e.g. leftBrightMean)
        % to calculate "edge preference indices" below, which should be
        % self-explanatory. All are (A-B)/(A+B), as in direction
        % selectivity. The first two have to do with the edge polarity
        % preference for a given cardinal direction, the second two have to
        % do with the non-direction selective response to bright versus
        % dark.
        eval.bright_min_dark_left_over_sum = ( leftBrightMean - leftDarkMean ) ./ ( leftBrightMean + leftDarkMean ); 
        eval.bright_min_dark_right_over_sum = ( rightBrightMean - rightDarkMean ) ./ ( rightBrightMean + rightDarkMean ); 
        eval.bright_left_plus_right  = ( leftBrightMean + rightBrightMean ); 
        eval.dark_left_plus_right  = ( leftDarkMean + rightDarkMean ); 
        
    end
    
    % 1 hz-itude, 2 hz-itude
%     sinAxis = [1:52]'/fs;
%     cosVect_1 = cos(2*pi*sinAxis);
%     sinVect_1 = sin(2*pi*sinAxis);
%     cosVect_2 = cos(2*2*pi*sinAxis);
%     sinVect_2 = sin(2*2*pi*sinAxis);
%     shiftBy = min(leftNum,rightNum)-1;
%     dirNums = [ leftNum rightNum ];
%     for qp = 1:2
%         q = dirNums(qp);
%         for r = 1:2
%             magCut(:,qp,r) = norm(traces(inds{q}{r}(1:52),:));
%             cosProj_1(:,qp,r) = (traces(inds{q}{r}(1:52),:)'*cosVect_1)';
%             sinProj_1(:,qp,r) = (traces(inds{q}{r}(1:52),:)'*sinVect_1)';
%             oscPhase_1(:,qp,r) = atan(cosProj_1(:,qp,r)./sinProj_1(:,qp,r));
%             cosProj_2(:,qp,r) = (traces(inds{q}{r}(1:52),:)'*cosVect_2)';
%             sinProj_2(:,qp,r) = (traces(inds{q}{r}(1:52),:)'*sinVect_2)';
%             oscPhase_2(:,qp,r) = atan(cosProj_2(:,qp,r)./sinProj_2(:,qp,r));
%         end
%     end      
%     eval.oscPhase_1 = reshape(oscPhase_1,[nRoi 4])';
%     eval.oscPhase_2 = reshape(oscPhase_2,[nRoi 4])';
%     eval.oscMag_1 = sum(sum(cosProj_1.^2 + sinProj_1.^2,2),3)' ./ sum(sum(magCut.^2,2),3)';    
%     eval.oscMag_2 = sum(sum(cosProj_2.^2 + sinProj_2.^2,2),3)' ./ sum(sum(magCut.^2,2),3)';    
    
    %% Save everything
    eval.inds = inds;
    eval.controlEpochs = controlEpochs;
    eval.roiEval = roiEval;
    eval.sphere = sphere;
    eval.meanMethod = meanMethod;
    eval.threshLevel = threshLevel;
    eval.catList = catList;
    Z.eval = eval;
    
end

function meanOut = meanFunction(inMat,meanMethod,threshLevel)

    switch meanMethod
        case 'mean'
            meanOut = mean(inMat,1);
        case 'percentile'
            for q = 1:size(inMat,2)
                meanOut(1,q) = percentileThresh(inMat(:,q),threshLevel);
            end
    end

end