function [nsr, kernel_fft_half] = STC_Utils_DeconvFirstKernel_EstimateSNR(kernel, centerOfRF, varargin)
xRange = 1;
tRange = 2;

for ii = 1:2:length(varargin)
    eval([varargin{ii},' = ', num2str(varargin{ii + 1}),';']);
end
[maxTau,nMultiBars] = size(kernel);
kernel_fft = zeros(size(kernel));
for ii = 1:1:nMultiBars
    kernel_fft(:,ii) = fft(kernel(:,ii));
end

kernel_fft_half = kernel_fft(1:floor(maxTau/2) + 1,:);
kernel_fft_half(2:end,:) = 2 * kernel_fft_half(2:end,:);

% last half for noise
startingPoint = floor(size(kernel_fft_half,1) /2);
a = abs(kernel_fft_half(startingPoint:end,:)).^2;
n_power = mean(a(:));

% first several pixel for signal
b = abs(kernel_fft_half(2:tRange + 1,MyMode([centerOfRF - xRange:1:centerOfRF + xRange],nMultiBars))).^2;
s_power = mean(b(:));
nsr = n_power/s_power;
end