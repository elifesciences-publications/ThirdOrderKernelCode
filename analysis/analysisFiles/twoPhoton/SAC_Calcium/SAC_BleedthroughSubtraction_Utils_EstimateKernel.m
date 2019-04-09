function bleedthrough_kernel = SAC_BleedthroughSubtraction_Utils_EstimateKernel(raw_movie,resptime_perframe, stimseq,  stimtime)
%% some meta data. HARD CODED HERE. Could be moved to a separate file in the future.
nlines = 128;
maxTau = 7;

%% response timing,
resptime_perline = SAC_Timealign_frame2lin(resptime_perframe, nlines);

%%
[bckg_traces, bckg_line_used] = BleedThroughSub_Utils_GetBckgTraces(raw_movie);

%% align response with stimulus.
nT = size(resptime_perline, 1);
n_lines_bckg = length(bckg_line_used);
stim_indexes = zeros(nT, n_lines_bckg);
for jj = 1:1:n_lines_bckg
    ll = bckg_line_used(jj);
    % get stim_indexes for all selected lines
    [stim_indexes(:,jj), ~] = SAC_Timealign_resp2stimindex(resptime_perline(:,ll), stimtime);
end

%% extract kernels.
resp = mat2cell(bckg_traces(5:end,:), nT - 4, ones(n_lines_bckg, 1));
stimind = mat2cell(stim_indexes(5:end,:), nT - 4, ones(n_lines_bckg, 1));

%% if the sampling frequency of response is larger than presentation of stimulus, use OLS.
fstim = 1/mean(diff(stimtime(:,1)));
fresp = 1/mean(diff(resptime_perframe));
if fresp > fstim
    [out, ~] = kernel_extraction_ARMA_OLS(resp, stimseq, stimind, 'order', 1, 'donoise', 0, 'maxTau', maxTau, 'arma_flag', false, 'nMultiBars', size(stimseq, 2),'kernel_by_bar_flag', false);
    bleedthrough_kernel = mean(cat(3, out{:}), 3);
else
    out = Main_KernelExtraction_ReverseCorr(resp, stimseq, stimind, 'order', 1, 'donoise', 0, 'maxTau', maxTau);
    bleedthrough_kernel = mean(out{1}, 3);
end

% MakeFigure;
% fstim = 30.1578;
% quickViewOneKernel(bleedthrough_kernel, 1 ,'f', fstim);
end