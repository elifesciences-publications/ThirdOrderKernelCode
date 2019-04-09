function C = MyLoop_ArrayByArray(myfun,A,b)
    N = size(A,2);
    C = zeros(N,1);
    for ii = 1:1:N
        C(ii) = myfun(A(:,ii),b);
    end
end