function C = MyBsxFun_ArrayByArray(myfun,A,b)
    % calculate fun(A(:,i),b)
    A = mat2cell(A,size(A,1),ones(1,size(A,2)));
    % expand B to a larger one...
    B = {b}; B = repmat(B,[1,size(A,2)]);
    % cellfun is dangerous? arrayfun is dangerous?
    C = cellfun(myfun,A,B)';
    
end