function data_sequence_image = tansfer_data_sequence_421_to_vector(data_sequence_image_421)
n_total_sample_points = sum(data_sequence_image_421.nSpI);

image_sequence_421 = data_sequence_image_421.image_sequence;
image_row_pos_sequence_421 = data_sequence_image_421.image_row_pos_sequence;
image_flip_flag_sequence_421 = data_sequence_image_421.image_flip_flag_sequence;

image_sequence = zeros(n_total_sample_points, 1);
image_row_pos_sequence = zeros(n_total_sample_points, 1);
image_flip_flag_sequence = zeros(n_total_sample_points, 1);
nSpI = data_sequence_image_421.nSpI;
counter = 1;
for m = 1:1:length(image_sequence_421) % the length of image_sequence might be smaller than nSpI
    imageID = image_sequence_421(m);
    if nSpI(imageID)~= 0
        
    end
    for k = 1:1:nSpI(imageID);
        % stim is a xt plot.spatial resolution is .38degree/pixel
        image_sequence(counter) = imageID;
        image_flip_flag_sequence(counter) = image_flip_flag_sequence_421{imageID}(k);
        image_row_pos_sequence(counter) = image_row_pos_sequence_421{imageID}(k); % for different imageID, there was some predetermined value to use
        counter = counter + 1;
    end
end

data_sequence_image.image_sequence = image_sequence;
data_sequence_image.image_row_pos_sequence = image_row_pos_sequence;
data_sequence_image.image_flip_flag_sequence = image_flip_flag_sequence;
