function [U, var_] = My_SVD_K3_3D_Appro(T, R)
% always 
    U = cpd(T,R);
    % plotting the before and after.
    T_recover = cpdgen(U);
    T_residual = T - T_recover;
    
    % compute it.
    var_.impulse =  sum(T(:).^2);
    var_.recover = sum(T_recover(:).^2);
    var_.residual = sum(T_residual(:).^2);
end
