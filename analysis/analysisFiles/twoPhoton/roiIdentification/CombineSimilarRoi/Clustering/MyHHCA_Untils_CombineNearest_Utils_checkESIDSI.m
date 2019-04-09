function ESI_DSI_NONDEC = MyHHCA_Untils_CombineNearest_Utils_Check_ESIDSI(pairlist, edgeTrace, roiMask, objectName) % relative object sequence.
n_pair = size(pairlist,1);
ESI_DSI_NONDEC = false(n_pair,2);
tic
for pp = 1:1:n_pair
    obj_1 = pairlist(pp,1);
    obj_2 = pairlist(pp,2);
    obj_size_1 = sum(sum(roiMask == objectName(obj_1)));
    obj_size_2 = sum(sum(roiMask == objectName(obj_2)));
    
    trace_1 = edgeTrace(:,pairlist(pp,1)); % use the non_smoothed version
    trace_2 = edgeTrace(:,pairlist(pp,2));
    
    trace_c = (trace_1 * obj_size_1 + trace_2 * obj_size_2)/(obj_size_1 + obj_size_2); % c stands for "combine"
    
    [ESI_1, DSI_1] = MyHHCA_Untils_ESIDSI_Calculation(trace_1);
    [ESI_2, DSI_2] = MyHHCA_Untils_ESIDSI_Calculation(trace_2);
    [ESI_c, DSI_c] = MyHHCA_Untils_ESIDSI_Calculation(trace_c);
    % find a function to compute the 
    ESI_max = max(abs([ESI_1, ESI_2]));
    DSI_max = max(abs([DSI_1, DSI_2]));
    ESI_DSI_NONDEC(pp,:) = [abs(ESI_c) >= ESI_max, abs(DSI_c) >= DSI_max];
end
toc


% still cannot believe in it. how come?
% MakeFigure;
% for pp = 1:1:n_pair
%      obj_1 = pairlist(pp,1);
%     obj_2 = pairlist(pp,2);
%     obj_size_1 = sum(sum(roiMask == objectName(obj_1)));
%     obj_size_2 = sum(sum(roiMask == objectName(obj_2)));
%     
%     trace_1 = edgeTrace(:,pairlist(pp,1)); % use the non_smoothed version
%     trace_2 = edgeTrace(:,pairlist(pp,2));
%     
% 
%     plot(trace_1);
%     hold on
%     plot(trace_2);
%     hold off
% end
end