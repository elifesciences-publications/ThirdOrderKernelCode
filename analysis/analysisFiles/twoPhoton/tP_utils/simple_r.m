function r = simple_r( a,b )

    if size(a,1) < size(a,2)
        a = a';
    end
    
    if size(b,1) < size(b,2)
        b = b';
    end
        
    a = a - mean(a);
    b = b - mean(b);
    
    r = a'*b/sqrt(a'*a*b'*b);

end

