function stim = VisualStimulusGeneration_CreateXT(c, v,time,image)
x = image.param.hor.x;
x0 = x;
% create time coordination;
dt = time.dt;
dur = time.duration;
t = (0:dt:dur)';
nT = length(t);

% output of , time series of a signal that photoreceptor received.
stim = zeros(nT,length(x));

xShift = v * t; 
xi = bsxfun(@minus, x0, xShift);

% construct the big image according to the range of xShift.
a = ceil((max(max(xi)) - x(end))/360);
b = ceil((x(1) - min(min(xi)))/360);
if a < 0 
    a = 0;
end
if b < 0;
    b = 0;
end
% extra image needed to be put on the image.
% turn c into column;
c = reshape(c,[length(c),1]);
C = repmat(c,[a+b+1,1]);

% compute corresponding xlong.
x = reshape(x,[length(x),1]);
scaler = (-b:1:a) * 360;
xlong = bsxfun(@plus, x, scaler);
xlong = xlong(:);

% sampling method changed to integration. from then on...
% it is time-averaging of the signal...
% the pixel of the picutre is 927 for 360 degree. therefore, for every
% 1/3 degree, there will be an effective pixel.
% use the xi to create a reasonable sampling vector.
% first, decide on the value of dxi

for tt = 1:1:nT
    stim(tt,:) =interp1(xlong,C,xi(tt,:),'linear');
end
%s = interp1(xlong,C,xi,'linear');


% MakeFigure; imagesc(stim); colormap(gray)
end