function filename = ConvertToFilename(input)
    %create list of characters that are unnacceptable in a filename and get
    %rid of them.
    deleteChars = {'<' '>' ':' '"' '/' '\' '|' '?' '*' ' '};
    
    for ii = 1:length(deleteChars)
        input = input(input~=deleteChars{ii});
    end
    
    filename = input;
end