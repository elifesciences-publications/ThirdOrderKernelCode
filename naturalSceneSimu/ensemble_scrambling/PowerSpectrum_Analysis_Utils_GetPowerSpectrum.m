function fft_value = PowerSpectrum_Analysis_Utils_GetPowerSpectrum(image_folder, varargin)
n_image = 1000;
seed_num = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
data_sequence_image_421 = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_image, 'seed_num', seed_num);
data_sequence_image = tansfer_data_sequence_421_to_vector(data_sequence_image_421);

image_data_info = dir(fullfile(image_folder, '*.mat'));
fft_value = zeros(n_image,927);
%% plot the distribution.
for ii = 1:1: n_image
    image_ID = data_sequence_image.image_sequence(ii);
    row_num = data_sequence_image.image_row_pos_sequence(ii);
    I = load(fullfile(image_folder, image_data_info(image_ID).name));
    this_row = I.I(row_num, :);
    fft_value(ii,:) = abs(fft(this_row));
end

end