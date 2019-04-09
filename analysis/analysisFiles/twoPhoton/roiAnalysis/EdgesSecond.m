function meanresp = EdgesSecond(kernel,edgeTypeVC,barWidth,plotFlag)
% doLN = 0;
% coe = 0;
% LNType = 'Rectification';
% attention...
%
% nBarUse = 20;
T = 720; % T is the total length of the stimulus, not the second...
T_transient = 1;% around 3 times larger than the length of the filter, should be larger enough. same for the second order filter....
% when you calculate things, get rid of that....
% response;
nEdges = size(edgeTypeVC,1);
nBarUse = 2;
% response;
resp = zeros(T,nEdges);
stimMat = zeros(T,nBarUse,nEdges);

for ii = 1:1:nEdges
    velocity = edgeTypeVC(ii,1);
    contrastPolarity = edgeTypeVC(ii,2);
    xt =  MovingEdgeGeneration_Juyue(velocity,contrastPolarity,T,nBarUse,barWidth);
    
    resp(:,ii) = ARMA2D_Pred_Stim(xt(:,1),xt(:,2),kernel);
    stimMat(:,:,ii) = xt;
    resp(1:T_transient,ii) = 0;
end
% meanResp = mean(resp,1);
%
% meanResp = squeeze(meanResp);
resp = squeeze(resp);
meanresp = mean(resp,1);
%% linear summatio of the response.

% if plotFlag
%     yLimMax = max(abs(firstRespSum(:)));
%     
%     
%     MakeFigure;
%     suplotNumStim = [1,3,5,7];
%     titleStr = {'left light','right light','left dark','right dark'};
%     for qq = 1:1:4
%         subplot(4,2,suplotNumStim(qq));
%         imagesc(stimMat(:,:,qq));
%         title(titleStr{qq})
%     end
%     subpotNumResp = [2,4,6,8];
%     for qq = 1:1:4
%         subplot(4,2,subpotNumResp(qq));
%         plot(squeeze(firstRespSum(:,1,qq)));
%         ylim([-yLimMax,yLimMax]);
%     end
% end

end