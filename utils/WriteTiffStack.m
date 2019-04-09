function out = WriteTiffStack(imgToWriteOut, dirFile, info)

photometric = Tiff.Photometric.MinIsBlack;
samplesPerPixel = 1;
compression = Tiff.Compression.None;
planarConfiguration = Tiff.PlanarConfiguration.Chunky;

imgToWriteOut = uint16(imgToWriteOut);
bitsPerSample = 16;
% info = imfinfo(dirFile);
TifLink = Tiff(dirFile, 'w');
if nargin == 3
    
end

[imageLength, imageWidth, numFrames] = size(imgToWriteOut);
fprintf('%4d%% done', 0)

for frame = 1:numFrames
    TifLink.setTag('ImageLength',imageLength);
    TifLink.setTag('ImageWidth',imageWidth);
    TifLink.setTag('Photometric',photometric);
    TifLink.setTag('BitsPerSample',bitsPerSample);
    TifLink.setTag('SamplesPerPixel',samplesPerPixel);
    TifLink.setTag('Compression',compression);
    TifLink.setTag('PlanarConfiguration',planarConfiguration);
    
    
    TifLink.write(imgToWriteOut(:, :, frame))
    TifLink.writeDirectory();
    percentDone = round(100*(frame)/numFrames);
    fprintf('\b\b\b\b\b\b\b\b\b\b%4d%% done', percentDone)
end


TifLink.close();
fprintf('\n');

