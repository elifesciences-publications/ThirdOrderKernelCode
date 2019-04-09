function  K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(A)
significant_point = find(A(:) == 1);
[ind_i, ind_j] = ind2sub(size(A),significant_point);
scatter(ind_j, ind_i, '*','k');
end