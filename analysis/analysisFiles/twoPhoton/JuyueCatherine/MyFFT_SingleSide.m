function [resp_f_amp,resp_f_pha, f, amp_, pha_] = MyFFT_SingleSide(resp,Fs,f_)
% resp is the response.
% Fs is the sampleing frequency of the response. 
% f_ is the frequency you are interested in. like 0.9375, 7.5Hz, or 15 Hz...

% output:
% resp_f_amp; amplitude of fourier transform
% resp_f_pha; phase of fourier transform
% f: corresponding frequency vector.
% amp_: amplitude at the frequency you are interested in.
% pha_: phase at the frequency you are interested in.

if round(Fs/f_) ~= Fs/f_
    warning('you have to do interpolation yourself! HaHa!');
else
    
    % calculate what is the best length for fft, so that f_ can be found directly after
    % fft. [To avoid intepolation on frequency space]
    
    l_ori = length(resp);
    L = ceil(l_ori * f_/Fs) * Fs / f_;% is it possible that L is an odd number?
    % pad zeros if L is larger than l_ori;
    resp = [resp;zeros(L - l_ori,1)]; % you do not have to pad zeros.
end

L = length(resp);
f = Fs * (0:L/2)/L;
resp_f_doubelside = fft(resp);
% what if L is an odd number?
resp_f_singleside = resp_f_doubelside(1:floor(L/2) + 1); % what is
% are they the same ? test...
% resp_f1_ = fft(resp,L);
resp_f_amp = abs(resp_f_singleside/L); % normalize by total time, and transfer to single side.
resp_f_amp(2:end) = 2 * resp_f_amp(2:end); % 0 frequency does not have to be doubled.
resp_f_pha = angle(resp_f_singleside);

if round(Fs/f_) ~= Fs/f_
    warning('you have to do interpolation yourself! HaHa!');
    amp_ = [];
    pha_ = [];
else
    amp_ = resp_f_amp(f == f_);
    pha_ = resp_f_pha(f == f_);
end



end