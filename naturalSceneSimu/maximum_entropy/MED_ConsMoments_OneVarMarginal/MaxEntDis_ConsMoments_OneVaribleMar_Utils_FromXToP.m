function p = MaxEntDis_ConsMoments_OneVaribleMar_Utils_FromXToP(lambda, gray_level, N)
    % you are calming down
    % you will get the probability from here.
   %% regressional model for 
   X = [ones(N, 1), gray_level, gray_level.^2, gray_level.^3];
   f_x = -ones(N, 1) + X * lambda;
   p = exp(f_x);   
end
