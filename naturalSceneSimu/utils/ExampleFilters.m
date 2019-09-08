function [ filters ] = ExampleFilters( whichOrder, maxTau )
% Generates simple example filters to use. WhichFilts should be a vector of
% logicals: [1 0 0] for first order only, [0 1 1] for second and third,
% etc.

if whichOrder(1)
    filtx = linspace(1,maxTau,maxTau);
    lpfun = @(x,tau) x.*exp(-x/tau);
    lpfast = lpfun(filtx,5);
    lpslow = lpfun(filtx,10);
    filters{1} = lpslow;

end

if whichOrder(2)
    filtx = linspace(1,maxTau,maxTau);
    lpfun = @(x,tau) x.*exp(-x/tau);
    lpfast = lpfun(filtx,5);
    lpslow = lpfun(filtx,10);
    filters{2} = lpslow'*lpfast - lpfast'*lpslow;
end

if whichOrder(3)
    [X Y Z] = meshgrid(linspace(1,maxTau,maxTau),linspace(1,maxTau,maxTau),...
    linspace(1,maxTau,maxTau));
    omx = .02; omy = .01; omz = .1;
    filters{3} = exp(-(Y+X+Z).^2/40^2).*cos(omx*X.^2 + omy*Y.^2 + omz*Z.^2);
end

end

