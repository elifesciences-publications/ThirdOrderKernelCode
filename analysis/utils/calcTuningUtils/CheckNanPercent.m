function CheckNanPercent(x)
    x = x(:);
    
    percentThreshold = 10;
    
    percentNan = 100*sum(isnan(x))/length(x);
    
    if percentNan>=percentThreshold
        warning([num2str(percentNan) '% of bootstraps returned nan']);
    end
end