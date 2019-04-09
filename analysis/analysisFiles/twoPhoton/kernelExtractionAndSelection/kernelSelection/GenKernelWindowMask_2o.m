function windMask = GenKernelWindowMask_2o(maxTau,dtMax,tMax,direction)
A = true(maxTau,maxTau);
% calculate things for the lower side.
Pro = tril(A,dtMax) & triu(A,0);
Pro(tMax:end,:) = false;
% calculate things for the upper side.
Reg = triu(A,-dtMax) & tril(A,0);
Reg(:,tMax:end)= false;

switch direction
    case 1 % prefered direction
        windMask = Pro;
    case -1 % null direction
        windMask = Reg;
    case 0 % no direction selectivity.
        windMask = Pro | Reg;
end