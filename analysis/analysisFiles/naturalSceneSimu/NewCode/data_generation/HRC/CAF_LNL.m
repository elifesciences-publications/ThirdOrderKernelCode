function response = CAF_LNL(stimulus, isNFlag)
response_L1_full = zeros(length(stimulus), 1);
response = zeros(length(stimulus), 1);

% define parameter for LN model.
c0 = 0.01;
dt = 1/60; % 60Hz.
f1_tau = 0.02; % 20ms;
f2_tau = 0.05; % 50ms.
f1_tau_n = f1_tau/dt;
f2_tau_n = f2_tau/dt;
max_tau = 10;
t_n = 1:max_tau;
f1 = exp(-t_n/f1_tau_n); f1  = f1/sum(f1);
f2 = exp(-t_n/f2_tau_n); f2 = f2/sum(f2);

%% get response of stimulus .
response_L1 = conv(stimulus, f1, 'valid');

response_L1_full(max_tau:end) = response_L1;
if isNFlag
    response_NL1 = tanh(response_L1_full/c0);
else
    response_NL1 = response_L1_full/c0;
end

response_L2 = conv(response_NL1, f2, 'valid');
response(max_tau:end) =  response_L2;
end