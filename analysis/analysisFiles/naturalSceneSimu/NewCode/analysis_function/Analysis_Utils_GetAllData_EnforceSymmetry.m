function data_matrix = Analysis_Utils_GetAllData_EnforceSymmetry(data_matrix)
% for every data set, double it by having flip sign of all velocities.
[n_vel, n_FWHM] = size(data_matrix);
for ii = 1:1:n_vel
    for jj = 1:1:n_FWHM
        data_matrix(ii,jj).v2 = [data_matrix(ii,jj).v2; -data_matrix(ii,jj).v2];
        data_matrix(ii,jj).v_real = [data_matrix(ii,jj).v_real; -data_matrix(ii,jj).v_real];
        if isfield(data_matrix,'v3')
            data_matrix(ii,jj).v3 = [data_matrix(ii,jj).v3; -data_matrix(ii,jj).v3];
        end
        if isfield(data_matrix(ii, jj),'solved_flag')
            data_matrix(ii,jj).solved_flag = [data_matrix(ii,jj).solved_flag; data_matrix(ii,jj).solved_flag];
        end
    end
end
end