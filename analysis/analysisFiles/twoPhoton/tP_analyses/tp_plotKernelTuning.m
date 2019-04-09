function kernelTuning = tp_plotKernelTuning( kernelPaths, threshold, maxTauSet )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        threshold = [];
    end
    
    if nargin < 3
        maxTauSet = Inf;
    end
    
    %% Grab kernels
    evalc(['load ' kernelPaths{1}]);
    kernels{1} = saveKernels.kernels;
    evalc(['load ' kernelPaths{2}]);
    kernels{2} = saveKernels.kernels;  
    
    %% Loop over ROIs
    nRois = size(kernels{1},3);   
    nKernels = size(kernels{1},2);
    maxTau = min([ size(kernels{1},1) round(sqrt(size(kernels{2},1))) maxTauSet ]);
    lambdas = 30;
    
    for q = 1:nRois
        makeFigure;      
        allQuad{q} = [];
        egLinear = kernels{1}(1:maxTau,:,q);
        linThresh = percentileThresh(abs(egLinear),threshold);
        egLinear = egLinear .* (abs(egLinear) > linThresh);
        tuning.linear{q} = predictLinearTuning(egLinear,lambdas,60,false);
        for r = 1:4
            egQuad = reshape(kernels{2}(:,r,q),[120 120]);
            egQuad = egQuad(1:40,1:40);
            quadThresh = percentileThresh(abs(egQuad),threshold);
            egQuad = egQuad .* (abs(egQuad) > quadThresh);
            tuning.quadratic{q,r} = predictQuadraticTuning(egQuad,lambdas,60,false);
            allQuad{q} = cat(2,allQuad{q},tuning.quadratic{q,r}.dsIndex);
        end
        subplot(1,2,1); 
        imagesc(egLinear);
        title('Linear Filters');
        set(gca,'XTick',[1:nKernels],'YTick',[10:10:maxTau],'YTickLabel',...
            round([10:10:maxTau]*1000/60));
        ylabel('\tau (ms)'); xlabel('bar id');
        subplot(2,2,2);
        plot(tuning.linear{q}.dsAxis,tuning.linear{q}.dsIndex)
        title('1o Filter Tuning');
        xlabel('|\omega| (hz)');
        ylabel('L - R (\Delta F/F)^2');
        subplot(2,2,4);
        plot(tuning.quadratic{q,1}.dsAxis,allQuad{q});
        title('2o Filter Tuning');
        xlabel('|\omega| (hz)');
        ylabel('L - R (\Delta F/F)^2');
    end
    
    kernelTuning = tuning;
    
end

