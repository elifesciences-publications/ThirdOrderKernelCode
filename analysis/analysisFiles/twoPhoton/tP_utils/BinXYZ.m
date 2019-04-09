function [binedx,binedy,binedz,n_x,n_y,n_z,binedz_sem, edgex, edgey] = BinXYZ(x,y,z,nbinsUsr, edge_distribution, clean_extreme_value_flag)

nbins = nbinsUsr;
% edgex should be changed to a fixed one now.....
% get rid of the extreme value.
if clean_extreme_value_flag
    ind_x_get_rid_of = (x > prctile(x,  100 - 100 * 10/length(x))) | (x < prctile(x, 100 * 10/length(x)));
    ind_y_get_rid_of = (y > prctile(y, 100 - 100 * 10/length(y))) | (y < prctile(y, 100 * 10/length(y)));
    ind_x_y_get_rid_of = ind_x_get_rid_of | ind_y_get_rid_of;
    
    x = x(~ind_x_y_get_rid_of);
    y = y(~ind_x_y_get_rid_of);
    z = z(~ind_x_y_get_rid_of);
end
max_x = max(abs(x));
max_y = max(abs(y));

if strcmp(edge_distribution,'linear')
    edgex = linspace(-max_x ,max_x,nbins(1)); % maximun value would not be appropriate. will it? it should be more symmetric
    edgey = linspace(-max_y,max_y,nbins(2));
    
elseif strcmp(edge_distribution,'histeq')
    % change the function 
    edgex = Bin_Edge_Histeq(x, nbins(1));
    edgey = Bin_Edge_Histeq(y, nbins(2));
end
[n_x,~,bins_x] = histcounts(x,edgex);
[n_y,~,bins_y] = histcounts(y, edgey);
% use bins_x and bins_y to arrange for bins_z
bins_z = (bins_y - 1) * nbins(1)+ bins_x;
% it is possible that not every bin will be filled. as long as there i
% fill x, y, z where there is nothing.
full_bins_z_range = 1:nbins(1) * nbins(2);
bins_z_range = unique(bins_z);
empty_z_bins = find(~ismember(full_bins_z_range,bins_z_range));

% you have to construct it as nan, and create corresponding z?
z = [z;nan(length(empty_z_bins),1)];
bins_z = [bins_z;empty_z_bins'];


% use sparse matrix
t_z = sparse(1:length(z),bins_z,z);

n_z = full(sum(t_z ~= 0));
% bin and average
mu = full(sum(t_z)./sum(t_z ~=0));
% bin and standard deviation, stderror of mean
sig = full(sum(t_z.^2)./sum(t_z ~= 0)) - mu.^2;
stadard_error_mean = sig./sqrt(n_z);

mu = reshape(mu,nbins);
sig = reshape(sig,nbins);
stadard_error_mean = reshape(stadard_error_mean,nbins);
n_z = reshape(n_z,nbins);

% middle point of the edge is the binedx
binedx = (edgex(1:end - 1) + edgex(2:end))/2;
binedy = (edgey(1:end - 1) + edgey(2:end))/2;
binedz = mu;
binedz_sem = stadard_error_mean;

end
