function [splitFlag,subRoiMasks] = getSubRoiMask(roiMask,edgeRespImg,meanImg,roiNum)
% nEdge = 2;
[nM,nN] = size(roiMask);
[M,N] = ind2sub([nM,nN],find(roiMask));
nPixel = length(M);

nResp = size(edgeRespImg,3);
A = zeros(nResp,nPixel);
smoothA = zeros(nResp,nPixel);
for pp = 1:1:nPixel
    A(:,pp) = squeeze(edgeRespImg(M(pp),N(pp),:));
    smoothA(:,pp) = smooth( A(:,pp),5);
end
[W,H] = nnmf(smoothA,2); % let use try.....I forget the result...
% you could calculate the correlation between 2
W1 = smooth(W(:,1),5);
W2 = smooth(W(:,2),5);
r = corr(W1,W2); % higely uncorrelated


if abs(r) < 0.7 % they are basically the same thing... strange...
    splitFlag = true;
    roiH = zeros(size(roiMask));
    for pp = 1:1:nPixel
        roiH(M(pp),N(pp)) = H(1,pp) - H(2,pp);
    end
    
    imgSize = size(meanImg);
    nSubRoi = 2;
    subRoiMasks = zeros(imgSize(1),imgSize(2),nSubRoi);
    subRoiMasks(:,:,1) = roiH > 0;
    subRoiMasks(:,:,2) = roiH < 0;
    
    nResp = size(edgeRespImg,3);
    edgeRespSubRoi = zeros(nResp,nSubRoi);
    for rr = 1:1:nSubRoi
        roiMaskThis = subRoiMasks(:,:,rr);
        sizeThisRoi = sum(roiMaskThis(:));
        roiMaskThis = repmat(roiMaskThis,1,1,nResp);
        trace = edgeRespImg(roiMaskThis == 1);
        trace = reshape(trace,sizeThisRoi,[]);
        edgeRespSubRoi(:,rr) = sum(trace);
    end
    %
    MakeFigure;
    for ii = 1:1:2
        subplot(4,1,ii);
        plot(W(:,ii));
        title([num2str(ii),'th Element']);
        xlim([1,length(W(:,ii))])
    end
    [sortH,sortHI] = sort(H(1,:)-H(2,:),'descend');
    % show A or smooth A
    subplot(2,1,2);
    sortA = A(:,sortHI);
    imagesc(sortA');
    xlabel('time')
    ylabel('H(1) - H(2)');
    ax = gca;
    xTickLabelStr = sortH(ax.YTick);
    xTickLabelStr = num2str(xTickLabelStr');
    set(gca,'YTickLabel',num2str(xTickLabelStr));
    %      PlotOneRoi_Save(gcf,num2str(roiNum),'Decomposition');
    
    MakeFigure;
    subplot(2,2,1);
    imagesc(meanImg);
    colormap(gray)
    hold on
    roiBoundaries = bwboundaries(roiMask(:,:),8,'noholes');
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',2,'color',[0,0,0]);
    subplot(2,2,2)
    plot(sum(A,2));
    title('original roi response to four edges');
    
    subplot(2,2,3)
    h = imagesc(roiH);
    diffScale = max(abs(roiH(:)));
    set(h,'AlphaData',roiMask * 0.5);
    set(gca,'Clim',[-diffScale diffScale]);
    hold on
    for rr = 1:1:nSubRoi
        roiBoundaries = bwboundaries(subRoiMasks(:,:,rr),8,'noholes');
        plot(roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',1,'color',[1,0,0]);
    end
    hold off
    subplot(4,2,6)
    plot(edgeRespSubRoi(:,1));
    title(['sub roi #',num2str(1)]);
    subplot(4,2,8)
    plot(edgeRespSubRoi(:,2));
    title(['sub roi #',num2str(2)]);
    
    %      PlotOneRoi_Save(gcf,num2str(roiNum),'RoiAndSubRoi');
    
else
    splitFlag = false;
    subRoiMasks = roiMask;
end
%
%     % % another method....
%     % preSeg = watershed(-abs(roiH),8);
%     % preSeg(~roiMask) = 0;
%     % MakeFigure;
%     % imagesc(preSeg)
%     % nSubRoi = max(preSeg(:));
%     % subRoiMasks = zeros(127,256,nSubRoi);
%     % for rr = 1:1:nSubRoi
%     %     maskTemp = zeros(size(roiMask));
%     %     maskTemp(preSeg == rr) = 1;
%     %     subRoiMasks(:,:,rr) = maskTemp;
%     % end
%     %
%     % nResp = size(edgeRespImg,3);
%     % edgeRespSubRoi = zeros(nResp,nSubRoi);
%     % for rr = 1:1:nSubRoi
%     %     roiMaskThis = subRoiMasks(:,:,rr);
%     %     sizeThisRoi = sum(roiMaskThis(:));
%     %     roiMaskThis = repmat(roiMaskThis,1,1,nResp);
%     %     trace = edgeRespImg(roiMaskThis == 1);
%     %     trace = reshape(trace,sizeThisRoi,[]);
%     %     edgeRespSubRoi(:,rr) = sum(trace);
%     %
%     % end
%     % MakeFigure;
%     nResp = size(edgeRespImg,3);
%     edgeRespSubRoi = zeros(nResp,nSubRoi);
%     for rr = 1:1:nSubRoi
%         roiMaskThis = subRoiMasks(:,:,rr);
%         sizeThisRoi = sum(roiMaskThis(:));
%         roiMaskThis = repmat(roiMaskThis,1,1,nResp);
%         trace = edgeRespImg(roiMaskThis == 1);
%         trace = reshape(trace,sizeThisRoi,[]);
%         edgeRespSubRoi(:,rr) = sum(trace);
%     end

end