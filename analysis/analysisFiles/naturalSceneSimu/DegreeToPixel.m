function nPixel = DegreeToPixel(degree, d)
% ideally, the function would get a number, abosolute number of the
% coordination, and changed it into number of pixel

% d = 'h', horizontal, d = 'v', vertical


% horizontally, it contains 927 pixel and represents 360 degree. 
nPixelHor = 927;
degreeHor = 360;

% vertically, it contains 251 pixel and represents 90 degree.
nPixelVer = 251;
degreeVer = 45 + 52.3707;

if strcmp(d,'h')
    nPixel = round(degree/degreeHor * nPixelHor);
elseif strcmp(d,'v')
    nPixel = round(degree/degreeVer * nPixelVer);
end

if nPixel == 0
    % the degree chosen is too small
    nPixel = 1;
    keyboard;
end
% 
end