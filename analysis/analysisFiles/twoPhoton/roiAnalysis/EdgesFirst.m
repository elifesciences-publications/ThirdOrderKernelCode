function [resp,respLinear,stimMat] = EdgesFirst(kernel,doLN,poly2_coe,lookUpTable,softRectificationCoe,LNType,edgeTypeVC,nBarUse,barWidth,grayStartFlag)
% for the edge response, instead of giving out mean response, gives out
% traces...
% nBarUse = 20;
T = 400; % T is the total length of the stimulus, not the second... T will be
T_Transient = 100;
r0 = 0.1;
% when you calculate things, get rid of that....
% response;
nEdges = size(edgeTypeVC,1);
firstResp = zeros(T,nBarUse,nEdges);
firstRespSum = zeros(T,1,nEdges);
stimMat = zeros(T,nBarUse,nEdges);
for ii = 1:1:nEdges
    velocity = edgeTypeVC(ii,1);
    contrastPolarity = edgeTypeVC(ii,2);
    
    % set the initial stimulus to be zeros.
    xt =  MovingEdgeGeneration_Juyue(velocity,contrastPolarity,T,T_Transient,nBarUse,barWidth,grayStartFlag);
    
    for q = 1:1:nBarUse
        [firstResp(:,q,ii)] =  filter(kernel(:,q),1,xt(:,q));
        % ARMA1D_Pred_Stim(xt(:,q),kernel(:,q));
    end
    stimMat(:,:,ii) = xt;
    firstRespSum(:,1,ii) = sum(firstResp(:,:,ii),2);
end
if doLN
    % there are three ways to do this nonlinearity.
    switch LNType
        case 'rectification'
            respRec = MyRectification(firstRespSum);
            resp = respRec;
        case 'square'
            respSqu = firstRespSum.^2;
            resp = respSqu;
        case 'coe'
            respCoe = MyLN_Coe(firstRespSum,poly2_coe,lookUpTable);
            resp = respCoe;
        case 'nonp'
            respNonParametric = MyLN_LookUpTable(firstRespSum,lookUpTable);
            resp = respNonParametric;
        case 'softRectification'
            respSoftRec = MyLN_SoftRectification(firstRespSum,softRectificationCoe);
            resp =  respSoftRec;
    end
else
    resp = firstRespSum;
    %     meanResp = mean(resp ,1);
    %     scintillatorPlot;
    
end
resp = squeeze(resp);
respLinear = squeeze(firstRespSum);
%% linear summatio of the response.
% meanResp = squeeze(meanResp);
end