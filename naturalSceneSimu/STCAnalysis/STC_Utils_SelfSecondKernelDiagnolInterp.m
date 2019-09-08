function kernel = STC_Utils_SelfSecondKernelDiagnolInterp(kernel)
    % get the off diag. four!
    maxTau = round(sqrt((size(kernel,1))));
    k = reshape(kernel,[maxTau,maxTau]);
    off_diag_ind = triu(true(maxTau,maxTau),1) & tril(true(maxTau,maxTau),1);
    % three values.
    off_diag_val = kernel(off_diag_ind);
    off_diag_val_smoothed = smooth(off_diag_val,3);
    % use the three average
    k(eye(maxTau) == 1) = [off_diag_val_smoothed;0];
    
    kernel = k(:);
end