function roi = roiAnalysis_kernel_extraction_ARMA(roi, varargin)
maxTau = 32; % small guy.. % shuffle?
order = 2;
dxBank = 0:19;
nMultiBars = 20; % hard coded it. use all of it.
shuffle_kernel_flag = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];

roiNum = roi.stimInfo.roiNum;
[respData,stimData,stimIndexes,~,~] = GetStimResp_ReverseCorr(flickpath, roiNum);

% you should be able to calculate whole bunch of different things.
% including first order kernel, or a particular second order kernel?
if ~shuffle_kernel_flag
    % extracting kernel using the correct resp/stim relationship.
    switch order
        case 1
            [ks, kr] = kernel_extraction_ARMA_draft(respData,stimData,stimIndexes,'maxTau',maxTau,'order',order);
            roi.filterInfo.ARMA.firstOrder.stim_driven =  ks;
            roi.filterInfo.ARMA.firstOrder.resp_auto = kr;
        case 2
            %% calculate cov_mat_arma.
            % organize your code a little bit.
            kernels_stim_driven = cell(nMultiBars,1);
            kernels_resp_auto = cell(nMultiBars,1);
            for xx = 1:1:nMultiBars
                dx = dxBank(xx);
                tic
                [ks, kr] = kernel_extraction_ARMA_draft(respData,stimData,stimIndexes,'maxTau',maxTau,'order',order,'dx',dx);
                toc
                kernels_stim_driven{xx} =  ks;
                kernels_resp_auto{xx} =  kr;
            end
            roi.filterInfo.ARMA.secondKernel.dx_full.stim_driven =  kernels_stim_driven;
            roi.filterInfo.ARMA.secondKernel.dx_full.resp_auto = kernels_resp_auto;
    end
else
    % extracting shuffled kernel for significance test.
    switch order
        case 1
            
            
        case 2
            n_noise_extraction = 45;
            dx = 1; % only maintain the self autocorrelation.
            kernels_stim_drive_noise = cell(n_noise_extraction,1);
            kernels_resp_auto_noise = cell(n_noise_extraction,1);
            for nn = 1:1:n_noise_extraction
                % wrap up the respData.
                tic
                nT = length(respData{1});
                rotBy = maxTau * 2 + floor(rand*(nT - maxTau * 3));
                firstBunch = 1:rotBy;
                secondBunch = rotBy+1:nT;
                kernelIndsUse = [secondBunch firstBunch];% shuffle(kernelInds)
                respData_noise{1} = respData{1}(kernelIndsUse,:);
                [ks, kr] = kernel_extraction_ARMA_draft(respData_noise,stimData,stimIndexes,'maxTau',maxTau,'order',2,'dx',dx);
                kernels_stim_drive_noise{nn} =  ks;
                kernels_resp_auto_noise{nn} =  kr;
                toc
            end
             roi.filterInfo.ARMA.secondKernel.noise.stim_driven = kernels_stim_drive_noise;
             roi.filterInfo.ARMA.secondKernel.noise.resp_auto = kernels_resp_auto_noise;
    end
    
    
end

end