function p = GetParamsFromPaths(filePaths)

for ff = 1:length(filePaths);
    [~,name,ext] = fileparts(filePaths{ff});
    switch ext
        case '.txt'
            % Read the file into a Table (first two lines no longer
            % relevant)
            T = readtable(filePaths{ff},'Delimiter','\t','ReadVariableNames',false,'HeaderLines',2);
            Nepochs = width(T)-1;
            Nparams = height(T);
            for jj=1:Nepochs
                for ii=1:Nparams
%                     eval([T{ii,1}{1} '= T{ii,1+jj};']);
                    if isnumeric(T{ii,1+jj}) %Entire column was numeric, so it stayed numeric
                        eval([T{ii,1}{1} '= T{ii,1+jj};'])
                    else %At least one row was a string, convert all others back to numerics
                       [value,wasConverted] = str2num(T{ii,1+jj}{1});
                        if wasConverted
                            eval([T{ii,1}{1} '= value;']);
                        else
                            eval([T{ii,1}{1} '= T{ii,1+jj}{1};']);
                        end
                    end
                end
                p{ff}(jj) = Stimulus; % All param names must be in the form Stimulus.XXX
            end
        case '.csv'
            f = fopen(filePaths{ff});
            % Read the first line containing 'headerSize N' where N is the
            % size of the header
            headerLine = textscan(f, '%s',1,'delimiter', '\n');
            headerSize = textscan(headerLine{1}{1},'%s %f',1,'Delimiter',',');
            
            % Use headerSize to read header. Contains global paramFile
            % preferences which will be added to all epochs
            header = textscan(f,'%s %s',headerSize{2}-1,'Delimiter',',','MultipleDelimsAsOne',1);
            fclose(f);
            for ii = 1:headerSize{2}-1
                [value,wasConverted] = str2num(header{2}{ii});
                if wasConverted
                    eval(['Stimulus.' header{1}{ii} '= value;']);
                else
                    eval(['Stimulus.' header{1}{ii} '= header{2}{ii};']);
                end
            end
            
            % Read the rest of the file into a Table
            T = readtable(filePaths{ff},'Delimiter',',','ReadVariableNames',false,'HeaderLines',headerSize{2});
            
            for epoch = 1:(width(T)-1)
                for param = 1:height(T)
                    if isnumeric(T{param,epoch+1}) %Entire column was numeric, so it stayed numeric
                        eval(['Stimulus.' T{param,1}{1} '= T{param,epoch+1};'])
                    else %At least one row was a string, convert all others back to numerics
                       [value,wasConverted] = str2num(T{param,epoch+1}{1});
                        if wasConverted
                            eval(['Stimulus.' T{param,1}{1} '= value;']);
                        else
                            eval(['Stimulus.' T{param,1}{1} '= T{param,epoch+1}{1};']);
                        end
                    end
                end
                p{ff}(epoch) = Stimulus; % All param names must be in the form Stimulus.XXX
            end
        otherwise
            error(['Unidentified paramfile filetype: ' name ext]);
    end 
end