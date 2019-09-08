function r = K2ConTest(f,s1,s2)
n = length(s1);
r = zeros(n, 1);
maxTau = size(f, 1);
for tt = maxTau:1:n
    for i = 1:1:maxTau
        for j = 1:1:maxTau
            r(tt) = r(tt) + f(i,j)* s1(tt - i + 1) * s2(tt - j + 1);
        end
    end
end
% testing funtion for filter calculation
