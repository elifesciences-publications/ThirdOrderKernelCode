function [ glidSign,disp2,disp3 ] = glidDispToCov( dx1,dx2,dt1,dt2 )
% Interprets between glidDisp and glidCovmat/glidAxes

if dx1 == 1 && dx2 == 1
        glidSign = +1;
        if dt1 > dt2
            disp2 = dt1-dt2;
            disp3 = -dt2;
        else
            disp2 = dt2-dt1;
            disp3 = -dt1;
        end
    else
        glidSign = -1; 
        if dx1 == 1
            disp2 = dt2;
            disp3 = dt1;
        elseif dx2 == 1
            disp2 = dt1;
            disp3 = dt2;
        else
            error('dx1 or dx2 should = 1');
        end      
end   

end

