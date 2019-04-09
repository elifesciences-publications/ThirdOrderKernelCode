% of course, you can do this on signle roi basis,
% on the other hand, you should be able to do this on fly basis. which way
% do you want to do?
function nlessOrEqual = KernelSelectoin_MultiD_1o_draft(kernel, kernel_shuffled)

[maxTau,nMultiBars] = size(kernel);
% regard each bar as an individual thing.
kernel_shuffled = reshape(kernel_shuffled,maxTau,[]);
D = mahal([kernel';kernel_shuffled'],kernel_shuffled');
kernelD_Bar = D(1:nMultiBars); kernelD_Sum = sum(kernelD_Bar);
kernelShuffleD_Bar = D(nMultiBars+1:end);
nShuffle = size(kernel_shuffled,2);
% you need a seed and you need to sum them together..
rng(0);
nShuffleSum = 10000;
kernelShuffleD_Sum = zeros(nShuffleSum,1);
for ii = 1:1:nShuffleSum
    kernelShuffleD_Sum(ii) = sum(kernelShuffleD_Bar(randi([1 nShuffle],[1,nMultiBars])));
end
nlessOrEqual = sum(kernelShuffleD_Sum <  kernelD_Sum | kernelShuffleD_Sum == kernelD_Sum);
end