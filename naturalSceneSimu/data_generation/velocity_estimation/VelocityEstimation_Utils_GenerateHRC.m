function HRC = VelocityEstimation_Utils_GenerateHRC()
% get the same sampling rate
dt = 1/60;
dur = 63/60;
tau = 20 * 1e-3;
t = 0:dt:dur;
f = t.*exp(-t/tau);
f = f/sum(f);
g = (1 - t/tau).* exp(-t/tau);
g = g/sum(g);

HRC.f = f;
HRC.g = g;
HRC.param.tau = tau;
HRC.param.dur = dur;
HRC.param.t = t;
end