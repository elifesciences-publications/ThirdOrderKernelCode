function p = MattPermutationTest(x,y,numBoot)
    % performs a permutation test on the vectors x and y to determine if
    % they have significantly different means
    % this will combine the two data sets and then randomly select from
    % this combined dataset subsets the same size as x and y
    % it will then determine the number of times that randomly selecting
    % subsets of the population generated means of the two populations as
    % or more different than what was actually observered.
    
    % essentially this is determining the probability that we would observe
    % the means of x and y as or more different as they are if in fact x
    % and y came from the same distribution. This is similar to a two
    % sample t-test for normally distributed data but should work for any
    % distribution.
    
    % I should note that this is not an exact test because I do not test
    % every possible subsample of the combined x and y vector
    
    % make sure x and y are column vectors
    x = x(:);
    y = y(:);
    
    % get rid of nans
    x = x(~isnan(x));
    y = y(~isnan(y));
    
    % number of samples in each
    nx = length(x);
    ny = length(y);
    
    % observed difference between the two distributions
    difference = abs(mean(x) - mean(y));
    
    % combined data set of both x and y
    combined = [x; y];
    
    % generate bootstrap resampling of the combined distribution
        
    % choose columns from combined of size nx and size ny
    valsA = ceil(length(combined)*rand(nx,numBoot));
    valsB = ceil(length(combined)*rand(ny,numBoot));

    % extract those values from combined
    sampleA = combined(valsA);
    sampleB = combined(valsB);

    % measure the mean of the sampled values
    meanA = mean(sampleA);
    meanB = mean(sampleB);

    % ask if the observed difference is >= than the distance
    % observed
    numGreaterThan = sum(abs(meanA - meanB) >= difference);
    
    p = numGreaterThan/numBoot;
end