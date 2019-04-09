function [a,b,c] = MakeProj(abHeight,cHeight)
    % returns the indicies that would work with subplot to generate the
    % following
    %
    %          cWidth  
    %          /_ _\
    %         |  a  |\ abHeight
    %      _ _| _ _ |/
    %     |   |     |\
    %     |b  |  c  | > cWdith
    %     |_ _| _ _ |/
    %      \ / \_ _/
    % abHeight   cWidth
    % 
    % use: [subA,subB,subC] = makeProj(1,3);
    % subplot(4,4,subA);
    % plot(A);
    % subplot(4,4,subB);
    % plot(B);
    % subplot(4,4,subC);
    % plot(C);



    sideSize = abHeight + cHeight;
    a = [];
    b = [];
    c = [];
    
    for rr = 1:sideSize
        if rr <= abHeight
            a = [a ((rr-1)*sideSize+abHeight+1):(rr*sideSize)];
        end
        
        if rr > abHeight
            b = [b ((rr-1)*sideSize+1):((rr-1)*sideSize+abHeight)];
            c = [c ((rr-1)*sideSize+1+abHeight):(rr*sideSize)];
        end
    end
end