function [roiSelected] = RoiSelectionByProbingStimulus(cfRoi,varargin)
% roiSelectedCorrPeakConsist = RoiSelectionByProbingStimulus(cfRoi,'method','CorrPeakConsistency','classInterested',1);
% ('threshMainTypeCorr',0.1,'method','primilinary_corr')
% ('method', 'preliminary_DSI_Diff','threshDSI_Diff',0.3);
% ('method','preliminary_LDSI','threshLDSI',0.2);
% ('method','preliminary_DSI_Diff_LDSI','threshDSI_Diff_Add_LDSI',0.4);
% give out the roi, based on your creteria.
% good roi: responsive to its own edge, do not response to other edges.
% input :
% cfRoi: self-correlation, peak response, ESI,DSI, stimulus/eye
% coordinates.
% method: select roi based on self-correlation(corr) or self-correlation + ESI of peak(corrPeak)
% classInterested == 2; % responsive to two edges.
% classInterested == 1; % responsive to only one edge

% large enought to be considered as a good roi.
threshMainTypeCorr = 0.6;
threshMainTypeESI = 0.6;

% the response tp the second selective edge should be large enough to be double selective.
threshSecTypeCorr = 0.4;
threshSecTypeESI = 0.4;

% the second selective edge could not be very large for that roi to be
% considered as a one type selective cell.
threshExcluCorr = 0.3;
threshESIExclu = 0.3;

% use DSI to throw out some neurons.
threshDSI = 0.55;

% use correlation to throw out some neurons.
threshCorr = 0.15;

% use peak response index to throw out some neurons.
threshESI = 0.3; % max one should be larger 0.3

threshDSI_Diff = 0.3;
threshDSI_Edge = 0.2;
threshDSI_Edge_Add_LDSI = 0.4;

threshLDSI= 0.2;
threshDSI_Diff_Add_LDSI = 0.4;

threshRepeatability = 0.1;
method = 'corrOnly'; % 'preliminary_peak','preliminary_corr','preliminary_DSI','corrOnly', 'corrPeak','CorrPeakConsistency'
classInterested = 1;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

roiCorrValue = cfRoi.CCStim.value(:,1:4);
roiPeakESI = cfRoi.PStim.ESI(:,1:4);
roiDSI = cfRoi.PEye.DSI;
roiDSI_Diff = cfRoi.PEye.DSI_Diff(:,1);
roiDSI_Edge = cfRoi.PEye.DSI_Edge;
roiLDSI_PreferedDir = cfRoi.PEye.LDSI_PreferedDir; % because you are using wrong thing.. you have to rerun everything tonight.
leftRightFlag = cfRoi.PStim.leftRightFlag;
roiR = cfRoi.repeatability.wholeProb;

nRoi = size(roiCorrValue,1);
roiClass = zeros(nRoi,1);
switch method
    case 'preliminary_corr'
        maxCorrValue = max(roiCorrValue,[],2);
        roiSelected = maxCorrValue > threshCorr;
        
    case 'preliminary_peak'   
        maxESI = max(roiPeakESI,[],2);
        roiSelected = maxESI > threshESI ;
        
    case 'preliminary_DSI' % direction selectivity for four square waves.      
        roiSelected = max(roiDSI,[],2) > threshDSI;
        
    case 'preliminary_DSI_Diff'
        roiSelected = abs(roiDSI_Diff) > threshDSI_Diff;
        
    case 'preliminary_LDSI'
        roiSelected = abs(roiLDSI_PreferedDir) > threshLDSI;
        
    case 'preliminary_DSI_Diff_LDSI'
        roiSelected = (abs(roiDSI_Diff) + abs(roiLDSI_PreferedDir)) > threshDSI_Diff_Add_LDSI;
    
    case 'preliminary_LeftRight_Only'
        roiSelected = leftRightFlag;
    
    case 'preliminary_DSI_Edge'
        roiSelected = abs(roiDSI_Edge) > threshDSI_Edge;
        
    case 'preliminary_DSI_Edge_LDSI'
         roiSelected = (abs(roiDSI_Edge) + abs(roiLDSI_PreferedDir)) > threshDSI_Edge_Add_LDSI;
    
    case 'preliminary_repeatability'
         roiSelected = roiR > threshRepeatability;
         
    case 'corrOnly'
        for rr = 1:1:nRoi
            maxCorrValue = max(roiCorrValue(rr,:));
            temp= sort(roiCorrValue(rr,1:4),'descend');
            maxSecCorrValue = temp(2);
            
            % what would be the first class? good roi, and does not
            % response to other class.
            if maxCorrValue > threshMainTypeCorr && maxSecCorrValue < threshExcluCorr
                roiClass(rr) = 1;
            end
            if maxCorrValue > threshMainTypeCorr && maxSecCorrValue > threshSecTypeCorr
                roiClass(rr) = 2;
            end
            
        end
        roiSelected = roiClass == classInterested;
        
        %% use the peak response as the second method...
    case 'corrPeak'
        for rr = 1:1:nRoi
            
            maxCorrValue = max(roiCorrValue(rr,:));
            temp= sort(roiCorrValue(rr,:),'descend');
            maxSecCorrValue = temp(2);
            
            maxESIValue= max(roiPeakESI(rr,:));
            temp= sort(roiPeakESI(rr,:),'descend');
            maxSecESIValue = temp(2);
            
            if maxCorrValue > threshMainTypeCorr && maxESIValue > threshMainTypeESI
                if maxSecCorrValue < threshExcluCorr && maxSecESIValue <  threshESIExclu
                    roiClass(rr) = 1;
                elseif maxSecCorrValue < threshSecTypeCorr && maxSecESIValue >  threshSecTypeESI
                    roiClass(rr) = 2;
                end
            end
            
        end
        
        roiSelected = roiClass == classInterested;
    case 'CorrPeakConsistency'
        % direction selectivity obtained from square wave does not always match the direction selectivity obtained from moving edge
        % exclude those...
        % use the PStim. Left Square should have Left Light and Left
        % Dark(1,3). Right Square should have Right Light and Right Darl(2,4)
        %
        
        dirType = cfRoi.PStim.dirType;
        edgeType = cfRoi.PStim.edgeType;
        
        leftRoiDir = dirType == 1;
        leftRoiEdge = edgeType == 1 | edgeType == 3;
        rightRoiDir = dirType == 2;
        rightRoiEdge = edgeType == 2 | edgeType == 4;
        
        roiLeftPeak = leftRoiDir & leftRoiEdge;
        roiRightPeak = rightRoiDir & rightRoiEdge;
        
        % the one from the correlation might be hard for some rio.
        % how do you tell the difference? are you missing out some good
        % rois by using this creteria?
        dirType = cfRoi.CCStim.dirType;
        edgeType = cfRoi.CCStim.edgeType;
        
        leftRoiDir = dirType == 1;
        leftRoiEdge = edgeType == 1 | edgeType == 3;
        rightRoiDir = dirType == 2;
        rightRoiEdge = edgeType == 2 | edgeType == 4;
        
        roiLeftCorr = leftRoiDir & leftRoiEdge;
        roiRightCorr = rightRoiDir & rightRoiEdge;
        
        % if the peak and the corr gives out same result.
        roiLeft = roiLeftCorr & roiLeftPeak;
        roiRight = roiRightCorr & roiRightPeak;
        roiSelected = roiLeft | roiRight;
        
    case 'dirEdgeConsistency'
        dirType = cfRoi.PStim.dirType;
        edgeType = cfRoi.PStim.edgeType;
        
        leftRoiDir = dirType == 1;
        leftRoiEdge = edgeType == 1 | edgeType == 3;
        rightRoiDir = dirType == 2;
        rightRoiEdge = edgeType == 2 | edgeType == 4;
        
        roiLeft = leftRoiDir & leftRoiEdge;
        roiRight = rightRoiDir & rightRoiEdge;
        roiSelected = roiLeft | roiRight;
        
        
end

