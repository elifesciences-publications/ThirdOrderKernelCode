function M = MyConv2(I, f)
% I is the image, 
% f is the filter
f = f/sum(f(:));
% normalize the intergral of f to be 1.

% I is thought to be the picture.
nx = size(I,2);
ny = size(I,1);

nfx = size(f,2);
nfy = size(f,1);

C = [I,I,I];
D = flipud(C);
C = [D;C;D];

% chose the central patch which could be convolved with f.
% cut part of it, so the whole image is smaller and conv2 is a little bit
% quicker.
startXL = nx + 1 - nfx;
endXL = 2 * nx + nfx;
startYL = ny + 1 - nfy;
endYL = 2 * ny + nfy;

I = C(startYL:endYL,startXL:endXL);


% filter in this program is the W, not traditional filer H.
% however, all filter is symmetrical so that f = -f';
% H(x,y) = W(-x,-y);
% Here, W = f, and f(x,y) = f(-x,-y)
% so, H = W.
M = conv2(I,f,'same');

startX = nfx + 1;
endX = startX + nx - 1;
startY = nfy + 1;
endY = startY + ny - 1;
M = M(startY:endY,startX:endX);

% how do you test it whether it is right or wrong...

end