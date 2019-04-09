function predResp = Kernel_Pred_OLS_AllBar_Linear(stim,k)
nMultiBars = length(stim);
nT = size(stim{1},1);
predResp = zeros(nT,nMultiBars);

for qq = 1:1:nMultiBars
    predResp(:,qq) = stim{qq} * k(:,qq);
end

predResp = sum(predResp,2);

end
