function out = LoadTiffStack(dirFile, startSpacing,numSlices)
warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
% info = imfinfo(dirFile);
TifLink = Tiff(dirFile, 'r');
info = TifLink.getTag('ImageDescription');
width = TifLink.getTag('ImageWidth');
height = TifLink.getTag('ImageLength');

% TODO This'll make numSlices calculations better
% numSlicesCell = regexp(TifLinkImage.getTag('ImageDescription'), 'slices=(\d+)', 'tokens');
%     numSlices = str2double(numSlicesCell{1}{1});

if nargin < 2
    fileInf = dir(dirFile);
    start = 1;
    spacing = 1;
    % This is an estimate of the number of slices making the assumption
    % that info makes up most of the size of the header--usually true, but
    % worst case scenario it preallocates more than necessary
    numSlices = ceil(fileInf.bytes/(2*width*height+length(info)));
elseif nargin < 3
    start = startSpacing(1);
    spacing = startSpacing(2);
    fileInf = dir([dirFile '*']);
    % This is an estimate of the number of slices making the assumption
    % that info makes up most of the size of the header--usually true, but
    % worst case scenario it preallocates more than necessary
    numSlices = ceil(fileInf.bytes/(2*width*height+length(info))/spacing);

end



out(height,width,numSlices) = 0;
fprintf('%4d%% done\n', 0)
insertFrame = 1;
% if numSlices < 2^16-1
    TifLink.setDirectory(start);
    lastDirectory = false;
    while ~lastDirectory && (TifLink.currentDirectory < 2^16-1)
        %     lastDirectory = TifLink.lastDirectory();
        out(:,:,insertFrame) = TifLink.read();
        percentDone = round(100*(insertFrame)/numSlices);
        fprintf('\b\b\b\b\b\b\b\b\b\b\b%4d%% done\n', percentDone)
        insertFrame = insertFrame+1;
        for step = 1:spacing
            lastDirectory = TifLink.lastDirectory();
            if ~lastDirectory && (TifLink.currentDirectory < 2^16-1)
                TifLink.nextDirectory();
            else
                break
            end
        end
    end
    if ~TifLink.lastDirectory()
        info = imfinfo(dirFile);
        numSlices = length(info);
        newStart = TifLink.currentDirectory;
        allIndexes = start:spacing:numSlices;
        for i = allIndexes(allIndexes>=newStart);
            out(:,:,insertFrame) = imread(dirFile, 'Index', i, 'Info', info);
            percentDone = round(100*(i)/numSlices);
            fprintf('\b\b\b\b\b\b\b\b\b\b\b%4d%% done\n', percentDone)
            insertFrame = insertFrame + 1;
        end
    else
        out(:, :, insertFrame) = TifLink.read();
    end
    fprintf('\b\b\b\b\b\b\b\b\b\b\b%4d%% done\n', 100)
% else
%     info = imfinfo(dirFile);
%     numSlices = length(info)/spacing;
%     for i = start:spacing:numSlices
%         out(:,:,insertFrame) = imread(dirFile, 'Index', i, 'Info', info);
%         percentDone = round(100*(insertFrame)/numSlices);
%         fprintf('\b\b\b\b\b\b\b\b\b\b%4d%% done', percentDone)
%         insertFrame = insertFrame + 1;
%     end
% end

% We're removing extra preallocated frames. Note that insertFrame gets one
% added before you break out of the loop, so no need to do it here.
% out(:, :, insertFrame:end) = [];
out = out(:, :, 1:insertFrame-1);


TifLink.close();