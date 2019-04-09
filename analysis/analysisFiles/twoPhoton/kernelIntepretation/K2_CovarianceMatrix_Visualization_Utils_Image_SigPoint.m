function  K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(A, varargin)
color = [0,0,0];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
significant_point = find(A(:) == 1);
[ind_i, ind_j] = ind2sub(size(A),significant_point);
scatter(ind_j, ind_i, '*','MarkerEdgeColor',color);
end