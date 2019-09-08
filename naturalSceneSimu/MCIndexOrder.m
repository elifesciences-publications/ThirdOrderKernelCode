function w = MCIndexOrder()
w = zeros(70,4);
count  = 0;
for i = 0:1:4
    for j = 0:1:4-i
        for k = 0:1:4-i-j
            for l = 0:1:4 - i - j - k
                count = count + 1;
                w(count,:) = [i,j,k,l];
            end
        end
    end
    
end