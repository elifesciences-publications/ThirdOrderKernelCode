function r = K3ConTest(f,s1,s2,s3)
n = length(s1);
r = 0;
maxTau = size(f,1);
% last second.
for i = 1:1:maxTau
    for j = 1:1:maxTau
        for k = 1:1:maxTau
            r = r + f(i,j,k)* s1(n - i + 1) * s2 (n - j + 1)* s3(n - k + 1);
        end
    end
end