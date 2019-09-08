function kernel_string_counterpart = kernel_path_management_utils_3okernel_string_mirror(kernel_string)
% one at a time... even though you are using them together
% first, if there is minus sign, change it to n

kernel_string(kernel_string == 'n') = '-';

%% do sign transition directly.
str_temp = strsplit(kernel_string,'_');
dx = zeros(1,2);
dx(1) = str2double(str_temp{2});
dx(2) = str2double(str_temp{3});

dx_mirror = -dx;
str_temp_mirror = strsplit(num2str(dx_mirror));
kernel_string_counterpart = strjoin({str_temp{1},str_temp_mirror{:}},'_');

% if there is minus sign, change it to n
kernel_string_counterpart(kernel_string_counterpart == '-') = 'n';
end