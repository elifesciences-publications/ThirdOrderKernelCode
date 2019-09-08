function x_syn = ensemble_scrambling_utils_generate_one_image(seed_num, varargin)
%% generate one synthetic image.
rng(seed_num)
NFFT = 927;
n_lambda = (NFFT - 1)/2;
%% if you do not get image_sequence as input, you will generate your own.
n_image = 421;
n_ver = 251;
%% know which image you are using.
image_sequence = datasample(1:n_image, n_lambda); % need to seed.
row_sequence = datasample(1:n_ver, n_lambda);
source_image_path = 'D:\Natural_Scene_Simu\image\statiche0_fft\FWHM25';

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

image_info_data = dir(fullfile(source_image_path, '*.mat'));
%% you need to sample the corresponding fft value from individual scenes.
phase_Y_half = rand(1,(NFFT - 1)/2 ) * 2 * pi; % phase...
fft_abs_synethetize_half = zeros(1,n_lambda); % NFFT is an odd number.
for ii = 1:1:n_lambda
    imageID = image_sequence(ii);
    rowID = row_sequence(ii);
    I = load(fullfile(source_image_path, image_info_data(imageID).name));
    fft_this = I.I_fft(rowID,:);
    fft_this(1) = []; 
    %% fft_abs_synethetize does not care about the dc value.
    %% ii is the first nonzeros component. re do it.
    fft_abs_synethetize_half(ii) = abs(fft_this(ii));
end

%% fourth, generate an image and store it somewhere
mag_Y = [0, fft_abs_synethetize_half, fft_abs_synethetize_half(end:-1:1)];
phase_Y = [0, phase_Y_half,  -phase_Y_half(end:-1:1)];
Y = mag_Y .* exp(phase_Y  * sqrt(-1));

x_syn = ifft(Y, 'symmetric');

% time it.
end