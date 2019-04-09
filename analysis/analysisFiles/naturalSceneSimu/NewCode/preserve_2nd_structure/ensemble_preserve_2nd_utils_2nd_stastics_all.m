function [fn_power, covariance] = ensemble_preserve_2nd_utils_2nd_stastics_all(img_folder, savefile)
img_info = dir(fullfile(img_folder, '*.mat'));

n_hor = 927;
n_fft = floor((n_hor - 1)/2);
n_ver = 251;

n_img = length(img_info);
fn_var_img = zeros(n_img, n_fft);
covariance_img = zeros(n_img, n_hor);
%%
for nn = 1:1:n_img
    img_file = fullfile(img_folder, img_info(nn).name);
    data = load(img_file);
    
    %% do fourier transform, and collect fn, f-n, look at the distribution..
    fn_all = zeros(n_ver, n_fft);
    cov_perline = zeros(n_ver, n_hor);
    for ii = 1:1:n_ver
        fft_f = fft(data.I(ii,:)) ;
        fn_all(ii, :) = fft_f(2:n_fft + 1);
        cov_perline(ii,:) = calculate_covariance(data.I(ii,:));
    end
 
    fn_var_img(nn,:) = mean(abs(fn_all).^2);
    covariance_img(nn, :) = mean(cov_perline);
end
fn_power = mean(fn_var_img); 
covariance = mean(covariance_img);

save(savefile, 'fn_power', 'covariance');
end