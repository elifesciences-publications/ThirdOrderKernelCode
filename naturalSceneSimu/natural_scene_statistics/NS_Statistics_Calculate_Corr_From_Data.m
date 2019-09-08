function stim_corr_value = NS_Statistics_Calculate_Corr_From_Data(data, varargin)
corr_name = {'Two Point DT 1','Two Point DT 2', 'Two Point DT 3','Two Point DT 4',...
    'Diverging DT 1','Diverging DT 2','Diverging DT 3','Diverging DT 4',...
    'Converging DT 1','Converging DT 2', 'Converging DT 3','Converging DT 4',...
    'Elbow','Late Knight','Early Knight','Elbow Late Break','Elbow Early Break'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
n_corr = length(corr_name);

if size(data.stim, 2) == length(data.column_pos)
    stim = data.stim;
else
    stim = data.stim(:,data.column_pos);
end

[nt,nx] = size(stim);
stim_corr_value = zeros(nx -1, n_corr, 2);
direction_vec = [1,-1]; % 1 is the same as glider
for ii = 1:1:n_corr
    [dx, dt] = K3_Glider_Trans_Utils_Name_To_TauDx(corr_name{ii});
    for dd = 1:1:2
        dx = dx * direction_vec(dd);
        ind_t = create_ind_for_three_points(nt,dt,'t');
        ind_x = create_ind_for_three_points(nx,dx,'x');
        stim_value_this = ones(size(ind_t,1), size(ind_x,1)); % size(ind_t, 2) is 2/3. order of the kernel.
        for jj = 1:1:size(ind_t,2)
            stim_value_this = stim_value_this .* stim(ind_t(:,jj), ind_x(:,jj));
        end
        stim_corr_value(:,ii,dd) = mean(stim_value_this, 1);
    end
end
end
%% 
function ind = create_ind_for_three_points(n,d, mode)
if strcmp(mode,'t')
    d = - d;
end

ind_all = bsxfun(@plus, (1:n)', [0,d]);
min_starting_point = min(ind_all,[],2);
starting_ind = min_starting_point >= 1;
max_ending_point = max(ind_all, [],2);
ending_ind = max_ending_point <= n;

ind = ind_all(starting_ind & ending_ind, :);
end