function conf = StarsAndBars (nStar,nBar)
    %% Returns the position of nmar in nbis, allowing the marbles to be in the same bin.

    %% This is standard stars and bars.
     numSymbols = nBar+nStar-1;
     stars = nchoosek (1:numSymbols, nStar);

    %% Star labels minus their consecutive position becomes their index
    %% position!
     idx = bsxfun (@minus, stars, 0:nStar-1);

    %% Manipulate indices into the proper shape for accumarray.
     nr = size (idx, 1);
     a = repmat (1:nr, nStar, 1);
     b = idx';
     conf = [a(:), b(:)];
     conf = accumarray (conf, 1);
end