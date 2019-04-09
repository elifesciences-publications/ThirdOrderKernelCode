function [ matout ] = rollup( vector,depth )
%Rolls M x 1 vector into M x depth matrix where past time points lie along
%i coordinate. Returns a matrix of dims M-(depth-1) x Depth 

    len = length(vector);
    matout = zeros(depth,len-(depth-1));

    for q = 1:len-(depth-1)
        matout(:,q) = flipud(vector(q:q+depth-1));    
    end

end