function SAC_Tmp_LN_Plot(predResp, resp, nbins, nOneBin)
    [x_,y_,n] = BinXY(predResp,resp,'x', 'nbins', nbins);
    x_Plot = x_(n > nOneBin);
    y_Plot = y_(n > nOneBin);
    FigPlot2_OneLN(x_Plot,y_Plot,'color',[1,0,0],'lineWidth',1);
end