function pValue = MattTwoSamplePairedTTest(meanDiff,stdDiff,n)
    tStar = meanDiff/(stdDiff/sqrt(n));
    pValue = 2*tcdf(-abs(tStar),n-1);
end