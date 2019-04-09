function  kernel_string = kernel_path_management_utils_kernelparam_to_kernelstr(kernel_param)

% first change it into kernel_param?
% use order directly...
n = length(kernel_param);
kernel_string = cell(n,1);
for ii = 1:1:n
    order = kernel_param(ii).order;
    noise = kernel_param(ii).donoise;
    dx = kernel_param(ii).dx;
    if order == 0
        kernel_string{ii} = 'flick';
    end
    if order == 1
        if noise == 0
            kernel_string{ii} = 'first';
        elseif noise == 1
            kernel_string{ii} = 'first_noise';
        end
    end
    if order == 2
        if noise == 0
            kernel_string{ii} = 'second';
        elseif noise == 1
            kernel_string{ii} = 'second_noise';
        end
    end
    if order == 3
        if noise == 0
            if isequal(dx, [0,0])
                kernel_string{ii} = 'third_0_0';
            elseif isequal(dx, [0,1])
                kernel_string{ii} = 'third_0_1';
            elseif isequal(dx, [0,-1])
                kernel_string{ii} = 'third_0_n1';
            elseif isequal(dx, [1,2])
                kernel_string{ii} = 'third_1_2';
            elseif isequal(dx, [-1,-2])
                kernel_string{ii} = 'third_n1_n2';
            elseif isequal(dx, [0,-2])
                kernel_string{ii} = 'third_0_n2';
            elseif isequal(dx, [0,2])
                kernel_string{ii} = 'third_0_2';
            else
                kernel_string{ii} = '';
            end
        end
    end
    
end
