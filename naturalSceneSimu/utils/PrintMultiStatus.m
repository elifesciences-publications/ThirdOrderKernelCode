function PrintMultiStatus(param,numParams)

    fakeDXY = zeros(1,5);
    numChars = PrintStatus(0,1,'',fakeDXY,fakeDXY,0);
    deleteStr = repmat('\b',[1 numChars]);
    fprintf(deleteStr);
    multiDeleteStr = repmat('\b',[1 42]);
    
    paramStr = ['Running parameter file ' num2str(param) ' of ' num2str(numParams)];
    if (param > 1)
        fprintf(multiDeleteStr);
    else
        fprintf('\n\n')
    end
    fprintf('%-40s\n\n',paramStr);
    
    
    