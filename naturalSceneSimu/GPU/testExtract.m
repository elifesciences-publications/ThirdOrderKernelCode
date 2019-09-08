load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\responseData.mat');
load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\alignedStimulusData.mat');
load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\kernels.mat');
load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\kernelInds.mat');

kernelInds = kernelInds(:);

shiftBy = 0;

for bar = 1:20;
    newAlignedStimulusData{bar} = single(alignedStimulusData{bar}(kernelInds(shiftBy+1:end),:));
end
newAlignedStimulusDataShifted = newAlignedStimulusData([2:end 1]);

responseDataCell{1} = single(responseData(kernelInds(1:end-shiftBy),:));

kernelsGPU = twod_gpu(newAlignedStimulusData,...
                      newAlignedStimulusDataShifted,...
                      responseDataCell);

tic;
for q = 1:20
    firstInd = q;
    secondInd = mod(q,20)+1;
    for r = 1:32
        inVar = var(alignedStimulusData{q}(kernelInds,r));
        kernelsCPU(:,q,r) = twod_fast(64,inVar,alignedStimulusData{firstInd}(kernelInds(shiftBy+1:end),r),...
                alignedStimulusData{secondInd}(kernelInds(1:end-shiftBy),r),responseData(kernelInds(1:end-shiftBy),r));
    fprintf('ROI %i, Bar %i ',r,q); toc
    end               
end 
                  
kernelsSquare = reshape(kernelsCPU,64,64,20,32);



for bar = 1:20
    varSquared =  reshape(var(alignedStimulusData{bar}(kernelInds,:)).^2,1,1,1,[]);
    kernelsGPUFormatted(:,:,bar,:) = permute(kernelsGPU{bar},[1 2 4 3])./((length(kernelInds(1:end-shiftBy))-64+1)*repmat(varSquared,64,64));
end

kernelDiff = abs((kernelsSquare - kernelsGPUFormatted)./mean(mean(mean(mean(abs(kernelsSquare))))));

barNum = 1;
roiNum = 1;
figure(1);imshow(kernelsSquare(:,:,barNum,roiNum)/0.01);%max(max(kernelsSquare(:,:,barNum,roiNum))));
figure(2);imshow(kernelsGPU{barNum}(:,:,roiNum)/((length(kernelInds(1:end-shiftBy))-64)*0.01));%max(max(kernelsGPU{barNum}(:,:,roiNum))));
figure(3);histogram(double(kernelDiff(:)),20,'Normalization','cdf');
%set(gca,'yscale','log')

%%

stim1{1}=single(2*round(rand(72000,1))-1);
stim2{1}=single(2*round(rand(72000,1))-1);
resp{1} =[rand(2,1);stim1{1}(1:end-2,:)].*[rand(1,1);stim2{1}(1:end-1,:)];
inVar = var(stim1{1});
sumOmer=twod_gpu(stim1,stim2,resp);
kernelsOmer = sumOmer{1}/((size(stim1{1},1)-64+1)*inVar^2);%Is +1 a correct thing to do?


kernelsHolly = twod_fast(64,double(inVar),double(stim1{1}),double(stim2{1}),double(resp{1}));
%kernelsHolly = twod_fast(64,inVar,alignedStimulusData{1}(:,1), alignedStimulusData{1}(:,1),responseData(:,1));
kernelDiff = abs((kernelsHolly(:) - kernelsOmer(:)))./(mean(mean(abs(kernelsHolly(:)))));
figure(4);imagesc(reshape(kernelsHolly,64,64));
figure(5);imagesc(reshape(kernelsOmer,64,64));
figure(6);imagesc(reshape(kernelsOmer(:)./kernelsHolly(:),64,64));
figure(7);histogram(double(100*kernelDiff(:)),20,'Normalization','cdf');

%%

load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\responseData.mat');
load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\alignedStimulusData.mat');
load('I:\2pData\2p_microscope_data\2015_07_29\+;UASGC6f_+;T4T5_+ - 4\multiBarFlicker_20_60hz_10dWidth_-73.4down018\kernelInds.mat');

kernelInds = kernelInds(:);

shiftBy = 0;

nRoi = 2;%32
nMultiBars = 20;
dx = 1;
maxTau = 128;

tic;
for r = 1:nRoi
    for q = 1:nMultiBars 
        firstInd = q;
        secondInd = mod(q + dx-1,nMultiBars) + 1;
        kernelsCPU(:,firstInd,r) = oneD_filter(alignedStimulusData{firstInd}(kernelInds(shiftBy+1:end),r),...
            responseData(kernelInds(1:end-shiftBy),r),maxTau); 
    end
    fprintf('Kernel extracted for ROI %i! ',r); toc
end
hollyTime = toc

tic;

for bar = 1:20;
    newAlignedStimulusData{bar} = single(alignedStimulusData{bar}(kernelInds(shiftBy+1:end),:));
end

responseDataCell{1} = single(responseData(kernelInds(1:end-shiftBy),:));

kernelsGPU = oned_gpu(maxTau,newAlignedStimulusData,...
                      responseDataCell);
omerTime = toc

for bar = 1:20
    variance =  reshape(var(alignedStimulusData{bar}(kernelInds,:)).^2,1,1,[]);
    kernelsGPUFormatted(:,bar,:) = permute(kernelsGPU{bar},[1 3 2])./((length(kernelInds(1:end-shiftBy))-maxTau+1)*repmat(variance,maxTau,1));
end

kernelDiff = abs((kernelsCPU - kernelsGPUFormatted(:,:,1:nRoi))./mean(mean(mean(abs(kernelsCPU)))));

barNum = 1;
roiNum = 2;
figure(1);imagesc(kernelsCPU(:,barNum,roiNum));
figure(2);imagesc(kernelsGPUFormatted(:,barNum,roiNum));
figure(3);histogram(double(kernelDiff(:)),20,'Normalization','cdf');
%set(gca,'yscale','log')
