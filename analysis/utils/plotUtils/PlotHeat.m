function PlotHeat(mat,nameX,nameY)
    imagesc(mat);
    colorbar;
    
    xlabel(nameX,'FontSize',16);
    ylabel(nameY,'FontSize',16);
end