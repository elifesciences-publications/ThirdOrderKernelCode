function kernel_shifted = SAC_tmp_align(kernel, order, offset, max_offset)
    % if it is first order kernel. easy.
    switch order 
        case 1
            kernel_shifted = circshift(kernel, -offset, 2);
            kernel_shifted = kernel_shifted(:, 1: size(kernel, 2) - max_offset);
        case 2
            nbars = 15;
            max_tau = size(kernel, 1)/nbars;
            n = nbars - max_offset;
            kernel_shifted = kernel(offset * max_tau + 1:(n + offset) * max_tau, offset * max_tau + 1:(n + offset) * max_tau);
    end
end