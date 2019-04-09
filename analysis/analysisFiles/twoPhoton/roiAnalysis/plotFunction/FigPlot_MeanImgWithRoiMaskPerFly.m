function FigPlot_MeanImgWithRoiMaskPerFly(roiData,roiUse,filepath,varargin)
% rememeber current path way....
currentFolder = pwd;
[~,edgeTypeColorRGB,DarkLightColor] = FigPlot1ColorCode();
roiMethod = 'ICA_NNMF';
for ii = 1:2:length(varargin)
    str = [ varargin{ii} ' = varargin {' num2str(ii+1) '};'];
    eval(str);
end
Z = twoPhotonMaster('filename',filepath,...
    'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','nnmf','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
movieMean = Z.rawTraces.movieMean;
cd(currentFolder);
% actually, you should plot all the roi.
Z = CullRoiTracesKernel(Z);

flyEye = roiData{roiUse(1)}.flyInfo.flyEye;

[cfRoi,~] = RoiClassification(Z,flyEye);
roiMasks = Z.ROI.roiMasks(:,:,1:end - 1);
contrastType = cfRoi.PEye.contrastType;
leftRightFlag = cfRoi.PEye.leftRightFlag;
ESI_Edge = abs(cfRoi.PEye.LDSI_Combined);
% only plot those which are larger than zeros...
% edgeType = cfRoi.PEye.edgeType;
MakeFigure
colormap(gray(256));
imagesc(movieMean);
for rr = 1:1:size(roiMasks,3)
    roiBoundaries = MyBWBoundaries(roiMasks(:,:,rr));
    type = contrastType(rr);
    if leftRightFlag(rr)
        h = rgb2hsv(DarkLightColor(type,:));
        hsvThis = [h(1),ESI_Edge(rr),1];
        rgbThis = hsv2rgb(hsvThis);
        hold on
        plot(roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',2,'color',rgbThis);
    end
end
hold off


nRoiUse = length(roiUse);
roiMasks = zeros([size(movieMean),nRoiUse]);
edgeType = zeros(nRoiUse,1);
kernelType = zeros(nRoiUse,1);
for ii = 1:1:nRoiUse
    rr = roiUse(ii);
    roiMasks(:,:,ii) = roiData{rr}.stimInfo.roiMasks;
    edgeType(ii) = roiData{rr}.typeInfo.edgeType;
    kernelType(ii) = roiData{rr}.filterInfo.kernelType;
end


axis off
hold on
for ii = 1:1:nRoiUse
    roiMaskThis = roiMasks(:,:,ii);
    roiBoundaries = MyBWBoundaries(roiMaskThis);
    type = edgeType(ii);
    plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',2,'color',edgeTypeColorRGB(type,:));
    % you have to compute the center of mass by your own..
    if kernelType(ii) == 1; % acutually, you should plot all of them, label the one which has kernel.
        [I,J] = ind2sub(size(roiMaskThis),find(roiMaskThis));
        centerOfMass = [mean(I),mean(J)];
        text(centerOfMass(2), centerOfMass(1), num2str(ii), 'HorizontalAlignment', 'center', 'Color', [0,0,0],'FontSize',10);
    end
    if kernelType(ii) == 2; % acutually, you should plot all of them, label the one which has kernel.
        [I,J] = ind2sub(size(roiMaskThis),find(roiMaskThis));
        centerOfMass = [mean(I),mean(J)];
        text(centerOfMass(2), centerOfMass(1), num2str(ii), 'HorizontalAlignment', 'center', 'Color', [1,1,0],'FontSize',10);
    end
    if kernelType(ii) == 3; % acutually, you should plot all of them, label the one which has kernel.
        [I,J] = ind2sub(size(roiMaskThis),find(roiMaskThis));
        centerOfMass = [mean(I),mean(J)];
        text(centerOfMass(2), centerOfMass(1), num2str(ii), 'HorizontalAlignment', 'center', 'Color', [1,1,1],'FontSize',10);
    end
end
end
