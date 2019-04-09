function [x_Out,y_Out] = LN_NonParametric(x_In,y_In)
nBins = 30;
nOneBin = 50;

[x_,y_,n] = BinXY(x_In,y_In,'x',nBins);

% you might need a flag to decide whether to plot this range.
x_Out = x_(n>nOneBin);
y_Out = y_(n>nOneBin);