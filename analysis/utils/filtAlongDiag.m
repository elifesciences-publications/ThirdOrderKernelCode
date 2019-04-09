function K_filt = filtAlongDiag( K, filt )
% Blur a 2d array along lines parallel to the main diagonal.

    M = size(K,1);
    
    for d = 0:M % indexing from zero means diagonal is repeated, but
                % this should not cause an issue - writes over, not added.
        thisTraceAbove = [];
        thisTraceBelow = [];
        for i = 1:M-d 
            thisTraceAbove = cat(1,thisTraceAbove,K(i,i+d));
            thisTraceBelow = cat(1,thisTraceBelow,K(i+d,i));
        end
        thisTraceAboveFilt = filter(filt,1,thisTraceAbove);
        thisTraceBelowFilt = filter(filt,1,thisTraceBelow);
        for i = 1:M-d
            K_filt(i,i+d) = thisTraceAboveFilt(i);
            K_filt(i+d,i) = thisTraceBelowFilt(i);
        end
    end

end

