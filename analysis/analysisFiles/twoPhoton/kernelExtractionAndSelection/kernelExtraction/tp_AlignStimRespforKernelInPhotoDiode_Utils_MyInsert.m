function [x,y] = tp_AlignStimRespforKernelInPhotoDiode_Utils_MyInsert(x,x_,y,y_)
    % y is the original vector
    % want to insert y_ into y.
    % x_ is a array of value, which can be found in x. it tells me where
    % should I put each element of y into x.
    % x(2) = 4, x_(1) = 4 --> y(1) should be put after y(2).
    myinsert = @(a,ind,b) [a(1:ind);b;a(ind:end)];
    uniX_ = unique(x_);
    for ii = 1:1:length(uniX_)
        thisX_ = uniX_(ii);
        indStart = find(x == thisX_); 
        
        y = myinsert(y,indStart,y_(x_ == thisX_));
        x = myinsert(x,indStart,x_(x_ == thisX_));
    end
end