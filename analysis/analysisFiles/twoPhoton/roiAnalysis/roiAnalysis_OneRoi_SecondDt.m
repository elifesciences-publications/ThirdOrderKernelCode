function roi = roiAnalysis_OneRoi_SecondDt(roi,varargin)
dt = [-8:1:8]';
tMax = 20;
normKernelFlag = false; % normalize individual kernels within one roi, and then do any calculation from there. it should be false.
normRoiFlag = true; % first, average all the kernels within one roi, get a roi secondkernel, normalize each roi. it should be true.
whichSecondKernel = 'Aligned';

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

timeUnit = 1/60;
dtPlot = dt * timeUnit;
nT = length(dt);
switch whichSecondKernel
    case 'Adjusted'
        secondKernel = cat(3,roi.filterInfo.secondKernel.dx1.Adjusted,roi.filterInfo.secondKernel.dx2.Adjusted);
    case 'Aligned'
        secondKernel = cat(3,roi.filterInfo.secondKernel.dx1.Aligned,roi.filterInfo.secondKernel.dx2.Aligned);
end
[~,nMultiBars,nDx] = size(secondKernel);

if isfield(roi.filterInfo.secondKernel.dx1,'barSelected')
    barSelected = cat(2,roi.filterInfo.secondKernel.dx1.barSelected,roi.filterInfo.secondKernel.dx2.barSelected);
else
    barSelected = true(nMultiBars,1,2);
end

%% calculate glider response
gliderResp = zeros(nT,nMultiBars,nDx);

if normKernelFlag
    A = sqrt(sum(secondKernel.^2,1));
    A(A == 0) = 100000;
    secondKernel = secondKernel./repmat(A,[size(secondKernel,1),1]);
end
if normRoiFlag
    meanKernelNorm = zeros(size(secondKernel,1),nDx);
    for dx = 1:1:nDx
        switch dx
            case 1
                meanKernel = mean(roi.filterInfo.secondKernel.dx1.Adjusted,2);
            case 2
                meanKernel = mean(roi.filterInfo.secondKernel.dx2.Adjusted,2);
        end
        A = sqrt(sum(meanKernel .^2,1));
        A(A == 0) = 100000;
        meanKernelNorm(:,dx) = meanKernel/A; % A should be a number here.
    end
end

if normRoiFlag
    for dx = 1:1:nDx
        gliderRespMean  = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(meanKernelNorm(:,dx),'dt',dt,'tMax',tMax);
        gliderResp(:,:,dx) = repmat(gliderRespMean,[1,nMultiBars]);
    end
else
    for dx = 1:1:nDx
        for qq = 1:1:nMultiBars
            %             if barSelected(qq,dx)
            gliderResp(:,qq,dx) = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(secondKernel(:,qq,dx),'dt',dt,'tMax',tMax);
            %             end
        end
    end
end

gr.dx1 = squeeze(gliderResp(:,:,1));
gr.dx2 = squeeze(gliderResp(:,:,2));
glider.resp = gr;
glider.dt = dtPlot;
glider.normKernelFlag = normKernelFlag;
glider.normRoiFlag = normRoiFlag;

roi.simu.sK.glider = glider;


%% do quantification ...
% along each diagnal, do the quantification.
% only two values, progressive direction, and regressive direction. % dx >
% 0 is regressive direction, dt < 0 is progressive direction.
magMean = zeros(2,nMultiBars,nDx); % first value is progressive, second value is regressive.
% magMax = zeros(2,nMultiBars,nDx);
% timeMax = zeros(2,nMultiBars,nDx);

for dx = 1:1:nDx
    for qq = 1:1:nMultiBars
        if barSelected(qq,dx)
            
            % smooth the gliderResp
            gliderRespSmooth = smooth(gliderResp(:,qq,dx),3); % left and right. might not be working...max is noisy...just trust it...
            
            %             dtPro = dt(dt < 0);
            %             dtReg = dt(dt > 0);
            % in the future, the calculation of opponency might change,
            % keep an eye on that...
            gliderRespPro = gliderRespSmooth(dt > 0);
            gliderRespReg = gliderRespSmooth(dt < 0); % ignore dt == 0;
            
            magMean(:,qq,dx) = mean([gliderRespPro,gliderRespReg],1)';
            
            %             % do the smoothing first,
            %             [~,timeMaxInd] = max(abs(gliderRespPro));
            %             timeMax(1,qq,dx) = dtPro(timeMaxInd);
            %             magMax(1,qq,dx) = gliderRespPro(timeMaxInd);
            %
            %             [~,timeMaxInd] = max(abs(gliderRespReg));
            %             timeMax(2,qq,dx) = dtReg(timeMaxInd);
            %             magMax(2,qq,dx) = gliderRespReg(timeMaxInd);
            
            %             MakeFigure;
            %             subplot(3,3,1)
            %             plot(gliderResp(:,qq,dx));
            %             subplot(3,3,2)
            %             plot(gliderRespSmooth);
            %             subplot(3,3,4)
            %             plot( dtPro, gliderRespPro)
            %             subplot(3,3,5)
            %             plot( dtReg,gliderRespReg)
        end
    end
end
% quantification.
mag.mean.dx1 = squeeze(magMean(:,:,1));
mag.mean.dx2 = squeeze(magMean(:,:,2));
%
% mag.max.dx1 = squeeze(magMax(:,:,1));
% mag.max.dx2 = squeeze(magMax(:,:,2));
%
% time.max.dx1 = squeeze(timeMax(:,:,1));
% time.max.dx2 = squeeze(timeMax(:,:,2));

quant.mag = mag;
% quant.time = time;
roi.SKquant = quant;

end