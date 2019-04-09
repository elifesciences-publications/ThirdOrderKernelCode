function resp= SAC_GetRoiTimeTrace_5D_movie(roi_mask, movie)
n_movie = length(movie);
n_roi = max(roi_mask(:));
movie_size = size(movie{1});
n_time = movie_size(3);
n_trial = movie_size(4);

resp = zeros(n_time, n_trial, n_movie, n_roi);
for mm = 1:1:n_movie
    for tt = 1:1:n_trial
        movie_this = reshape(movie{mm}(:,:,:,tt), movie_size(1)*movie_size(2),n_time)';
        for rr = 1:1:n_roi
            roimask_this = (roi_mask(:) == rr);
            n_pixel = sum(roimask_this);
            resp(:,tt,mm,rr) = movie_this * roimask_this/n_pixel;
        end
    end
end
% time, trial, movie, roi. the trial here is determining the stimulus...
end