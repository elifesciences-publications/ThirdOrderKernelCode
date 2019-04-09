function tifSplitter(varargin)
% This function slpits up TIFs into their component layer and then makes
% sure to save the imageDescription that goes with each frame into the new
% image

% framesPerGrab will usually be calculated using the image description, but
% it stands here as a variable to allow it to be manipulated by a varargin
framesPerGrab = 0;

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


[imgFrames, fn, path, ~] = twoPhotonImageParser('splitImage', true, 'channelDesired', 'all', varargin{:}, 'runPDAnalysis', 'no');

tifFile = Tiff([path fn]);

imageLength = tifFile.getTag('ImageLength');
imageWidth = tifFile.getTag('ImageWidth');
photometric = tifFile.getTag('Photometric');
bitsPerSample = tifFile.getTag('BitsPerSample');
samplesPerPixel = tifFile.getTag('SamplesPerPixel');
compression = tifFile.getTag('Compression');
planarConfiguration = tifFile.getTag('PlanarConfiguration');
imageDescription = tifFile.getTag('ImageDescription');

% Assuming no user set frames per grab has been given (this allows the user
% to manually split an image whichever way they want)
if ~framesPerGrab
    % Here you figure out how many channels were saved
    tifInfDescription = strsplit(imageDescription, sprintf('\r'));
    acquiredChannelCell = regexp(tifInfDescription, 'saving.*(\d+)=[^0]', 'tokens');
    numChannels = sum(~cellfun('isempty', acquiredChannelCell));
    % And then you multiply that by the number of frames per channel
    framesPerGrabCell = regexp(imageDescription, 'numberOfFrames=(\d+)', 'tokens');
    framesPerGrab = numChannels*str2double(framesPerGrabCell{:}{:});
end



%Outer loop goes through each z level
for i = 1:framesPerGrab:size(imgFrames, 3)
    disp(['i = ' num2str(i)])
    %If the split's not even, the remainder won't have framesPerGrab parts.
    %To handle this, note it in the filename and then change framesPerGrab
    %to grab the rest of the image in the for loop
    if (i+framesPerGrab-1) > size(imgFrames, 3)
        outImageFilename = [path fn(1:end-4) '_' num2str(i) '_remainder' '.tif'];
        framesPerGrab = size(imgFrames, 3) + 1 - i;
    else
        outImageFilename = [path fn(1:end-4) '_' num2str(i) '.tif'];
    end
    tifOutFile = Tiff(outImageFilename, 'a');
    for x = 1:framesPerGrab
        tifOutFile.setTag('ImageLength',imageLength);
        tifOutFile.setTag('ImageWidth',imageWidth);
        tifOutFile.setTag('Photometric',photometric);
        tifOutFile.setTag('BitsPerSample',bitsPerSample);
        tifOutFile.setTag('SamplesPerPixel',samplesPerPixel);
        tifOutFile.setTag('Compression',compression);
        tifOutFile.setTag('PlanarConfiguration',planarConfiguration);
        tifOutFile.setTag('ImageDescription',imageDescription);
        if ~mod(x, 100)
            disp(x);
        end
        frame = uint16(imgFrames(:, :, i+x-1));
        tifOutFile.write(frame)
        tifOutFile.writeDirectory();
    end
    tifOutFile.close()
end