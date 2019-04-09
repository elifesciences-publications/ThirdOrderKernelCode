function trace_shift = MyHHCA_Untils_CombineNearest_Utils_Check_Shift(pairlist, edgeTrace)
for pp = 1:1:n_pair
    obj_1 = pairlist(pp,1);
    obj_2 = pairlist(pp,2);    
    trace_1 = edgeTrace(:,pairlist(pp,1)); % use the non_smoothed version
    trace_2 = edgeTrace(:,pairlist(pp,2));
    
    % use the cross correlation?
    a = xcorr(trace_1, trace_2); 
    lag = MyHHCA_Untils_CombineNearest_Utils_Check_Shift_OnePair(trace_1, trace_2);
    % triggering point?
    
    
    
end
end