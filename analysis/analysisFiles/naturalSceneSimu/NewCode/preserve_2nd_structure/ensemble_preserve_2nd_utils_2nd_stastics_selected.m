function [fn_power, covariance] = ensemble_preserve_2nd_utils_2nd_stastics_selected(img_folder, data_sequence_image, savefile)

n_hor = 927;
n_fft = floor((n_hor - 1)/2);

%%
img_info = dir(fullfile(img_folder, '*.mat'));
image_sequence = data_sequence_image.image_sequence;
image_row_pos_sequence = data_sequence_image.image_row_pos_sequence;
image_flip_flag_sequence = data_sequence_image. image_flip_flag_sequence;

n_ver = length(data_sequence_image.image_sequence);

%%
I_ori = zeros(n_ver, n_hor);
for nn = 1:1:n_ver
    img_file = fullfile(img_folder, img_info(image_sequence(nn)).name);
    data = load(img_file);
    row = data.I(image_row_pos_sequence(nn),:);
    if image_flip_flag_sequence(nn)
        row = fliplr(row);
    end
    I_ori(nn,:) = row;
end

%%    
fn_all = zeros(n_ver, n_fft);
cov_perline = zeros(n_ver, n_hor);
for ii = 1:1:n_ver
    fft_f = fft(I_ori(ii,:)) ;
    fn_all(ii, :) = fft_f(2:n_fft + 1);
    cov_perline(ii,:) = calculate_covariance(I_ori(ii,:));
end

fn_power = mean(abs(fn_all).^2);
covariance = mean(cov_perline);
    
save(savefile, 'fn_power', 'covariance');
end