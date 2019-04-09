%%  Test correlations of xt plot from gliderBarVarFar stim

slices = [ 73 78 83 88 ];

for q = 1:3
    X = D.analysis.R.xtPlot(:,slices(q));
    Y = D.analysis.R.xtPlot(:,slices(q+1));
    axis = [1:1:size(X,1)];
    axis = find(mod(axis,10) == 0);
    X = X(axis);
    Y = Y(axis);
    threed = threed_fast(40,1,Y,Y,X,ones(size(X)));
    threeDvisualize_slices(40,9,reshape(threed,[40 40 40]));
end

