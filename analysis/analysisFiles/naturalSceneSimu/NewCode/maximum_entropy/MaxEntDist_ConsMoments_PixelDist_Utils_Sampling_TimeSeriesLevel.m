function time_series_level  = ...
    MaxEntDist_ConsMoments_PixelDist_Utils_Sampling_TimeSeriesLevel(x_solved_scale, gray_value, N, K, n_sample,varargin);
%
n_highest_moments = 3;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
p_joint = MaxEntDis_ConsMoments_Utils_FromLambdaToP(x_solved_scale, gray_value, N, 1,'n_highest_moments',n_highest_moments);
time_series_level =  GibbsSampling_Utils_OD_Sample(p_joint, n_sample);
end