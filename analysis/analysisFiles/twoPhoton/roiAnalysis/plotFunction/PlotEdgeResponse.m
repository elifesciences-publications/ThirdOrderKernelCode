function PlotEdgeResponse(resp,respLinear,stim)
MakeFigure;
% the stimulus
suplotNumStim = [1,6,11,16];
titleStr = {'left light','right light','left dark','right dark'};
for qq = 1:1:4
    subplot(4,5,suplotNumStim(qq));
    imagesc(stim(:,:,qq));
    colorbar
    title(titleStr{qq})
end

% the linear response/.
suplotNumRespLinear = [2,7,12,17];
yLimMax = max(max(abs(respLinear(:)),abs(resp(:))));
for qq = 1:1:4
    subplot(4,5,suplotNumRespLinear(qq));
    plot(squeeze(respLinear(:,qq)));
    ylim([-yLimMax,yLimMax]);
    if qq == 1
        title('linear response');
    end
end% end
%
subpotNumResp  = [3,8,13,18];
for qq = 1:1:4
    subplot(4,5,subpotNumResp (qq));
    plot(squeeze(resp(:,qq)));
    ylim([-yLimMax,yLimMax]);
    if qq == 1
        title('non linear response');
    end
end

timeSlot = roiAnalysis_OneRoi_Edge_CalRelavantTime(respLinear);
suplotNumRespLinear = [4,9,14,19];
yLimMax = max(max(abs(respLinear(:)),abs(resp(:))));
for qq = 1:1:4
    subplot(4,5,suplotNumRespLinear(qq));
    plot(squeeze(respLinear(:,qq).* timeSlot ));
    ylim([-yLimMax,yLimMax]);
    if qq == 1
        title('linear response');
    end
end% end
%
subpotNumResp  = [5,10,15,20];
for qq = 1:1:4
    subplot(4,5,subpotNumResp (qq));
    plot(squeeze(resp(:,qq).* timeSlot));
    ylim([-yLimMax,yLimMax]);
    if qq == 1
        title('non linear response');
    end
end
% 
% titleStr = {'light:(L-R)','light:(R-L)','dark:(L-R)','dark:(R-L)'};
% respLinearDiff = roiAnalysis_OneRoi_Edges_LeftMinusRight(respLinear);
% yLimMax = max(max(abs(respDiff(:)),abs(respLinearDiff(:))));
% 
% subpotNumRespLinearDiff = [4,9,14,19];
% for qq = 1:1:4
%     subplot(4,5,subpotNumRespLinearDiff(qq));
%     plot(squeeze(respLinearDiff(:,qq)));
%     ylim([-yLimMax,yLimMax]);
%     if qq == 1
%         title([titleStr{qq},' linear']);
%     else
%         title([titleStr{qq}]);
%     end
%     
% end% end
% 
% subpotNumRespDiff = [5,10,15,20];
% for qq = 1:1:4
%     subplot(4,5,subpotNumRespDiff(qq));
%     plot(squeeze(respDiff(:,qq)));
%     ylim([-yLimMax,yLimMax]);
%     if qq == 1
%         title('non linear ');
%     end
% end% end
end