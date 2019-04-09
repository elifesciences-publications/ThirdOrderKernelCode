function resp= SAC_GetRoiTimeTrace(roi_mask, movie)
n_trial = length(movie);
n_roi = max(roi_mask(:));
movie_size = size(movie{1});
n_t = movie_size(3);

resp = zeros(n_t, n_roi, n_trial);
for tt = 1:1:n_trial
    movie_this = reshape(movie{tt}, movie_size(1)*movie_size(2), movie_size(3))';
    for rr = 1:1:n_roi
        roimask_this = (roi_mask(:) == rr);
        n_pixel = sum(roimask_this);
        resp(:,rr,tt) = movie_this * roimask_this/n_pixel;
    end
end

end
