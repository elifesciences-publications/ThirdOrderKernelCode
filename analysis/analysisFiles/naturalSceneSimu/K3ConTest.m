function r = K3ConTest(f,s1,s2)
N = length(s1);
r = zeros(N,1);
maxTau = size(f, 1);
for n = maxTau:1:N
    for i = 1:1:maxTau
        for j = 1:1:maxTau
            for k = 1:1:maxTau
                r(n) = r(n) + f(i,j,k)* s1(n - i + 1) * s1 (n - j + 1)* s2(n - k + 1);
%                 disp(f(i,j,k))
%                 disp(s1(n - i + 1) * s1 (n - j + 1))
%                 disp(s2(n - k + 1))
                r(n) = r(n) + f(i,j,k)* s1(n - i + 1) * s1 (n - j + 1)* s2(n - k + 1);
            end
        end
    end
end
% testing funtion for filter calculation
