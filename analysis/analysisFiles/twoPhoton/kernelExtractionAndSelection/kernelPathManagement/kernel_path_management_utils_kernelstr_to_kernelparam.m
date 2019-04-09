function  kernel_param = kernel_path_management_utils_kernelstr_to_kernelparam(kernel_string)

% this should be changed... how do you want to do it?
% first, rewrite kernels, and update your roi kernels...
n = length(kernel_string);
% I want this to be a struct array.
kernel_param = struct('order', cell(n,1),'noise',cell(n,1),'maxTau',cell(n,1),'dx', cell(n,1));
for ii = 1:1:n
    % have a look up table.
    kernel_string_this = kernel_string{ii};
    switch kernel_string_this
        case 'flick'
            kernel_param.order = 0;
            kernel_param.maxTau = [];
            kernel_param.noise = [];
            
        case 'first'
            kernel_param.order = 1;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
        case 'second'
            kernel_param.order = 2;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
        case 'first_noise'
            kernel_param.order = 1;
            kernel_param.noise = 1;
            kernel_param.maxTau = 64;
        case 'second_noise'
            kernel_param.order = 2;
            kernel_param.noise = 1;
            kernel_param.maxTau = 64;
            %% for third order kernels, this list will go very long? not really.
        case 'third_0_0'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0,0];
        case 'third_0_1'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0,1];
        case 'third_0_1_noise'
            kernel_param.order = 3;
            kernel_param.noise = 1;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0,1];
        case 'third_0_n1'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0, -1];
        case 'third_0_n1_noise'
            kernel_param.order = 3;
            kernel_param.noise = 1;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0, -1];
        case 'third_1_2'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [1, 2];
        case 'third_n1_n2'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [-1, -2];
        case 'third_0_2'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0, 2];
        case 'third_0_n2'
            kernel_param.order = 3;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
            kernel_param.dx = [0, -2];
        case 'arma_ols_first'
            kernel_param.order = 1;
            kernel_param.noise = 0;
            kernel_param.maxTau = 64;
    end
end
