function numStr = StrGeneration_KernelOrRoiPerFly(n)
nfly = length(n);
numStr = [];
for ii  = 1:1:nfly
    if ii == 1
        numStr = num2str(n(ii));
    else
        numStr = [numStr,',',num2str(n(ii))];
    end
end
end