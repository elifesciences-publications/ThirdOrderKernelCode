function outSize = CsvSize(file,exhaustive)
    
    if(nargin < 2)
        exhaustive = false;
    end
    if exhaustive
        outSize = size(csvread(file, 1, 0));
    else
        fh = fopen(file, 'rt');
        assert(fh ~= -1, 'Could not read: %s', file);
        x = onCleanup(@() fclose(fh));

        %Read num lines
        lineCount = 0;
        while ~feof(fh)
            lineCount = lineCount + sum( fread( fh, 16384, 'char' ) == char(10) );
        end

        %Read num columns
        frewind(fh)
        tline = fgetl(fh);
        colCount = length(find(tline==',')) + 1;

        outSize = [lineCount colCount];
    end
end
    