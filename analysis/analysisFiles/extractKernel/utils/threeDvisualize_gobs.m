function [ output_args ] = threeDvisualize_gobs( kernel,z,blobSize,subplotInd  )

if nargin < 3
    blobSize = 50;
end

if nargin < 4
    isSubplot = 0;
else
    isSubplot = 1;
end

maxTau = length(kernel);
maxDev = max(abs(kernel(:)));

gridAxis = linspace(1,maxTau,maxTau);
[X Y Z] = meshgrid(gridAxis,gridAxis,gridAxis);

hugDiag = find(abs(kernel) > z);
X = X(:); X = X(hugDiag);
Y = Y(:); Y = Y(hugDiag);
Z = Z(:); Z = Z(hugDiag);
kernel = kernel(:); kernel = kernel(hugDiag);

if isSubplot
    subplot(subplotInd(1),subplotInd(2),subplotInd(3));
else
    figure;
end

scatter3(X(:),Y(:),Z(:),blobSize,kernel(:))
set(gca,'Xlim',[0 maxTau]);
set(gca,'Ylim',[0 maxTau]);
set(gca,'Zlim',[0 maxTau]);
set(gca,'Clim',[-maxDev maxDev]);

colormap_gen;
colormap(mymap);

end

