function [analysis_fn_OR_imgFrames] = alignAcquisition(path, fn, varargin)
%Note the output depends on whether this is a linescan or not!!! Yeah,
%probably not the best programming technique, but :P

linescan = '';

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

[~, name, ~] = fileparts([path fn]);
tifFiles = dir('*.tif');
alignFnEnd = {['_ch' channelDesired '_disinterleaved_aligned.tif'], ['_ch' channelDesired '_disinterleaved_tocoords.tif']};

if isempty(linescan)
    warning('Acquisition not aligned because alignAcquisition.m couldn''t determine whether this was a linescan or not (try to pass the ''linescan'' flag in with your function call and set it to true or false.')
    analysis_fn_OR_imgFrames = fn; %no analysis has been done
    return
end

if ~linescan
    %Switch the file to the aligned version if alignment is required (which
    %it is by default)
    if ~any(strcmp([name alignFnEnd{1}], {tifFiles.name})) && ~any(strcmp([name alignFnEnd{2}], {tifFiles.name}))
        %ImageJ MUST BE on your path for this to work!
        alignMacro = which('alignImages.ijm');
        os = computer;
        if strcmp(os, 'MACI64')
            system_call = 'java -Xmx3024m -jar /Applications/ImageJ/ImageJ64.app/Contents/Resources/Java/ij.jar -ijpath /Applications/ImageJ -macro';
        else
            system_call = 'ImageJ -macro';
        end
        system(sprintf('%s "%s" "%s\n\n%s"', system_call, alignMacro, [path fn], channelDesired));
    end
    
    % Remember there are new tif files in the directory now!
    tifFiles = dir('*.tif');
    if any(strcmp([name alignFnEnd{1}], {tifFiles.name}))
        analysis_fn_OR_imgFrames = [name alignFnEnd{1}];
    elseif any(strcmp([name alignFnEnd{2}], {tifFiles.name}))
        analysis_fn_OR_imgFrames = [name alignFnEnd{2}];
    end
else
    if ~exist('imgFrames', 'var')
        error('For linescans I need the imgFrames in order to correctly process the alignment!');
    end
    
    imgSize = size(imgFrames);
    
    if ~any(strcmp([name alignFnEnd{1}], {tifFiles.name})) && ~any(strcmp([name alignFnEnd{2}], {tifFiles.name}))
        intensities = zeros(imgSize(1)*imgSize(3), imgSize(2));
        
        %We're grabbing each pixel of the line individually and plotting it
        %down! (Probably gonna change this to an ROI at some point)
        for i = 1:size(imgFrames, 2)
            intensities(:, i) = reshape(imgFrames(:, i, :), [imgSize(1)*imgSize(3), 1]);
        end
        
        num_acqs = size(intensities, 1);
        line_width = size(intensities, 2);
        
        
        mean_intensity = mean(intensities);
        
        %The 2*line_width-1 part has to do with the size xcov outputs
        cross_covariances = zeros(num_acqs, 2*line_width-1);
        
        disp('Finding optimal line alignment...')
        fprintf('%4d%% done', 0)
        for j = 1:num_acqs
            if ~mod(j, round(num_acqs/100))
                fprintf('\b\b\b\b\b\b\b\b\b\b');
                fprintf('%4d%% done', round(100*j/num_acqs))
            end
            cross_covariances(j, :) = xcorr(intensities(j, :), mean_intensity, 'coeff');
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b');
        fprintf('%4d%% done', 100)
        fprintf('\n');
        
        [~, ind] = max(cross_covariances, [], 2);
        shift = ind - imgSize(2);
        
        stabilized_intensities = zeros(size(intensities));
        
        disp(['Aligning ch' channelDesired ' lines...'])
        fprintf('%4d%% done', 0)
        for k = 1:length(shift)
            if ~mod(k, round(length(shift)/100))
                fprintf('\b\b\b\b\b\b\b\b\b\b');
                fprintf('%4d%% done', round(100*k/length(shift)))
            end
            shift_here = shift(k);
            if shift_here < 0
                stabilized_intensities(k, :) = [zeros(1, -shift_here) intensities(k, 1:end+shift_here)];
            elseif shift_here > 0
                stabilized_intensities(k, :) = [intensities(k, shift_here+1:end), zeros(1, shift_here)];
            else
                stabilized_intensities(k, :) = intensities(k, :);
            end
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b');
        fprintf('%4d%% done',100)
        fprintf('\n');
        
        disp('Saving alignment...')
        [~, name, ~] = fileparts(fn);
        csvwrite([path name '_ch' channelDesired '_disinterleaved_alignment.txt'], shift);
        
        disp('Reframing image...')
        reframed_image = mat2cell(stabilized_intensities, imgSize(1)*ones(1,imgSize(3)), imgSize(2));
        
        currentFile = Tiff([path fn]);
        disinterleaved_aligned_file = Tiff([path name alignFnEnd{1}], 'a');
        
        imageLength = currentFile.getTag('ImageLength');
        imageWidth = currentFile.getTag('ImageWidth');
        photometric = currentFile.getTag('Photometric');
        bitsPerSample = currentFile.getTag('BitsPerSample');
        samplesPerPixel = currentFile.getTag('SamplesPerPixel');
        compression = currentFile.getTag('Compression');
        planarConfiguration = currentFile.getTag('PlanarConfiguration');
        imageDescription = currentFile.getTag('ImageDescription');
        
        disp(['Saving disinterleaved aligned ch' channelDesired ' image...'])
        fprintf('%4d%% done', 0)
        for i = 1:length(reframed_image)
            if ~mod(i, round(length(reframed_image)/100))
                fprintf('\b\b\b\b\b\b\b\b\b\b');
                fprintf('%4d%% done', round(100*i/length(reframed_image)))
            end
            disinterleaved_aligned_file.setTag('ImageLength',imageLength);
            disinterleaved_aligned_file.setTag('ImageWidth',imageWidth);
            disinterleaved_aligned_file.setTag('Photometric',photometric);
            disinterleaved_aligned_file.setTag('BitsPerSample',bitsPerSample);
            disinterleaved_aligned_file.setTag('SamplesPerPixel',samplesPerPixel);
            disinterleaved_aligned_file.setTag('Compression',compression);
            disinterleaved_aligned_file.setTag('PlanarConfiguration',planarConfiguration);
            disinterleaved_aligned_file.setTag('ImageDescription',[imageDescription '\n' 'slices=' num2str(length(reframed_image))]);
            frame = uint16(reframed_image{i});
            
            disinterleaved_aligned_file.write(frame)
            disinterleaved_aligned_file.writeDirectory();
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b');
        fprintf('%4d%% done', 100)
        fprintf('\n');
        disinterleaved_aligned_file.close()
        
        % Need to select the other channel that's getting aligned
        disp('Checking if a second acquisition channel needs to be aligned to the first''s alignment values')
        if strcmp(channelDesired, '1')
            alignee_channel = '2';
        else
            alignee_channel = '1';
        end
        
        % Now we're checking to see if that channel exists
        if any(strfind(imageDescription, ['acquiringChannel' alignee_channel '=1']))
            disp(['Reading in other channel']);
            % Making use of twoPhotonImageParser to grab the frames since
            % it's already there... :D GOTTA PUT THE RIGHT FLAGS, otherwise
            % we'll get in an awkward recursive loops :(
            [imgFramesAligneeChannel, ~, ~, ~] = twoPhotonImageParser('filename', [path fn], 'saveMat', false, 'align', false, 'linescan', true, 'runPDAnalysis', 'No', 'channelDesired', alignee_channel, 'frameGrab', true);
            
            intensities_alignee = zeros(imgSize(1)*imgSize(3), imgSize(2));
        
            %We're grabbing each pixel of the line individually and plotting it
            %down! (Probably gonna change this to an ROI at some point)
            for i = 1:size(imgFramesAligneeChannel, 2)
                intensities_alignee(:, i) = reshape(imgFramesAligneeChannel(:, i, :), [imgSize(1)*imgSize(3), 1]);
            end
            
            disp(['Aligning ch' alignee_channel ' lines...'])
            stabilized_intensities_alignee = zeros(size(intensities_alignee));
            fprintf('%4d%% done', 0)
            for k = 1:length(shift)
                if ~mod(k, round(length(shift)/100))
                    fprintf('\b\b\b\b\b\b\b\b\b\b');
                    fprintf('%4d%% done', round(100*k/length(shift)))
                end
                shift_here = shift(k);
                if shift_here < 0
                    stabilized_intensities_alignee(k, :) = [zeros(1, -shift_here) intensities_alignee(k, 1:end+shift_here)];
                elseif shift_here > 0
                    stabilized_intensities_alignee(k, :) = [intensities_alignee(k, shift_here+1:end), zeros(1, shift_here)];
                else
                    stabilized_intensities_alignee(k, :) = intensities_alignee(k, :);
                end
            end
            fprintf('\n');
            
            disp('Reframing image...')
            reframed_image_alignee = mat2cell(stabilized_intensities_alignee, imgSize(1)*ones(1,imgSize(3)), imgSize(2));
            
            disp(['Saving disinterleaved aligned ch' alignee_channel ' image...'])
            disinterleaved_aligned_file_alignee = Tiff([path name '_ch' alignee_channel alignFnEnd{2}(5:end)], 'a');
            
            fprintf('%4d%% done', 0)
            for i = 1:length(reframed_image_alignee)
                if ~mod(i, round(length(reframed_image_alignee)/100))
                    fprintf('\b\b\b\b\b\b\b\b\b\b');
                    fprintf('%4d%% done', round(100*i/length(reframed_image_alignee)))
                end
                disinterleaved_aligned_file_alignee.setTag('ImageLength',imageLength);
                disinterleaved_aligned_file_alignee.setTag('ImageWidth',imageWidth);
                disinterleaved_aligned_file_alignee.setTag('Photometric',photometric);
                disinterleaved_aligned_file_alignee.setTag('BitsPerSample',bitsPerSample);
                disinterleaved_aligned_file_alignee.setTag('SamplesPerPixel',samplesPerPixel);
                disinterleaved_aligned_file_alignee.setTag('Compression',compression);
                disinterleaved_aligned_file_alignee.setTag('PlanarConfiguration',planarConfiguration);
                disinterleaved_aligned_file_alignee.setTag('ImageDescription',[imageDescription '\n' 'slices=' num2str(length(reframed_image_alignee))]);
                frame = uint16(reframed_image_alignee{i});
                
                disinterleaved_aligned_file_alignee.write(frame)
                disinterleaved_aligned_file_alignee.writeDirectory();
            end
            fprintf('\n');
            disinterleaved_aligned_file_alignee.close()
        else
            disp('No other channel acquired.')
        end
        
        analysis_fn_OR_imgFrames = cell2mat(reshape(reframed_image, 1, 1, imgSize(3)));
    else
        if any(strcmp([name alignFnEnd{1}], {tifFiles.name}))
            analysis_fn = [name alignFnEnd{1}];
        elseif any(strcmp([name alignFnEnd{2}], {tifFiles.name}))
            analysis_fn = [name alignFnEnd{2}];
        else
            error('Something''s gone seriously wrong with programming skilllzzzz -.- We got in this segment because strcmp() said the filename was appropriate, but now it says it''s not. Boo.');
        end
        
        analysis_fn_OR_imgFrames = zeros(imgSize);
        
        TifLinkImage = Tiff([path analysis_fn], 'r');
        numSlices = imgSize(3);
        
        for i = 1:numSlices
            TifLinkImage.setDirectory(i)
            analysis_fn_OR_imgFrames(:, :, i) = TifLinkImage.read();
        end
        TifLinkImage.close();
    end
    
end