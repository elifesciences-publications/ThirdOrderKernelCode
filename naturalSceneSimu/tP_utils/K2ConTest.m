function r = K2ConTest(f,s1,s2)
n = length(s1);
r = 0;
for i = 1:1:n
    for j = 1:1:n
        r = r + f(i,j)* s1(n-i + 1) * s2(n-j + 1);
    end
end