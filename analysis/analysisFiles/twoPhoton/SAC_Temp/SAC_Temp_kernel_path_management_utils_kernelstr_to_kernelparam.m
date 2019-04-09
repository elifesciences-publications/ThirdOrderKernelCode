function  kernel_param = SAC_Temp_kernel_path_management_utils_kernelstr_to_kernelparam(kernel_string, varargin)

% this should be changed... how do you want to do it?
% first, rewrite kernels, and update your roi kernels...
n = length(kernel_string);
f = 37.5;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% I want this to be a struct array.
kernel_param = struct('order', cell(n,1),'noise',cell(n,1),'maxTau',cell(n,1),'dx', cell(n,1));
for ii = 1:1:n
    % have a look up table.
    kernel_string_this = kernel_string{ii};
    switch kernel_string_this
        case 'first'
            kernel_param.order = 1;
            kernel_param.noise = 0;
            kernel_param.maxTau =  ceil(500/(1000/f));
        case 'second'
            kernel_param.order = 2;
            kernel_param.noise = 0;
            kernel_param.maxTau =  ceil(500/(1000/f));
        case 'first_noise'
            kernel_param.order = 1;
            kernel_param.noise = 1;
            kernel_param.maxTau =  ceil(500/(1000/f));
        case 'second_noise'
            kernel_param.order = 2;
            kernel_param.noise = 1;
            kernel_param.maxTau =  ceil(500/(1000/f));
            %% for third order kernels, this list will go very long? not really.
    end
end
