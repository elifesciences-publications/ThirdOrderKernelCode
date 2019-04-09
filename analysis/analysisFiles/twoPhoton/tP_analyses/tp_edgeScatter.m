function tp_edgeScatter( Z )
% Takes the output of tp_roiEval and creates scatter plots comparing the
% edge selectivity of ROIs. Prints correlation coefficients.
    % Inputs:
    %   Z: the structure containing filtered traces for the ROIs you wish
    %   evauluate. ASSUMES THAT tp_roiEval HAS BEEN RUN.

    %% Parameters
    % careful if you decide to turn these on!
    discardOutliers = 0; % discard points more than 3 standard deviations 
                         % from the mean activity of that epoch type. 
    discardWeak = 0; % discard ROIs in the bottom (weakThreshLevel)th 
                     % percentile of direction selectivity.  
    weakThreshLevel = .9; % See discardWeak
    
    loadFlexibleInputs(Z);   
    
    nRoi = length(Z.eval.roiEval);
        
    %% Find where in the controlEpochs vector these four edge types are
    % located.  
    leftBrightNum = find(strcmp(Z.eval.controlEpochs,'Left Light Edge'));
    leftDarkNum = find(strcmp(Z.eval.controlEpochs,'Left Dark Edge'));
    rightBrightNum = find(strcmp(Z.eval.controlEpochs,'Right Light Edge'));
    rightDarkNum = find(strcmp(Z.eval.controlEpochs,'Right Dark Edge'));
 
    %% Average the rawMeans output of tp_roiEval to combine repeated 
    % presentations of the same epoch. Remember that each control epoch is
    % shown twice, and rawMeans is calculaed separately for each
    % presentation. 
    means = zeros(4,nRoi); % edge type first dimension, ROI second dimension
    outlierVect = zeros(4,nRoi); % this variable keeps track of which ROIs
                                 % are far from the mean activity for the
                                 % given control epoch (first dim) in case
                                 % you want to use it to discard outliers. 
    
    for q = 1:4 % looping over edge types
        numAppearances = size(Z.eval.rawMeans,2); % presentations along 2nd dim of rawMeans
        for r = 1:numAppearances
            means(q,:) = means(q,:) + Z.eval.rawMeans{q,r} / numAppearances;
        end
        % put a 1 in outlierVect(A,B) if the average of the Bth ROI for
        % edge type A is more than three standard deviations away from the
        % mean. 
        if discardOutliers
            sts(q) = std(means(q,:));
            outlierVect(q,:) = (abs(means(q,:) - mean(means(q,:))) > 3*sts(q));
        end                
    end
    
    % discard weak ROIs
    if discardWeak
        weakThresh = percentileThresh(abs(Z.eval.direction_selectivity),weakThreshLevel); 
            % find the numerical value that corresponds to the
            % (weakThreshLevel)th percentile of direction selectivity
            % absolute value.
        weakVect = abs(Z.eval.direction_selectivity) < weakThresh;
            % determine which ROIs fall below this threshold of direction
            % selectivity. 
        weakVect = repmat(weakVect,[4 1]);
            % duplicate this vector 4 times along the first dimension to
            % match dimensions of outlierVect.
    else
        weakVect = zeros(size(outlierVect));
    end
    
    %% Apply the outlierVect and weakVect to eliminate ROIs. Counter-
    % intuitively, outlierVect(A) = 1 if roi #A is /retained/ (not if it's
    % an outlier). 
    outlierVect = sum(outlierVect + weakVect,1);
    outlierVect = ~outlierVect; % ROIs you keep
    meansTrimmed = means(:,outlierVect);
    roiUseTrimmed = Z.eval.roiEval(:,outlierVect);
    
    %% Plot some of these means against each other to make scatter plots. 
    
    MakeFigure
           
    % this part of the code determines the color that each point in the
    % scatter plot will be. The system it uses for doing this depends on
    % the ROI extraction method. If these ROIs were extracted using
    % edgeTypeRoi, then Z.ROI.typeFlag will exist (since this is an output
    % of edgeTypeRoi). Therefore, we color code by the types as assigned in
    % edgeTypeRoi. If the ROIs were selected by another method, this
    % variable will not exist. In that case, we color-code the dots by the
    % categories determined in Z.eval. 
    if isfield(Z.ROI,'typeFlag')
        colorCode = Z.ROI.typeFlag(outlierVect);
        colorMax = max(colorCode);
        colorMin = min(colorCode);
    elseif isfield(Z.eval,'category_force')
        colorCode = Z.eval.category_force(outlierVect);
        colorMax = max(colorCode);
        colorMin = min(colorCode);
    end   
    
    % assign the string saying what units the activity is in. This depends
    % on the method chosen in eval (meanMethod) - averaging or percentile. 
    switch Z.eval.meanMethod
        case 'mean'
            unit = 'avg \DeltaF/F';
        case 'percentile'
            unit = [ num2str(Z.eval.threshLevel*100) 'th percentile \DeltaF/F'];
    end
    
    % if the traces were sphered in Z.eval, append "sphered" to the unit
    % string to indicate that these means are not in natural units.
    if Z.eval.sphere
        unit = [ unit ' sphered' ];
    end
    
    %% Create Scatter Plots (2 x 2 grid)
    
    % left bright means versus left dark means
    subplot(2,2,1);
    scatter(meansTrimmed(leftBrightNum,:),meansTrimmed(leftDarkNum,:),[],colorCode);
    set(gca,'Clim',[colorMin colorMax]);
    title([ 'bright L v dark L' ]); %axis equal;
    xlabel(['Left Bright (' unit ')']); ylabel(['Left Dark (' unit ')']);

    % right bright means versus right dark means
    subplot(2,2,3);
    scatter(meansTrimmed(rightBrightNum,:),meansTrimmed(rightDarkNum,:),[],colorCode);
    set(gca,'Clim',[colorMin colorMax]);
    title([ 'bright R v dark R' ]); %axis equal;
    xlabel(['Right Bright (' unit ')']); ylabel(['Right Dark (' unit ')']);
    
    % total bright (L+R) versus total dark (L+R)
    subplot(2,2,2);
    scatter(Z.eval.bright_left_plus_right(outlierVect),Z.eval.dark_left_plus_right(outlierVect),[],colorCode);
    set(gca,'Clim',[colorMin colorMax]);
    title('T4itude vs T5itude');
    xlabel(['Bright Response L+R (' unit ')']);
    ylabel(['Dark Response L+R (' unit ')']);
    
    % edge index ((Bright-Dark)/(Bright+Dark)) left versus right
    subplot(2,2,4);
    scatter(Z.eval.bright_min_dark_left_over_sum(outlierVect),Z.eval.bright_min_dark_right_over_sum(outlierVect),[],colorCode);
    title('Edge Index left versus right');
    xlabel(['Edge Index Left (B-D/B+D)']);
    ylabel(['Edge Index Right (B-D/B+D)']);
    
end

