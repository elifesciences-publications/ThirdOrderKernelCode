function PlotLNModel(predResp,resp)
nBins = 30;
nOneBin = 50;

% mode = 1, only plot the easier situation,

r  = corr(predResp,resp);
plotH = ScatterXYBinned(predResp,resp,nBins,nOneBin);


title(['r :', num2str(r)]);
axis equal
xlabel('r(1o)');
ylabel('r(real)');

end
