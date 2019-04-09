function [ renamed ] = renameOLS( kernels,order )

switch order
    case 1
        renamed.k1_x_all = kernels.k1_x;
        renamed.k1_y_all = kernels.k1_y;
    case 2
        renamed.k2_xy_all = kernels.k2_xy;
    case 3
        renamed.k3_xxy_all = kernels.k3_xxy;
        renamed.k3_yyx_all = kernels.k3_yyx;
end     

end

