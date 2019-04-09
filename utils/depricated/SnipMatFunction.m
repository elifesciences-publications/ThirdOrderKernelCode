function output = snipMatFunction(input,func,property)
    switch property
        case 'walk'
            index = 1;
        case 'turn'
            index = 1;
        otherwise
            index = 1:2;
    end
    output = cellfun(@(x) func(x(:,:,index)),input,'UniformOutput',false);
end