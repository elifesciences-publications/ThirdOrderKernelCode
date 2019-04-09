function predicted_resp_sparse = SAC_Tmp_LN_Calcu(kernel, stimseq, stimindexes)
nbars = size(stimseq, 2);
predicted_resp_tense = zeros(size(stimseq));
for nn = 1:1:nbars 
    predicted_tmp = conv(stimseq(:, nn), kernel(:,nn));
    predicted_resp_tense(:, nn) = predicted_tmp(1:size(stimseq, 1));
end
predicted_resp_tense = sum(predicted_resp_tense, 2);
predicted_resp_sparse = predicted_resp_tense(stimindexes);

%% plot is separated.
end