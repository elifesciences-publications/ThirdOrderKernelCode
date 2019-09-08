function index = FindOutlier(X,a)
% find data point X, where the value is larger than 3 std of itself
thre = a * std(X);
index = find(X > thre | X < -thre);
end