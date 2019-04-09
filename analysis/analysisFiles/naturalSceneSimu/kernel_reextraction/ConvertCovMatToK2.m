function kernel_2o_dx1 = ConvertCovMatToK2(kernel_2o, nMultiBars)
% This is a particular
maxTau = round(size(kernel_2o, 1)/nMultiBars);
kernel_2o_dx1 = zeros(maxTau, maxTau);
kernel_2o = mat2cell(kernel_2o, ones(1,nMultiBars) * maxTau, ones(1,nMultiBars) * maxTau);
% you should have four things to averaged out.that is so true..
for qq = 1:1:nMultiBars
    kernel_2o_dx1 = kernel_2o_dx1 + kernel_2o{qq, mod(qq, nMultiBars) + 1};
end
kernel_2o_dx1 = kernel_2o_dx1/nMultiBars;

end