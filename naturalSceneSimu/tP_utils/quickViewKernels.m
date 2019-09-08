function quickViewKernels( kernels, order, sym, forceTitle )
% quickly visualize all the kernels saved in saveKernels

    if nargin < 3
        sym = 'none';
    end
    
    if nargin < 4
        forceTitle = [];
    end
    
    colormap_gen; 
    for q = 1:size(kernels,3);
       	switch order
            case 1
                thisKernel = kernels(:,:,q);
                thisMaxVal = max(abs(thisKernel(:)));
                figure; 
                imagesc(thisKernel);
                set(gca,'Clim',[-thisMaxVal thisMaxVal]);
                if isempty(forceTitle)
                    suptitle(['1^o Kernels, ROI ' num2str(q) ]);
                else
                    suptitle(forceTitle);
                end
                colormap(mymap);
                
            case 2
                maxTau = round(sqrt(size(kernels,1)));
                subplotHt = floor(sqrt(size(kernels,2)));
                subplotWd = ceil(size(kernels,2)/subplotHt);
                MakeFigure;
                thisMaxVal = max(max(abs(kernels(:,:,q))));
                for r = 1:size(kernels,2)
                    subplot(subplotHt,subplotWd,r);
                    thisKernel = kernels(:,r,q);                    
                    thisKernel = reshape(thisKernel,[maxTau maxTau]);
                    switch sym
                        case 'none'
                            imagesc(thisKernel);
                        case 'skew'
                            imagesc((thisKernel - thisKernel')/2);
                        case 'sym'
                            imagesc((thisKernel + thisKernel')/2);
                    end
                    hold all;
                    plot([1:maxTau],[1:maxTau],'k');
                    set(gca,'Clim',[-thisMaxVal thisMaxVal]);
                end
                if isempty(forceTitle)
                    suptitle(['2^o Kernels, ROI ' num2str(q) ]);
                else
                    suptitle(forceTitle);
                end
                colormap(mymap);
              
        end

end

