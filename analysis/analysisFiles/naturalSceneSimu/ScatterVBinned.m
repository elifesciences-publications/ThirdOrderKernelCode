function ScatterVBinned(v,nbins)
n = 4;
vOrigin = cell(n,1);
vOrigin{1} = v.HRC;
vOrigin{2} = v.k2;
vOrigin{3} = v.k3;
vOrigin{4} = v.k2 + v.k3;
% bin the stimulus before plotting them.
% how do you bin data?
vPlot  = cell(n,1);
for i = 1:1:n
    
    if nargin > 1
        [binnedV,vPlot{i}] = BinXY(v.real,vOrigin{i},'x',nbins);
    else
        [binnedV,vPlot{i}] = BinXY(v.real,vOrigin{i},'x');
        
    end
end
titleStr = cell(n,1);
titleStr{1} = 'HRC';
titleStr{2} = 'k2';
titleStr{3} = 'k3';
titleStr{4} = 'k2 + k3';

makeFigure;
for i = 1:1:n
    subplot(2,2,i)
    scatter(binnedV,vPlot{i},'r.');
    title(titleStr{i});
    xlabel('velocity');
    ylabel('predicted velocity');
    figurePretty;
end
end