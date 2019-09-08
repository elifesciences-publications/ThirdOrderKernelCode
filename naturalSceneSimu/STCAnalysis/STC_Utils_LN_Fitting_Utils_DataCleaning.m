function x_use = STC_Utils_LN_Fitting_Utils_DataCleaning(x,p)
d = size(x,2);
n = size(x,1);

perctileThresh = zeros(2,d);
perctileThresh(1,:) =  prctile(x, p, 1);
perctileThresh(2,:) =  prctile(x, 100 - p, 1);

% calculate where is the bound?
ind_use = zeros(n,d);
for ii = 1:1:d
    ind_use(:,ii) = x(:,ii) >  perctileThresh(1,ii) & x(:,ii) < perctileThresh(2,ii);
end

ind_use_all = sum(ind_use, 2) >= 3;

x_use = x(ind_use_all,:);

end
