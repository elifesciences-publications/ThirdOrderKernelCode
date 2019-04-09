function time = ParameterFile_TimeInfomation(duration, varargin)
dt = 1/60;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
time.dt = dt; 
time.duration = duration;
time.t = 0:(time.dt):(time.duration);
time.n = length(time.t);
end