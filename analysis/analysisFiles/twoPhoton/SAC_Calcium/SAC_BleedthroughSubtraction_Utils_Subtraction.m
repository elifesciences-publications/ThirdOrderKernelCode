function movie_bckg_subtracted = SAC_BleedthroughSubtraction_Utils_Subtraction(raw_movie, resptime_perframe, stimseq, stimtime, kernel)
%% some meta data. HARD CODED HERE. Could be moved to a separate file in the future. 
nlines = 128;
nbars = 15;

%% response timing,
resptime_perline = SAC_Timealign_frame2lin(resptime_perframe, nlines);

%% predict the bleedthrough movie.
predicted_resp = zeros(size(stimseq));
for nn = 1:1:nbars 
    predicted_tmp = conv(stimseq(:, nn), kernel(:,nn));
    predicted_resp(:, nn) = predicted_tmp(1:size(stimseq, 1));
end
predicted_resp = sum(predicted_resp, 2);

%% subtracte out the bleedthrough movie
movie_bckg_subtracted = zeros(size(raw_movie));
for ll = 1:1:nlines 
    [stim_indexes, ~] = SAC_Timealign_resp2stimindex(resptime_perline(:,ll), stimtime);
    movie_bckg_subtracted(ll, :, 2:end) = bsxfun(@minus, squeeze(raw_movie(ll, :, 2:end)),predicted_resp(stim_indexes(2:end))');
end
end