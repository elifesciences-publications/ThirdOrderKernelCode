function filter = FilterGeneration(fpara,varargin)

ipara.ver.nPixel = 1e4;
ipara.hor.nPixel = 1e4;

for ii = 1:2:length(varargin)
    eval([varargin{ii} ,' = ',num2str(varargin{ii + 1}),';']);
end

GaussianRange = fpara.GaussianRange;
sig = fpara.nVerSig;
% check the number of pixel being averaged.
% the size of the filter will not be larger than the size of the pictures.
if 2 * sig * GaussianRange + 1> floor(ipara.ver.nPixel/2)
    range = - floor(ipara.ver.nPixel/2) : floor(ipara.ver.nPixel/2);
else
    range = -GaussianRange  * sig : GaussianRange  * sig;
end
y = normpdf(range,0,sig)';


GaussianRange = fpara.GaussianRange;
sig = fpara.nHorSig;
if 2 * sig * GaussianRange + 1 > floor(ipara.hor.nPixel)
    range = - floor(ipara.hor.nPixel) : floor(ipara.hor.nPixel);
else
    range = -GaussianRange  * sig : GaussianRange  * sig;
end
x = normpdf(range,0,sig)';

[meshy,meshx] = ndgrid(y,x);
filter = meshy.*meshx;


% if fpara.FWHM == 360
%     % do not show filter....
% end
% % define that 360 is not a Gussian filter, just something new. 

end