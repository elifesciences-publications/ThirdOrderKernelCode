function HRC = HRCGenerator(HRC)

tau = HRC.param.tau;
t = HRC.param.t;

f = t.*exp(-t/tau);
f = f/sum(f);
g = (1 - t/tau).* exp(-t/tau);
g = g/sum(g);

HRC.f = f;
HRC.g = g;
%HRC.param.
% calculate the filter of HRC

