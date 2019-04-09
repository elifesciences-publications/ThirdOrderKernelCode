function [ void ] = slices( maxLen,numSlices,K_3D )

if numSlices > maxLen
    fprintf('Error: numSlices > maxLen\n');
    return
end

maxmaxmax = max(max(max(K_3D)));
minminmin = min(min(min(K_3D)));
lim = max([ abs(maxmaxmax) abs(minminmin) ]);

resid = mod(maxLen,numSlices);
chopLen = maxLen - resid;
interval = chopLen/numSlices;
sliceDepth = [1:interval:chopLen]
subplotEdge = ceil(sqrt(numSlices));

colormap_gen;

figure
for q = 1:numSlices
    thisTitle = sprintf('z = %0.5g',sliceDepth(q));
    subplot(subplotEdge,subplotEdge,q);
    imagesc(K_3D(:,:,sliceDepth(q)));
    set(gca,'CLim',[-lim lim]);
    colormap(mymap);
    title(thisTitle);
end


void = 0;

end

