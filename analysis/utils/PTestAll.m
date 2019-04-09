function PPT = PTestAll(input)
    assert(size(input,2) == 1,'pTest only works on single flies for now');
    numPermutations = 1000;
    
    timeMeanStruct = snipMatCombineInput(input,'time');
    timeMean = timeMeanStruct.comb;
    numParams = size(timeMean,1);
    PPT.walkDifferences = zeros(numParams);
    PPT.turnDifferences = zeros(numParams);
    PPT.walkSignificance = zeros(numParams);
    PPT.turnSignificance = zeros(numParams);
    PPT.walkAllPermunations = zeros(numParams,numParams,numPermutations);
    PPT.turnAllPermunations = zeros(numParams,numParams,numPermutations);
    
    for firstParam = 1:numParams
        for secondParam = (firstParam+1):numParams
            diffParams = mean(timeMean{firstParam},2) - ...
                         mean(timeMean{secondParam},2);
            concatTrials = cat(2,timeMean{firstParam},timeMean{secondParam});
            totalTrials = size(concatTrials,2);
            numMoreDifferent = zeros(1,1,2);
            for permutation = 1:numPermutations
                random = rand(totalTrials,1);
                randFirstParamIndex = find(random >= 0.5);
                randSecondParamIndex = find(random < 0.5);
                randFirstParam = concatTrials(1,randFirstParamIndex,:);
                randSecondParam = concatTrials(1,randSecondParamIndex,:);                
                randDiffParams = mean(randFirstParam,2) - mean(randSecondParam,2);
                numMoreDifferent = numMoreDifferent + (abs(randDiffParams) > abs(diffParams));
                PPT.walkAllPermutations(firstParam,secondParam,permutation) = randDiffParams(2);
                PPT.turnAllPermutations(firstParam,secondParam,permutation) = randDiffParams(1);
                PPT.walkAllPermutations(secondParam,firstParam,permutation) = randDiffParams(2);
                PPT.turnAllPermutations(secondParam,firstParam,permutation) = randDiffParams(1);
            end
            PPT.walkDifferences(firstParam,secondParam) =  diffParams(2);
            PPT.walkDifferences(secondParam,firstParam) = -diffParams(2);
            PPT.turnDifferences(firstParam,secondParam) =  diffParams(1);
            PPT.turnDifferences(secondParam,firstParam) = -diffParams(1);
            PPT.walkSignificance(firstParam,secondParam) =  numMoreDifferent(2)/numPermutations;
            PPT.walkSignificance(secondParam,firstParam) =  numMoreDifferent(2)/numPermutations;
            PPT.turnSignificance(firstParam,secondParam) =  numMoreDifferent(1)/numPermutations;
            PPT.turnSignificance(secondParam,firstParam) =  numMoreDifferent(1)/numPermutations;
        end
    end