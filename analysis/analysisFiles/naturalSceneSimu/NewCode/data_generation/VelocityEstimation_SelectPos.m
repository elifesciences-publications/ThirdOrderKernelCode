function pos = VelocityEstimation_SelectPos(colum_pos_reference, varargin)
space_range = 54;
spatial_dist = 13;
% synthetic_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% first randomly choose a location.
n_hor = 927;
% if synthetic_flag
%     colum_pos_reference = 1;
% else
%     %% here you have to predefine the position.
%     colum_pos_reference = randi(n_hor);
% end

pos = colum_pos_reference + [0:1:space_range - 1]' * spatial_dist;
pos = mod(pos - 1, n_hor) + 1; % periodic 360 degree.
end
